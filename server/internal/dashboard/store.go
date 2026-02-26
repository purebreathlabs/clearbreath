package dashboard

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type RequestLogRow struct {
	ID         int64      `json:"id"`
	Timestamp  time.Time  `json:"timestamp"`
	Method     string     `json:"method"`
	Path       string     `json:"path"`
	StatusCode int        `json:"status_code"`
	DurationMs float64    `json:"duration_ms"`
	IPAddress  string     `json:"ip_address"`
	UserAgent  string     `json:"user_agent"`
	RequestID  string     `json:"request_id"`
	UserID     *uuid.UUID `json:"user_id"`
	ErrorCode  string     `json:"error_code"`
	ErrorMsg   string     `json:"error_msg"`
}

type EventLogRow struct {
	ID        int64      `json:"id"`
	Timestamp time.Time  `json:"timestamp"`
	Level     string     `json:"level"`
	EventType string     `json:"event_type"`
	Message   string     `json:"message"`
	RequestID string     `json:"request_id"`
	UserID    *uuid.UUID `json:"user_id"`
	IPAddress string     `json:"ip_address"`
	Provider  string     `json:"provider"`
	Metadata  []byte     `json:"metadata"`
}

type RequestLogFilters struct {
	StatusGroup string // "2xx", "3xx", "4xx", "5xx"
	Method      string
	Search      string
}

type EventLogFilters struct {
	Level     string
	EventType string
	Search    string
}

type OverviewStats struct {
	TotalRequests24h int64
	ErrorCount24h    int64
	AvgDurationMs    float64
	UniqueIPs24h     int64
}

type store struct {
	pool *pgxpool.Pool
}

func newStore(pool *pgxpool.Pool) *store {
	return &store{pool: pool}
}

