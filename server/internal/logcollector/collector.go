package logcollector

import (
	"context"
	"encoding/json"
	"log/slog"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// RequestLog represents an HTTP request log entry.
type RequestLog struct {
	Timestamp  time.Time  `json:"timestamp"`
	Method     string     `json:"method"`
	Path       string     `json:"path"`
	StatusCode int        `json:"status_code"`
	DurationMs float64    `json:"duration_ms"`
	IPAddress  string     `json:"ip_address"`
	UserAgent  string     `json:"user_agent"`
	RequestID  string     `json:"request_id"`
	UserID     *uuid.UUID `json:"user_id,omitempty"`
	ErrorCode  string     `json:"error_code"`
	ErrorMsg   string     `json:"error_msg"`
}

// EventLog represents an application or auth event.
type EventLog struct {
	Timestamp time.Time              `json:"timestamp"`
	Level     string                 `json:"level"`
	EventType string                 `json:"event_type"`
	Message   string                 `json:"message"`
	RequestID string                 `json:"request_id"`
	UserID    *uuid.UUID             `json:"user_id,omitempty"`
	IPAddress string                 `json:"ip_address"`
	Provider  string                 `json:"provider"`
	Metadata  map[string]interface{} `json:"metadata,omitempty"`
}

// LogEntry is a union type sent to SSE subscribers.
type LogEntry struct {
	Type    string      `json:"type"` // "request" or "event"
	Request *RequestLog `json:"request,omitempty"`
	Event   *EventLog   `json:"event,omitempty"`
}

// Broadcaster manages SSE subscribers.
type Broadcaster struct {
	mu      sync.RWMutex
	clients map[chan LogEntry]struct{}
}

func newBroadcaster() *Broadcaster {
	return &Broadcaster{
		clients: make(map[chan LogEntry]struct{}),
	}
}

// Subscribe returns a channel that receives new log entries and an unsubscribe function.
func (b *Broadcaster) Subscribe() (chan LogEntry, func()) {
	ch := make(chan LogEntry, 256)
	b.mu.Lock()
	b.clients[ch] = struct{}{}
	b.mu.Unlock()
	return ch, func() {
		b.mu.Lock()
		delete(b.clients, ch)
		close(ch)
		b.mu.Unlock()
	}
}

func (b *Broadcaster) broadcast(entry LogEntry) {
	b.mu.RLock()
	defer b.mu.RUnlock()
	for ch := range b.clients {
		select {
		case ch <- entry:
		default:
			// slow client, drop
		}
	}
}

// Collector buffers log entries and batch-inserts them into PostgreSQL.
type Collector struct {
	pool        *pgxpool.Pool
	reqCh       chan RequestLog
	evtCh       chan EventLog
	broadcaster *Broadcaster
}

// New creates a new Collector.
func New(pool *pgxpool.Pool) *Collector {
	return &Collector{
		pool:        pool,
		reqCh:       make(chan RequestLog, 10000),
		evtCh:       make(chan EventLog, 5000),
		broadcaster: newBroadcaster(),
	}
}

// Broadcaster returns the SSE broadcaster for subscribing to live logs.
func (c *Collector) Broadcaster() *Broadcaster {
	return c.broadcaster
}

// Collect enqueues a request log entry (non-blocking).
func (c *Collector) Collect(log RequestLog) {
	select {
	case c.reqCh <- log:
	default:
		slog.Warn("logcollector: request log channel full, dropping entry")
	}
	c.broadcaster.broadcast(LogEntry{Type: "request", Request: &log})
}

// CollectEvent enqueues an event log entry (non-blocking).
func (c *Collector) CollectEvent(evt EventLog) {
	select {
	case c.evtCh <- evt:
	default:
		slog.Warn("logcollector: event log channel full, dropping entry")
	}
	c.broadcaster.broadcast(LogEntry{Type: "event", Event: &evt})
}

// Run starts the batch-insert loops. Call in a goroutine. Blocks until ctx is cancelled.
func (c *Collector) Run(ctx context.Context) {
	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		c.runRequestLoop(ctx)
	}()
	go func() {
		defer wg.Done()
		c.runEventLoop(ctx)
	}()
	wg.Wait()
}

