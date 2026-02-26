package dashboard

import (
	"bytes"
	"fmt"
	"net/http"
	"time"

	"github.com/clearbreath/server/internal/logcollector"
)

// SSELogs streams new log entries to the client via Server-Sent Events.
func (d *Dashboard) SSELogs(w http.ResponseWriter, r *http.Request) {
	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "streaming not supported", http.StatusInternalServerError)
		return
	}

	// Set per-connection write deadline using ResponseController
	rc := http.NewResponseController(w)

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	w.Header().Set("X-Accel-Buffering", "no") // disable nginx buffering
	w.WriteHeader(http.StatusOK)
	flusher.Flush()

	ch, unsub := d.broadcaster.Subscribe()
	defer unsub()

	heartbeat := time.NewTicker(15 * time.Second)
	defer heartbeat.Stop()

	for {
		select {
		case entry, ok := <-ch:
			if !ok {
				return
			}
			_ = rc.SetWriteDeadline(time.Now().Add(30 * time.Second))

			var buf bytes.Buffer
			if entry.Type == "request" && entry.Request != nil {
				d.renderRequestSSE(&buf, entry.Request)
				if _, err := fmt.Fprintf(w, "event: request-log\ndata: %s\n\n", buf.String()); err != nil {
					return
				}
			} else if entry.Type == "event" && entry.Event != nil {
				d.renderEventSSE(&buf, entry.Event)
				if _, err := fmt.Fprintf(w, "event: event-log\ndata: %s\n\n", buf.String()); err != nil {
					return
				}
			}
			flusher.Flush()

		case <-heartbeat.C:
			_ = rc.SetWriteDeadline(time.Now().Add(30 * time.Second))
			if _, err := fmt.Fprint(w, ":heartbeat\n\n"); err != nil {
				return
			}
			flusher.Flush()

		case <-r.Context().Done():
			return
		}
	}
}

func (d *Dashboard) renderRequestSSE(buf *bytes.Buffer, log *logcollector.RequestLog) {
	userID := ""
	if log.UserID != nil {
		userID = log.UserID.String()[:8]
	}

	statusClass := statusBadgeClass(log.StatusCode)
	methodClass := methodBadgeClass(log.Method)

	fmt.Fprintf(buf, `<tr class="border-b border-zinc-700/50 hover:bg-zinc-800/50 transition-colors animate-fade-in">`+
		`<td class="px-3 py-2 text-xs text-zinc-400 whitespace-nowrap">%s</td>`+
		`<td class="px-3 py-2"><span class="px-1.5 py-0.5 text-xs font-medium rounded %s">%s</span></td>`+
		`<td class="px-3 py-2 text-sm text-zinc-200 font-mono max-w-xs truncate" title="%s">%s</td>`+
		`<td class="px-3 py-2"><span class="px-1.5 py-0.5 text-xs font-bold rounded %s">%d</span></td>`+
		`<td class="px-3 py-2 text-xs text-zinc-400 whitespace-nowrap">%.1fms</td>`+
		`<td class="px-3 py-2 text-xs text-zinc-500 font-mono">%s</td>`+
		`<td class="px-3 py-2 text-xs text-zinc-500 font-mono">%s</td>`+
		`<td class="px-3 py-2 text-xs text-zinc-500 font-mono">%s</td>`+
		`</tr>`,
		log.Timestamp.Format("15:04:05.000"),
		methodClass, log.Method,
		log.Path, truncate(log.Path, 60),
		statusClass, log.StatusCode,
		log.DurationMs,
		log.IPAddress,
		log.RequestID[:min(16, len(log.RequestID))],
		userID,
	)
}

func (d *Dashboard) renderEventSSE(buf *bytes.Buffer, evt *logcollector.EventLog) {
	levelClass := levelBadgeClass(evt.Level)

	fmt.Fprintf(buf, `<tr class="border-b border-zinc-700/50 hover:bg-zinc-800/50 transition-colors animate-fade-in">`+
		`<td class="px-3 py-2 text-xs text-zinc-400 whitespace-nowrap">%s</td>`+
		`<td class="px-3 py-2"><span class="px-1.5 py-0.5 text-xs font-bold rounded %s">%s</span></td>`+
		`<td class="px-3 py-2 text-xs text-zinc-300">%s</td>`+
		`<td class="px-3 py-2 text-sm text-zinc-200 max-w-md truncate" title="%s">%s</td>`+
		`<td class="px-3 py-2 text-xs text-zinc-500 font-mono">%s</td>`+
		`<td class="px-3 py-2 text-xs text-zinc-500 font-mono">%s</td>`+
		`</tr>`,
		evt.Timestamp.Format("15:04:05.000"),
		levelClass, evt.Level,
		evt.EventType,
		evt.Message, truncate(evt.Message, 80),
		evt.IPAddress,
		evt.Provider,
	)
}

func statusBadgeClass(code int) string {
	switch {
	case code >= 500:
		return "bg-red-500/20 text-red-400"
	case code >= 400:
		return "bg-orange-500/20 text-orange-400"
	case code >= 300:
		return "bg-yellow-500/20 text-yellow-400"
	default:
		return "bg-emerald-500/20 text-emerald-400"
	}
}

func methodBadgeClass(method string) string {
	switch method {
	case "GET":
		return "bg-blue-500/20 text-blue-400"
	case "POST":
		return "bg-green-500/20 text-green-400"
	case "PUT", "PATCH":
		return "bg-yellow-500/20 text-yellow-400"
	case "DELETE":
		return "bg-red-500/20 text-red-400"
	default:
		return "bg-zinc-500/20 text-zinc-400"
	}
}

func levelBadgeClass(level string) string {
	switch level {
	case "error":
		return "bg-red-500/20 text-red-400"
	case "warn":
		return "bg-yellow-500/20 text-yellow-400"
	default:
		return "bg-blue-500/20 text-blue-400"
	}
}

func truncate(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen-3] + "..."
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
