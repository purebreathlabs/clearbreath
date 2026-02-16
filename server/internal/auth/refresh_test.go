package auth

import "testing"

func TestRefreshTokenHashDeterministic(t *testing.T) {
	h1 := HashRefreshToken("secretsecretsecretsecretsecretsecretse", "token")
	h2 := HashRefreshToken("secretsecretsecretsecretsecretsecretse", "token")
	if string(h1) != string(h2) {
		t.Fatalf("hash mismatch")
	}
}

func TestNewRefreshTokenNotEmpty(t *testing.T) {
	tok, err := NewRefreshToken()
	if err != nil {
		t.Fatalf("new refresh token: %v", err)
	}
	if tok == "" {
		t.Fatalf("token empty")
	}
}
