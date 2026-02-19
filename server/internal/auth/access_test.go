package auth

import (
	"strings"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

func TestAccessTokenIssueAndParse(t *testing.T) {
	m, err := NewAccessTokenManager("0123456789abcdef0123456789abcdef", 15)
	if err != nil {
		t.Fatalf("new manager: %v", err)
	}

	now := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	userID := uuid.New()

	token, exp, err := m.Issue(userID, now)
	if err != nil {
		t.Fatalf("issue: %v", err)
	}
	if token == "" {
		t.Fatalf("token empty")
	}
	if !exp.Equal(now.Add(15 * time.Minute)) {
		t.Fatalf("exp: got %v, want %v", exp, now.Add(15*time.Minute))
	}

	gotID, err := m.Parse(token, now.Add(1*time.Minute))
	if err != nil {
		t.Fatalf("parse: %v", err)
	}
	if gotID != userID {
		t.Fatalf("user id: got %v, want %v", gotID, userID)
	}
}

func TestAccessTokenRejectsExpired(t *testing.T) {
	m, err := NewAccessTokenManager("0123456789abcdef0123456789abcdef", 1)
	if err != nil {
		t.Fatalf("new manager: %v", err)
	}

	now := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	userID := uuid.New()

	token, _, err := m.Issue(userID, now)
	if err != nil {
		t.Fatalf("issue: %v", err)
	}

	if _, err := m.Parse(token, now.Add(2*time.Minute)); err == nil {
		t.Fatalf("expected error, got nil")
	}
}

func TestAccessTokenRejectsWrongSecret(t *testing.T) {
	m1, err := NewAccessTokenManager("0123456789abcdef0123456789abcdef", 15)
	if err != nil {
		t.Fatalf("new manager: %v", err)
	}
	m2, err := NewAccessTokenManager("fedcba9876543210fedcba9876543210", 15)
	if err != nil {
		t.Fatalf("new manager: %v", err)
	}

	now := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	userID := uuid.New()
	token, _, err := m1.Issue(userID, now)
	if err != nil {
		t.Fatalf("issue: %v", err)
	}

	if _, err := m2.Parse(token, now.Add(1*time.Minute)); err == nil {
		t.Fatalf("expected error, got nil")
	}
}

func TestNewAccessTokenManagerValidation(t *testing.T) {
	if _, err := NewAccessTokenManager("short", 15); err == nil {
		t.Fatalf("expected error")
	}
	if _, err := NewAccessTokenManager("0123456789abcdef0123456789abcdef", 0); err == nil {
		t.Fatalf("expected error")
	}
}

func TestAccessTokenRejectsInvalidSubject(t *testing.T) {
	m, err := NewAccessTokenManager("0123456789abcdef0123456789abcdef", 15)
	if err != nil {
		t.Fatalf("new manager: %v", err)
	}

	now := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	claims := accessClaims{
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   "not-a-uuid",
			IssuedAt:  jwt.NewNumericDate(now.UTC()),
			ExpiresAt: jwt.NewNumericDate(now.Add(15 * time.Minute).UTC()),
		},
	}

	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	raw, err := tok.SignedString(m.secret)
	if err != nil {
		t.Fatalf("sign: %v", err)
	}

	_, err = m.Parse(raw, now.Add(1*time.Minute))
	if err == nil {
		t.Fatalf("expected error")
	}
	if !strings.Contains(err.Error(), "parse subject") {
		t.Fatalf("error: got %q", err.Error())
	}
}
