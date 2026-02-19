package middleware

import (
	"log/slog"
	"net/http"
	"runtime/debug"

	"github.com/clearbreath/server/internal/httpx"
)

func PanicRecovery(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil {
				slog.Error("panic recovered",
					"error", err,
					"stack", string(debug.Stack()),
					"request_id", RequestIDFromContext(r.Context()),
				)
				httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", RequestIDFromContext(r.Context()))
			}
		}()
		next.ServeHTTP(w, r)
	})
}