func (s *store) ListRequestLogs(ctx context.Context, f RequestLogFilters, page, perPage int) ([]RequestLogRow, int64, error) {
	if page < 1 {
		page = 1
	}
	if perPage < 1 || perPage > 200 {
		perPage = 50
	}

	where, args := buildRequestWhere(f)

	countQ := "SELECT COUNT(*) FROM request_logs" + where
	var total int64
	if err := s.pool.QueryRow(ctx, countQ, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	argIdx := len(args) + 1
	q := fmt.Sprintf(
		"SELECT id, timestamp, method, path, status_code, duration_ms, ip_address, user_agent, request_id, user_id, error_code, error_msg FROM request_logs%s ORDER BY timestamp DESC LIMIT $%d OFFSET $%d",
		where, argIdx, argIdx+1,
	)
	args = append(args, perPage, offset)

	rows, err := s.pool.Query(ctx, q, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var result []RequestLogRow
	for rows.Next() {
		var r RequestLogRow
		if err := rows.Scan(&r.ID, &r.Timestamp, &r.Method, &r.Path, &r.StatusCode, &r.DurationMs, &r.IPAddress, &r.UserAgent, &r.RequestID, &r.UserID, &r.ErrorCode, &r.ErrorMsg); err != nil {
			return nil, 0, err
		}
		result = append(result, r)
	}
	return result, total, rows.Err()
}

func (s *store) ListEventLogs(ctx context.Context, f EventLogFilters, page, perPage int) ([]EventLogRow, int64, error) {
	if page < 1 {
		page = 1
	}
	if perPage < 1 || perPage > 200 {
		perPage = 50
	}

	where, args := buildEventWhere(f)

	countQ := "SELECT COUNT(*) FROM event_logs" + where
	var total int64
	if err := s.pool.QueryRow(ctx, countQ, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	argIdx := len(args) + 1
	q := fmt.Sprintf(
		"SELECT id, timestamp, level, event_type, message, request_id, user_id, ip_address, provider, metadata FROM event_logs%s ORDER BY timestamp DESC LIMIT $%d OFFSET $%d",
		where, argIdx, argIdx+1,
	)
	args = append(args, perPage, offset)

	rows, err := s.pool.Query(ctx, q, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var result []EventLogRow
	for rows.Next() {
		var r EventLogRow
		if err := rows.Scan(&r.ID, &r.Timestamp, &r.Level, &r.EventType, &r.Message, &r.RequestID, &r.UserID, &r.IPAddress, &r.Provider, &r.Metadata); err != nil {
			return nil, 0, err
		}
		result = append(result, r)
	}
	return result, total, rows.Err()
}

func (s *store) GetOverviewStats(ctx context.Context) (OverviewStats, error) {
	since := time.Now().UTC().Add(-24 * time.Hour)
	var stats OverviewStats

	err := s.pool.QueryRow(ctx,
		`SELECT
			COUNT(*),
			COUNT(*) FILTER (WHERE status_code >= 400),
			COALESCE(AVG(duration_ms), 0),
			COUNT(DISTINCT ip_address)
		FROM request_logs WHERE timestamp >= $1`,
		since,
	).Scan(&stats.TotalRequests24h, &stats.ErrorCount24h, &stats.AvgDurationMs, &stats.UniqueIPs24h)

	return stats, err
}

func (s *store) RecentErrors(ctx context.Context, limit int) ([]RequestLogRow, error) {
	rows, err := s.pool.Query(ctx,
		`SELECT id, timestamp, method, path, status_code, duration_ms, ip_address, user_agent, request_id, user_id, error_code, error_msg
		FROM request_logs WHERE status_code >= 400 ORDER BY timestamp DESC LIMIT $1`,
		limit,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []RequestLogRow
	for rows.Next() {
		var r RequestLogRow
		if err := rows.Scan(&r.ID, &r.Timestamp, &r.Method, &r.Path, &r.StatusCode, &r.DurationMs, &r.IPAddress, &r.UserAgent, &r.RequestID, &r.UserID, &r.ErrorCode, &r.ErrorMsg); err != nil {
			return nil, err
		}
		result = append(result, r)
	}
	return result, rows.Err()
}

func buildRequestWhere(f RequestLogFilters) (string, []interface{}) {
	var conditions []string
	var args []interface{}
	idx := 1

	if f.StatusGroup != "" {
		var lo, hi int
		switch f.StatusGroup {
		case "2xx":
			lo, hi = 200, 299
		case "3xx":
			lo, hi = 300, 399
		case "4xx":
			lo, hi = 400, 499
		case "5xx":
			lo, hi = 500, 599
		}
		if lo > 0 {
			conditions = append(conditions, fmt.Sprintf("status_code BETWEEN $%d AND $%d", idx, idx+1))
			args = append(args, lo, hi)
			idx += 2
		}
	}

	if f.Method != "" {
		conditions = append(conditions, fmt.Sprintf("method = $%d", idx))
		args = append(args, strings.ToUpper(f.Method))
		idx++
	}

	if f.Search != "" {
		conditions = append(conditions, fmt.Sprintf("(path ILIKE $%d OR request_id ILIKE $%d OR error_msg ILIKE $%d)", idx, idx, idx))
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	if len(conditions) == 0 {
		return "", nil
	}
	return " WHERE " + strings.Join(conditions, " AND "), args
}

func buildEventWhere(f EventLogFilters) (string, []interface{}) {
	var conditions []string
	var args []interface{}
	idx := 1

	if f.Level != "" {
		conditions = append(conditions, fmt.Sprintf("level = $%d", idx))
		args = append(args, f.Level)
		idx++
	}

	if f.EventType != "" {
		conditions = append(conditions, fmt.Sprintf("event_type = $%d", idx))
		args = append(args, f.EventType)
		idx++
	}

	if f.Search != "" {
		conditions = append(conditions, fmt.Sprintf("(message ILIKE $%d OR request_id ILIKE $%d OR provider ILIKE $%d)", idx, idx, idx))
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	if len(conditions) == 0 {
		return "", nil
	}
	return " WHERE " + strings.Join(conditions, " AND "), args
}
