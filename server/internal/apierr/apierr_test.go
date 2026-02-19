package apierr

import (
	"errors"
	"fmt"
	"testing"
)

func TestErrorString(t *testing.T) {
	e := New(400, "validation", "bad request")
	if e.Error() != "bad request" {
		t.Fatalf("got %q, want %q", e.Error(), "bad request")
	}
}

func TestAs(t *testing.T) {
	e := New(401, "unauthorized", "unauthorized")
	wrapped := fmt.Errorf("wrap: %w", e)

	got, ok := As(wrapped)
	if !ok {
		t.Fatalf("expected ok")
	}
	if got.Status != 401 {
		t.Fatalf("status: got %d, want 401", got.Status)
	}
	if got.Code != "unauthorized" {
		t.Fatalf("code: got %q, want %q", got.Code, "unauthorized")
	}

	if _, ok := As(errors.New("nope")); ok {
		t.Fatalf("expected not ok")
	}
}
