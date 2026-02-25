package middleware

import (
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/logcollector"
)

type wrappedWriter struct {
	http.ResponseWriter
	statusCode int
}

func (w *wrappedWriter) WriteHeader(code int) {
	w.statusCode = code
	w.ResponseWriter.WriteHeader(code)
}

// Flush delegates to the underlying ResponseWriter if it supports flushing.
func (w *wrappedWriter) Flush() {
	if f, ok := w.ResponseWriter.(http.Flusher); ok {
		f.Flush()
	}
}

// Unwrap returns the underlying ResponseWriter (needed for http.ResponseController).
func (w *wrappedWriter) Unwrap() http.ResponseWriter {
	return w.ResponseWriter
}

func Logger(next http.Handler) http.Handler {
	return LoggerWithCollector(nil)(next)
}

// LoggerWithCollector returns logging middleware that also writes to the log collector when non-nil.
func LoggerWithCollector(collector *logcollector.Collector) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			wrapped := &wrappedWriter{ResponseWriter: w, statusCode: http.StatusOK}

			next.ServeHTTP(wrapped, r)

			duration := time.Since(start)
			uid := userID(r)

			slog.Info("request",
				"method", r.Method,
				"path", r.URL.Path,
				"status", wrapped.statusCode,
				"duration_ms", duration.Milliseconds(),
				"request_id", RequestIDFromContext(r.Context()),
				"user_id", uid,
			)

			if collector != nil && !strings.HasPrefix(r.URL.Path, "/dashboard") {
				var userUUID *uuid.UUID
				if id, ok := auth.UserIDFromContext(r.Context()); ok {
					userUUID = &id
				}

				collector.Collect(logcollector.RequestLog{
					Timestamp:  start,
					Method:     r.Method,
					Path:       r.URL.Path,
					StatusCode: wrapped.statusCode,
					DurationMs: float64(duration.Microseconds()) / 1000.0,
					IPAddress:  ClientIP(r),
					UserAgent:  r.UserAgent(),
					RequestID:  RequestIDFromContext(r.Context()),
					UserID:     userUUID,
				})
			}
		})
	}
}

func userID(r *http.Request) string {
	id, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		return ""
	}
	return id.String()
}