func (c *Collector) runRequestLoop(ctx context.Context) {
	batch := make([]RequestLog, 0, 100)
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case log := <-c.reqCh:
			batch = append(batch, log)
			if len(batch) >= 100 {
				c.flushRequests(ctx, batch)
				batch = batch[:0]
			}
		case <-ticker.C:
			if len(batch) > 0 {
				c.flushRequests(ctx, batch)
				batch = batch[:0]
			}
		case <-ctx.Done():
			// drain remaining
			close(c.reqCh)
			for log := range c.reqCh {
				batch = append(batch, log)
			}
			if len(batch) > 0 {
				shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
				c.flushRequests(shutdownCtx, batch)
				cancel()
			}
			return
		}
	}
}

func (c *Collector) runEventLoop(ctx context.Context) {
	batch := make([]EventLog, 0, 50)
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case evt := <-c.evtCh:
			batch = append(batch, evt)
			if len(batch) >= 50 {
				c.flushEvents(ctx, batch)
				batch = batch[:0]
			}
		case <-ticker.C:
			if len(batch) > 0 {
				c.flushEvents(ctx, batch)
				batch = batch[:0]
			}
		case <-ctx.Done():
			close(c.evtCh)
			for evt := range c.evtCh {
				batch = append(batch, evt)
			}
			if len(batch) > 0 {
				shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
				c.flushEvents(shutdownCtx, batch)
				cancel()
			}
			return
		}
	}
}

func (c *Collector) flushRequests(ctx context.Context, batch []RequestLog) {
	rows := make([][]interface{}, len(batch))
	for i, l := range batch {
		rows[i] = []interface{}{
			l.Timestamp, l.Method, l.Path, l.StatusCode, l.DurationMs,
			l.IPAddress, l.UserAgent, l.RequestID, l.UserID,
			l.ErrorCode, l.ErrorMsg,
		}
	}

	_, err := c.pool.CopyFrom(ctx,
		pgx.Identifier{"request_logs"},
		[]string{"timestamp", "method", "path", "status_code", "duration_ms",
			"ip_address", "user_agent", "request_id", "user_id",
			"error_code", "error_msg"},
		pgx.CopyFromRows(rows),
	)
	if err != nil {
		slog.Error("logcollector: failed to flush request logs", "error", err, "count", len(batch))
	}
}

func (c *Collector) flushEvents(ctx context.Context, batch []EventLog) {
	rows := make([][]interface{}, len(batch))
	for i, e := range batch {
		var meta []byte
		if e.Metadata != nil {
			meta, _ = json.Marshal(e.Metadata)
		}
		rows[i] = []interface{}{
			e.Timestamp, e.Level, e.EventType, e.Message,
			e.RequestID, e.UserID, e.IPAddress, e.Provider, meta,
		}
	}

	_, err := c.pool.CopyFrom(ctx,
		pgx.Identifier{"event_logs"},
		[]string{"timestamp", "level", "event_type", "message",
			"request_id", "user_id", "ip_address", "provider", "metadata"},
		pgx.CopyFromRows(rows),
	)
	if err != nil {
		slog.Error("logcollector: failed to flush event logs", "error", err, "count", len(batch))
	}
}

// CleanupLoop deletes logs older than retentionDays. Call in a goroutine.
func (c *Collector) CleanupLoop(ctx context.Context, retentionDays int) {
	// Run immediately on startup
	c.cleanup(ctx, retentionDays)

	ticker := time.NewTicker(1 * time.Hour)
	defer ticker.Stop()
	for {
		select {
		case <-ticker.C:
			c.cleanup(ctx, retentionDays)
		case <-ctx.Done():
			return
		}
	}
}

func (c *Collector) cleanup(ctx context.Context, retentionDays int) {
	cutoff := time.Now().UTC().AddDate(0, 0, -retentionDays)

	tag, err := c.pool.Exec(ctx, "DELETE FROM request_logs WHERE timestamp < $1", cutoff)
	if err != nil {
		slog.Error("logcollector: failed to cleanup request_logs", "error", err)
	} else if tag.RowsAffected() > 0 {
		slog.Info("logcollector: cleaned up request_logs", "deleted", tag.RowsAffected())
	}

	tag, err = c.pool.Exec(ctx, "DELETE FROM event_logs WHERE timestamp < $1", cutoff)
	if err != nil {
		slog.Error("logcollector: failed to cleanup event_logs", "error", err)
	} else if tag.RowsAffected() > 0 {
		slog.Info("logcollector: cleaned up event_logs", "deleted", tag.RowsAffected())
	}
}
