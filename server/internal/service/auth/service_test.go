package auth

import (
	"testing"
	"time"
)

func TestAgeBandFromBirthYear(t *testing.T) {
	now := time.Date(2026, 2, 16, 0, 0, 0, 0, time.UTC)

	tests := []struct {
		name      string
		birthYear int
		wantBand  string
		wantErr   bool
	}{
		{name: "missing", birthYear: 0, wantErr: true},
		{name: "too old", birthYear: 1800, wantErr: true},
		{name: "future", birthYear: 3000, wantErr: true},
		{name: "under 13", birthYear: 2015, wantBand: "u13"},
		{name: "teen", birthYear: 2010, wantBand: "13_17"},
		{name: "adult", birthYear: 2000, wantBand: "18_plus"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := ageBandFromBirthYear(tt.birthYear, now)
			if tt.wantErr {
				if err == nil {
					t.Fatalf("expected error, got nil")
				}
				return
			}

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if got != tt.wantBand {
				t.Fatalf("band: got %q, want %q", got, tt.wantBand)
			}
		})
	}
}
