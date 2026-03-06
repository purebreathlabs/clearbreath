package middleware

import (
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"

	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/httpx"
	"github.com/clearbreath/server/internal/repository"
)

func Auth(tokens *auth.AccessTokenManager, store *repository.Store) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			requestID := RequestIDFromContext(r.Context())
			h := r.Header.Get("Authorization")
			if h == "" {
				httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "missing authorization header", requestID)
				return
			}

			parts := strings.SplitN(h, " ", 2)
			if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" || strings.TrimSpace(parts[1]) == "" {
				httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "invalid authorization header", requestID)
				return
			}

			userID, err := tokens.Parse(parts[1], time.Now().UTC())
			if err != nil {
				httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "invalid access token", requestID)
				return
			}

			if _, err := store.Queries().GetUserByID(r.Context(), userID); err != nil {
				if errors.Is(err, pgx.ErrNoRows) {
					httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "invalid access token", requestID)
					return
				}
				httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
				return
			}

			ctx := auth.ContextWithUserID(r.Context(), userID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// OptionalAuth is like Auth but does not return 401 if no token is present.
// If a valid JWT is present, user_id is set in context. Otherwise, continues without it.
func OptionalAuth(tokens *auth.AccessTokenManager, store *repository.Store) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			h := r.Header.Get("Authorization")
			if h == "" {
				next.ServeHTTP(w, r)
				return
			}

			parts := strings.SplitN(h, " ", 2)
			if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" || strings.TrimSpace(parts[1]) == "" {
				next.ServeHTTP(w, r)
				return
			}

			userID, err := tokens.Parse(parts[1], time.Now().UTC())
			if err != nil {
				next.ServeHTTP(w, r)
				return
			}

			if _, err := store.Queries().GetUserByID(r.Context(), userID); err != nil {
				next.ServeHTTP(w, r)
				return
			}

			ctx := auth.ContextWithUserID(r.Context(), userID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func AuthAllowDeleted(tokens *auth.AccessTokenManager, store *repository.Store) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			requestID := RequestIDFromContext(r.Context())
			h := r.Header.Get("Authorization")
			if h == "" {
				httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "missing authorization header", requestID)
				return
			}

			parts := strings.SplitN(h, " ", 2)
			if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" || strings.TrimSpace(parts[1]) == "" {
				httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "invalid authorization header", requestID)
				return
			}

			userID, err := tokens.Parse(parts[1], time.Now().UTC())
			if err != nil {
				httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "invalid access token", requestID)
				return
			}

			if _, err := store.Queries().GetUserByIDAllowDeleted(r.Context(), userID); err != nil {
				if errors.Is(err, pgx.ErrNoRows) {
					httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "invalid access token", requestID)
					return
				}
				httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
				return
			}

			ctx := auth.ContextWithUserID(r.Context(), userID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}
