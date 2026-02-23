package user

import (
	"strings"
	"testing"

	"github.com/clearbreath/server/internal/profanity"
	"github.com/clearbreath/server/internal/repository"
)

func TestNewServiceValidation(t *testing.T) {
	filter := profanity.NewDefault()
	store := &repository.Store{}

	if _, err := NewService(nil, filter); err == nil {
		t.Fatalf("expected error")
	}
	if _, err := NewService(store, nil); err == nil {
		t.Fatalf("expected error")
	}
	if _, err := NewService(store, filter); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestCanonicalizeDisplayNameAdditional(t *testing.T) {
	tests := []struct {
		name    string
		in      string
		want    string
		wantErr string
	}{
		{name: "trim and collapse spaces", in: "  A   B  ", want: "A B"},
		{name: "invalid characters", in: "Al!ce", wantErr: "display_name has invalid characters"},
		{name: "required", in: "   ", wantErr: "display_name is required"},
		{name: "too short", in: "Al", wantErr: "display_name must be 3-20 characters"},
		{name: "too long", in: strings.Repeat("a", 21), wantErr: "display_name must be 3-20 characters"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := CanonicalizeDisplayName(tt.in)
			if tt.wantErr != "" {
				if err == nil {
					t.Fatalf("expected error")
				}
				if err.Error() != tt.wantErr {
					t.Fatalf("error: got %q, want %q", err.Error(), tt.wantErr)
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if got != tt.want {
				t.Fatalf("got %q, want %q", got, tt.want)
			}
		})
	}
}
