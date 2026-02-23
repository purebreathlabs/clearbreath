package user

import "testing"

func TestCanonicalizeDisplayName(t *testing.T) {
	tests := []struct {
		name    string
		in      string
		want    string
		wantErr bool
	}{
		{name: "trim", in: "  Bob  ", want: "Bob"},
		{name: "collapse spaces", in: "A   B   C", want: "A B C"},
		{name: "too short", in: "Hi", wantErr: true},
		{name: "too long", in: "ThisNameIsWayTooLongForTheRule", wantErr: true},
		{name: "invalid char", in: "Bob_", wantErr: true},
		{name: "empty", in: "   ", wantErr: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := CanonicalizeDisplayName(tt.in)
			if tt.wantErr {
				if err == nil {
					t.Fatalf("expected error, got nil")
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
