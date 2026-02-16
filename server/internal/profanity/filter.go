package profanity

import (
	"strings"
	"unicode"
)

type Filter struct {
	words []string
}

func NewDefault() *Filter {
	return &Filter{
		words: defaultWords(),
	}
}

func (f *Filter) HasProfanity(s string) bool {
	n := normalize(s)
	if n == "" {
		return false
	}
	for _, w := range f.words {
		if strings.Contains(n, w) {
			return true
		}
	}
	return false
}

func normalize(s string) string {
	var b strings.Builder
	b.Grow(len(s))

	for _, r := range strings.ToLower(s) {
		switch r {
		case '0':
			r = 'o'
		case '1':
			r = 'i'
		case '3':
			r = 'e'
		case '4':
			r = 'a'
		case '5':
			r = 's'
		case '7':
			r = 't'
		case '@':
			r = 'a'
		}

		if unicode.IsLetter(r) || unicode.IsNumber(r) {
			b.WriteRune(r)
		}
	}

	return b.String()
}

func defaultWords() []string {
	return []string{
		"fuck",
		"shit",
		"bitch",
		"asshole",
		"cunt",
		"dick",
		"pussy",
		"faggot",
		"nigger",
		"slut",
		"whore",
	}
}
