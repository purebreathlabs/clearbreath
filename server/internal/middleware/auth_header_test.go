package middleware

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	internalauth "github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/repository"
)

type httpError struct {
	Error string `json:"error"`
	Code  string `json:"code"`
}

func TestAuthMiddlewareRejectsMissingOrInvalidAuthorizationHeader(t *testing.T) {
	mws := []struct {
		name string
		wrap func(*internalauth.AccessTokenManager, *repository.Store) func(http.Handler) http.Handler
	}{
		{name: "auth", wrap: Auth},
		{name: "auth allow deleted", wrap: AuthAllowDeleted},
	}

	tests := []struct {
		name    string
		header  string
		wantMsg string
	}{
		{name: "missing header", header: "", wantMsg: "missing authorization header"},
		{name: "invalid header", header: "nope", wantMsg: "invalid authorization header"},
		{name: "invalid bearer", header: "Bearer ", wantMsg: "invalid authorization header"},
	}

	for _, mw := range mws {
		for _, tt := range tests {
			t.Run(mw.name+" "+tt.name, func(t *testing.T) {
				called := false
				next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
					called = true
					w.WriteHeader(http.StatusOK)
				})

				h := mw.wrap(nil, nil)(next)
				req := httptest.NewRequest(http.MethodGet, "/", nil)
				if tt.header != "" {
					req.Header.Set("Authorization", tt.header)
				}
				rec := httptest.NewRecorder()
				h.ServeHTTP(rec, req)

				if called {
					t.Fatalf("expected handler not called")
				}
				if rec.Code != http.StatusUnauthorized {
					t.Fatalf("status: got %d, want %d", rec.Code, http.StatusUnauthorized)
				}

				var e httpError
				if err := json.NewDecoder(rec.Body).Decode(&e); err != nil {
					t.Fatalf("decode: %v", err)
				}
				if e.Code != "unauthorized" {
					t.Fatalf("code: got %q, want %q", e.Code, "unauthorized")
				}
				if e.Error != tt.wantMsg {
					t.Fatalf("error: got %q, want %q", e.Error, tt.wantMsg)
				}
			})
		}
	}
}

func TestAuthMiddlewareRejectsInvalidAccessToken(t *testing.T) {
	tokens, err := internalauth.NewAccessTokenManager("dev_access_secret_change_me_01234567890123456789012", 15)
	if err != nil {
		t.Fatalf("access token manager: %v", err)
	}

	mws := []struct {
		name string
		wrap func(*internalauth.AccessTokenManager, *repository.Store) func(http.Handler) http.Handler
	}{
		{name: "auth", wrap: Auth},
		{name: "auth allow deleted", wrap: AuthAllowDeleted},
	}

	for _, mw := range mws {
		t.Run(mw.name, func(t *testing.T) {
			called := false
			next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				called = true
				w.WriteHeader(http.StatusOK)
			})

			h := mw.wrap(tokens, nil)(next)
			req := httptest.NewRequest(http.MethodGet, "/", nil)
			req.Header.Set("Authorization", "Bearer not-a-jwt")
			rec := httptest.NewRecorder()
			h.ServeHTTP(rec, req)

			if called {
				t.Fatalf("expected handler not called")
			}
			if rec.Code != http.StatusUnauthorized {
				t.Fatalf("status: got %d, want %d", rec.Code, http.StatusUnauthorized)
			}

			var e httpError
			if err := json.NewDecoder(rec.Body).Decode(&e); err != nil {
				t.Fatalf("decode: %v", err)
			}
			if e.Code != "unauthorized" {
				t.Fatalf("code: got %q, want %q", e.Code, "unauthorized")
			}
			if e.Error != "invalid access token" {
				t.Fatalf("error: got %q, want %q", e.Error, "invalid access token")
			}
		})
	}
}
