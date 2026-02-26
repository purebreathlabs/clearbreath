package middleware

import (
	"fmt"
	"log/slog"
	"net/http"
	"runtime/debug"
	"time"

	"github.com/clearbreath/server/internal/httpx"
	"github.com/clearbreath/server/internal/logcollector"
)

func PanicRecovery(next http.Handler) http.Handler {
	return PanicRecoveryWithCollector(nil)(next)
}

// PanicRecoveryWithCollector returns panic recovery middleware that also logs to the collector.
func PanicRecoveryWithCollector(collector *logcollector.Collector) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if err := recover(); err != nil {
					stack := string(debug.Stack())
					reqID := RequestIDFromContext(r.Context())

					slog.Error("panic recovered",
						"error", err,
						"stack", stack,
						"request_id", reqID,
					)

					if collector != nil {
						collector.CollectEvent(logcollector.EventLog{
							Timestamp: time.Now().UTC(),
							Level:     "error",
							EventType: "panic",
							Message:   fmt.Sprintf("panic: %v", err),
							RequestID: reqID,
							IPAddress: ClientIP(r),
							Metadata: map[string]interface{}{
								"stack": stack,
							},
						})
					}

					httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", reqID)
				}
			}()
			next.ServeHTTP(w, r)
		})
	}
}
