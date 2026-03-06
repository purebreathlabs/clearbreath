package middleware

import (
	"net/http"

	"github.com/clearbreath/server/internal/httpx"
)

// DevAuth guards dev-only endpoints with the X-Dev-Auth header.
func DevAuth(secret string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			requestID := RequestIDFromContext(r.Context())
			h := r.Header.Get("X-Dev-Auth")
			if h == "" || h != secret {
				httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "invalid dev auth", requestID)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}
