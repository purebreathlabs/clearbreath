package profanity

import "testing"

func TestFilterHasProfanity(t *testing.T) {
	f := NewDefault()

	tests := []struct {
		name string
		in   string
		want bool
	}{
		{name: "clean", in: "Breather123", want: false},
		{name: "simple", in: "fuck", want: true},
		{name: "spaced", in: "f u c k", want: true},
		{name: "leetspeak", in: "sh1t", want: true},
		{name: "mixed", in: "HelloShitWorld", want: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := f.HasProfanity(tt.in); got != tt.want {
				t.Fatalf("got %v, want %v", got, tt.want)
			}
		})
	}
}
