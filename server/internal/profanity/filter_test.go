package profanity

import "testing"

func TestNormalize(t *testing.T) {
	tests := []struct {
		name string
		in   string
		want string
	}{
		{name: "lowercase and strip punctuation", in: "HeLlo, World!", want: "helloworld"},
		{name: "leet speak", in: "5h1t", want: "shit"},
		{name: "leet mapping coverage", in: "013457@", want: "oieasta"},
		{name: "at sign", in: "@ss", want: "ass"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := normalize(tt.in); got != tt.want {
				t.Fatalf("got %q, want %q", got, tt.want)
			}
		})
	}
}

func TestHasProfanity(t *testing.T) {
	f := NewDefault()

	tests := []struct {
		name string
		in   string
		want bool
	}{
		{name: "empty after normalize", in: "!!!", want: false},
		{name: "clean", in: "hello", want: false},
		{name: "direct profanity", in: "fuck", want: true},
		{name: "leet profanity", in: "5h1t", want: true},
		{name: "embedded profanity", in: "xxb1tchyy", want: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := f.HasProfanity(tt.in); got != tt.want {
				t.Fatalf("got %v, want %v", got, tt.want)
			}
		})
	}
}
