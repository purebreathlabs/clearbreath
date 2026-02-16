package leaderboard

import "testing"

func TestInitials(t *testing.T) {
	tests := []struct {
		name string
		in   string
		want string
	}{
		{name: "empty", in: "", want: "U"},
		{name: "single", in: "Alice", want: "A"},
		{name: "two words", in: "Alice Bob", want: "AB"},
		{name: "spaces", in: "  Alice   Bob  ", want: "AB"},
		{name: "numbers", in: "User 123", want: "U1"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := initials(tt.in); got != tt.want {
				t.Fatalf("got %q, want %q", got, tt.want)
			}
		})
	}
}
