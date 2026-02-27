package handler

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
)

type readyMockPinger struct{ err error }

func (m readyMockPinger) Ping(_ context.Context) error { return m.err }

func TestReadyCheck(t *testing.T) {
	errDown := errors.New("connection refused")

	tests := []struct {
		name       string
		dbErr      error
		cacheErr   error
		wantCode   int
		wantStatus string
		wantPG     string
		wantRedis  string
	}{
		{
			name:       "all healthy",
			wantCode:   http.StatusOK,
			wantStatus: "ok",
			wantPG:     "connected",
			wantRedis:  "connected",
		},
		{
			name:       "postgres down",
			dbErr:      errDown,
			wantCode:   http.StatusServiceUnavailable,
			wantStatus: "degraded",
			wantPG:     "disconnected",
			wantRedis:  "connected",
		},
		{
			name:       "redis down",
			cacheErr:   errDown,
			wantCode:   http.StatusServiceUnavailable,
			wantStatus: "degraded",
			wantPG:     "connected",
			wantRedis:  "disconnected",
		},
		{
			name:       "both down",
			dbErr:      errDown,
			cacheErr:   errDown,
			wantCode:   http.StatusServiceUnavailable,
			wantStatus: "degraded",
			wantPG:     "disconnected",
			wantRedis:  "disconnected",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			h := NewReadyHandler(readyMockPinger{tt.dbErr}, readyMockPinger{tt.cacheErr})
			h.tick(context.Background())

			req := httptest.NewRequest(http.MethodGet, "/ready", nil)
			rec := httptest.NewRecorder()

			h.Check(rec, req)

			if rec.Code != tt.wantCode {
				t.Fatalf("status code: got %d, want %d", rec.Code, tt.wantCode)
			}

			var resp healthResponse
			if err := json.NewDecoder(rec.Body).Decode(&resp); err != nil {
				t.Fatalf("decode response: %v", err)
			}

			if resp.Status != tt.wantStatus {
				t.Errorf("status: got %q, want %q", resp.Status, tt.wantStatus)
			}
			if resp.Postgres != tt.wantPG {
				t.Errorf("postgres: got %q, want %q", resp.Postgres, tt.wantPG)
			}
			if resp.Redis != tt.wantRedis {
				t.Errorf("redis: got %q, want %q", resp.Redis, tt.wantRedis)
			}

			if ct := rec.Header().Get("Content-Type"); ct != "application/json" {
				t.Errorf("content-type: got %q, want application/json", ct)
			}
		})
	}
}
