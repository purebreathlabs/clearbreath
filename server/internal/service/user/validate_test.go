package user

import "testing"

func TestCanonicalizeUsername(t *testing.T) {
	tests := []struct {
		name    string
		in      string
		want    string
		wantErr bool
	}{
		{name: "trim and lowercase", in: "  Bob  ", want: "bob"},
		{name: "underscores allowed", in: "a_b_c", want: "a_b_c"},
		{name: "too short", in: "Hi", wantErr: true},
		{name: "too long", in: "thisnameiswaytoolongfortheruless", wantErr: true},
		{name: "invalid char space", in: "A B", wantErr: true},
		{name: "empty", in: "   ", wantErr: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := CanonicalizeUsername(tt.in)
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
