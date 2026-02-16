package middleware

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"strings"
	"time"

	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/httpx"
)

func RateLimitIP(rdb *redis.Client, keyPrefix string, limit int, window time.Duration) func(http.Handler) http.Handler {
	return rateLimit(rdb, keyPrefix, limit, window, func(r *http.Request) string {
		return clientIP(r)
	})
}

func RateLimitUser(rdb *redis.Client, keyPrefix string, limit int, window time.Duration) func(http.Handler) http.Handler {
	return rateLimit(rdb, keyPrefix, limit, window, func(r *http.Request) string {
		userID, ok := auth.UserIDFromContext(r.Context())
		if !ok {
			return ""
		}
		return userID.String()
	})
}

func rateLimit(rdb *redis.Client, keyPrefix string, limit int, window time.Duration, idFn func(*http.Request) string) func(http.Handler) http.Handler {
	if limit <= 0 || window <= 0 {
		return func(next http.Handler) http.Handler { return next }
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			id := strings.TrimSpace(idFn(r))
			if id == "" {
				next.ServeHTTP(w, r)
				return
			}

			key := fmt.Sprintf("%s:%s", keyPrefix, id)
			allowed, err := allow(r.Context(), rdb, key, limit, window)
			if err != nil {
				httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", RequestIDFromContext(r.Context()))
				return
			}
			if !allowed {
				httpx.WriteError(w, http.StatusTooManyRequests, "rate_limited", "rate limited", RequestIDFromContext(r.Context()))
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

func allow(ctx context.Context, rdb *redis.Client, key string, limit int, window time.Duration) (bool, error) {
	count, err := rdb.Incr(ctx, key).Result()
	if err != nil {
		return false, err
	}

	if count == 1 {
		if err := rdb.Expire(ctx, key, window).Err(); err != nil {
			return false, err
		}
	}

	return count <= int64(limit), nil
}

func clientIP(r *http.Request) string {
	if xff := strings.TrimSpace(r.Header.Get("X-Forwarded-For")); xff != "" {
		parts := strings.Split(xff, ",")
		if len(parts) > 0 {
			return strings.TrimSpace(parts[0])
		}
	}
	if xrip := strings.TrimSpace(r.Header.Get("X-Real-IP")); xrip != "" {
		return xrip
	}

	host, _, err := net.SplitHostPort(strings.TrimSpace(r.RemoteAddr))
	if err == nil && host != "" {
		return host
	}
	return strings.TrimSpace(r.RemoteAddr)
}
