package auth

import (
	"testing"
	"time"

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
