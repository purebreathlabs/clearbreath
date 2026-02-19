package stats

import (
	"testing"

	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/repository"
)

func TestNewServiceValidation(t *testing.T) {
	clk := clock.RealClock{}
	store := &repository.Store{}

	if _, err := NewService(nil, clk); err == nil {
		t.Fatalf("expected error")
	}
	if _, err := NewService(store, nil); err == nil {
		t.Fatalf("expected error")
	}
	if _, err := NewService(store, clk); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}
