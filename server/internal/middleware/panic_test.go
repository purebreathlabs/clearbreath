package middleware

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

type panicHTTPError struct {
	Error     string `json:"error"`
	Code      string `json:"code"`
	RequestID string `json:"request_id,omitempty"`
}

func TestPanicRecoveryRecoversAndWritesInternalError(t *testing.T) {
	next := http.HandlerFunc(func(http.ResponseWriter, *http.Request) {
		panic("boom")
	})

	h := PanicRecovery(next)
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	req = req.WithContext(context.WithValue(req.Context(), requestIDKey, "req1"))
	rec := httptest.NewRecorder()

	h.ServeHTTP(rec, req)

	if rec.Code != http.StatusInternalServerError {
		t.Fatalf("status: got %d, want %d", rec.Code, http.StatusInternalServerError)
	}

	var e panicHTTPError
	if err := json.NewDecoder(rec.Body).Decode(&e); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if e.Code != "internal" {
		t.Fatalf("code: got %q, want %q", e.Code, "internal")
	}
	if e.Error != "internal server error" {
		t.Fatalf("error: got %q, want %q", e.Error, "internal server error")
	}
	if e.RequestID != "req1" {
		t.Fatalf("request id: got %q, want %q", e.RequestID, "req1")
	}
}

func TestPanicRecoveryPassesThroughOnNoPanic(t *testing.T) {
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})

	h := PanicRecovery(next)
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	req = req.WithContext(context.WithValue(req.Context(), requestIDKey, "req1"))
	rec := httptest.NewRecorder()

	h.ServeHTTP(rec, req)

	if rec.Code != http.StatusNoContent {
		t.Fatalf("status: got %d, want %d", rec.Code, http.StatusNoContent)
	}
	if rec.Body.Len() != 0 {
		t.Fatalf("expected empty body, got %q", rec.Body.String())
	}
}
