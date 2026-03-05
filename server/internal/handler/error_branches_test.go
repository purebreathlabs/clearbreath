package handler

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
	sessionsvc "github.com/clearbreath/server/internal/service/session"
)

type httpError struct {
	Error string `json:"error"`
	Code  string `json:"code"`
}

func TestHandlersReturnUnauthorizedWithoutUserID(t *testing.T) {
	tests := []struct {
		name string
		run  func(rec *httptest.ResponseRecorder, req *http.Request)
	}{
		{name: "me get", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewMeHandler(nil).Get(rec, req) }},
		{name: "me patch", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewMeHandler(nil).Patch(rec, req) }},
		{name: "me delete", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewMeHandler(nil).Delete(rec, req) }},
		{name: "safety acks get", run: func(rec *httptest.ResponseRecorder, req *http.Request) {
			NewSafetyAcknowledgementsHandler(nil).Get(rec, req)
		}},
		{name: "safety acks post", run: func(rec *httptest.ResponseRecorder, req *http.Request) {
			NewSafetyAcknowledgementsHandler(nil).Post(rec, req)
		}},
		{name: "stats snapshot", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewStatsHandler(nil, nil).Snapshot(rec, req) }},
		{name: "stats weekly", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewStatsHandler(nil, nil).Weekly(rec, req) }},
		{name: "leaderboard self", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewLeaderboardHandler(nil).Self(rec, req) }},
		{name: "auth logout", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewAuthHandler(nil).Logout(rec, req) }},
		{name: "sessions submit", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewSessionsHandler(nil).Submit(rec, req) }},
		{name: "sessions sync", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewSessionsHandler(nil).Sync(rec, req) }},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(http.MethodGet, "/", nil)
			rec := httptest.NewRecorder()
			tt.run(rec, req)

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
		})
	}
}

func TestHandlersReturnBadRequestOnInvalidJSON(t *testing.T) {
	userID := uuid.MustParse("3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11")
	ctx := auth.ContextWithUserID(contextBackground{}, userID)

	tests := []struct {
		name string
		run  func(rec *httptest.ResponseRecorder, req *http.Request)
	}{
		{name: "me patch", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewMeHandler(nil).Patch(rec, req) }},
		{name: "auth provider sign in", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewAuthHandler(nil).ProviderSignIn(rec, req) }},
		{name: "auth refresh", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewAuthHandler(nil).Refresh(rec, req) }},
		{name: "auth logout", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewAuthHandler(nil).Logout(rec, req) }},
		{name: "safety acks post", run: func(rec *httptest.ResponseRecorder, req *http.Request) {
			NewSafetyAcknowledgementsHandler(nil).Post(rec, req)
		}},
		{name: "sessions submit", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewSessionsHandler(nil).Submit(rec, req) }},
		{name: "sessions sync", run: func(rec *httptest.ResponseRecorder, req *http.Request) { NewSessionsHandler(nil).Sync(rec, req) }},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString("{"))
			req.Header.Set("Content-Type", "application/json")
			req = req.WithContext(ctx)
			rec := httptest.NewRecorder()

			tt.run(rec, req)

			if rec.Code != http.StatusBadRequest {
				t.Fatalf("status: got %d, want %d", rec.Code, http.StatusBadRequest)
			}
			var e httpError
			if err := json.NewDecoder(rec.Body).Decode(&e); err != nil {
				t.Fatalf("decode: %v", err)
			}
			if e.Code != "validation" {
				t.Fatalf("code: got %q, want %q", e.Code, "validation")
			}
		})
	}
}

type contextBackground struct{}

func (contextBackground) Deadline() (time.Time, bool) { return time.Time{}, false }
func (contextBackground) Done() <-chan struct{}       { return nil }
func (contextBackground) Err() error                  { return nil }
func (contextBackground) Value(key any) any           { return nil }

func TestToStatsSnapshotResponseInvalidJSON(t *testing.T) {
	_, err := toStatsSnapshotResponse(sqlcgen.StatsSnapshot{
		CurrentStreakDays:  1,
		LongestStreakDays:  2,
		MinutesThisWeek:    3,
		MinutesAllTime:     4,
		SessionsAllTime:    5,
		MinutesByTechnique: []byte("{"),
		UpdatedAt:          time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC),
	}, nil)
	if err == nil {
		t.Fatalf("expected error")
	}
}

func TestToStatsSnapshotResponseNullMapDefaultsEmpty(t *testing.T) {
	resp, err := toStatsSnapshotResponse(sqlcgen.StatsSnapshot{
		CurrentStreakDays:  1,
		LongestStreakDays:  2,
		MinutesThisWeek:    3,
		MinutesAllTime:     4,
		SessionsAllTime:    5,
		MinutesByTechnique: []byte("null"),
		UpdatedAt:          time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC),
	}, nil)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp.MinutesByTechnique == nil {
		t.Fatalf("expected non-nil map")
	}
	if len(resp.MinutesByTechnique) != 0 {
		t.Fatalf("expected empty map")
	}
}

func TestToIngestSessionsResponsePropagatesSnapshotError(t *testing.T) {
	_, err := toIngestSessionsResponse(sessionsvc.IngestResult{
		StatsSnapshot: sqlcgen.StatsSnapshot{
			MinutesByTechnique: []byte("{"),
			UpdatedAt:          time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC),
		},
	})
	if err == nil {
		t.Fatalf("expected error")
	}
}

func TestStatsHandlerWeeklyRejectsInvalidWeekOffset(t *testing.T) {
	userID := uuid.MustParse("3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11")
	req := httptest.NewRequest(http.MethodGet, "/v1/stats/weekly?week_offset=1", nil)
	req = req.WithContext(auth.ContextWithUserID(contextBackground{}, userID))
	rec := httptest.NewRecorder()

	NewStatsHandler(nil, nil).Weekly(rec, req)

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status: got %d, want %d", rec.Code, http.StatusBadRequest)
	}
	var e httpError
	if err := json.NewDecoder(rec.Body).Decode(&e); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if e.Code != "validation" {
		t.Fatalf("code: got %q, want %q", e.Code, "validation")
	}
}
