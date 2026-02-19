package httpx

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestDecodeJSONEmptyBody(t *testing.T) {
	var dst struct {
		Name string `json:"name"`
	}

	req := httptest.NewRequest(http.MethodPost, "/", nil)
	rec := httptest.NewRecorder()

	err := DecodeJSON(rec, req, 1024, &dst)
	if err == nil {
		t.Fatalf("expected error")
	}
	if !strings.Contains(err.Error(), "empty body") {
		t.Fatalf("error: got %q, want contains %q", err.Error(), "empty body")
	}
}

func TestDecodeJSONDisallowsUnknownFields(t *testing.T) {
	var dst struct {
		Name string `json:"name"`
	}

	req := httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString(`{"name":"x","extra":1}`))
	rec := httptest.NewRecorder()

	err := DecodeJSON(rec, req, 1024, &dst)
	if err == nil {
		t.Fatalf("expected error")
	}
}

func TestDecodeJSONRejectsTrailingData(t *testing.T) {
	var dst struct {
		Name string `json:"name"`
	}

	req := httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString(`{"name":"x"} {"name":"y"}`))
	rec := httptest.NewRecorder()

	err := DecodeJSON(rec, req, 1024, &dst)
	if err == nil {
		t.Fatalf("expected error")
	}
	if err.Error() != "unexpected trailing data" {
		t.Fatalf("error: got %q, want %q", err.Error(), "unexpected trailing data")
	}
}

func TestDecodeJSONEnforcesMaxBytes(t *testing.T) {
	var dst struct {
		Name string `json:"name"`
	}

	req := httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString(`{"name":"this is long"}`))
	rec := httptest.NewRecorder()

	err := DecodeJSON(rec, req, 5, &dst)
	if err == nil {
		t.Fatalf("expected error")
	}
}
