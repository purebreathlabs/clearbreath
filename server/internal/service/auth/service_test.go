package auth

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/clearbreath/server/internal/apierr"
	internalauth "github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/profanity"
	"github.com/clearbreath/server/internal/repository"
)

type fixedClock struct{ t time.Time }

func (c fixedClock) Now() time.Time { return c.t }

func TestNewServiceValidation(t *testing.T) {
	now := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	clk := fixedClock{t: now}
	store := &repository.Store{}
	accessTokens, err := internalauth.NewAccessTokenManager(strings.Repeat("a", 32), 15)
	if err != nil {
		t.Fatalf("access token manager: %v", err)
	}

	tests := []struct {
		name          string
		store         *repository.Store
		clock         fixedClock
		accessTokens  *internalauth.AccessTokenManager
		refreshSecret string
		refreshTTLMin int
		want          string
	}{
		{name: "missing store", store: nil, clock: clk, accessTokens: accessTokens, refreshSecret: strings.Repeat("b", 32), refreshTTLMin: 60, want: "store is required"},
		{name: "missing clock", store: store, clock: fixedClock{}, accessTokens: accessTokens, refreshSecret: strings.Repeat("b", 32), refreshTTLMin: 60, want: "clock is required"},
		{name: "missing access tokens", store: store, clock: clk, accessTokens: nil, refreshSecret: strings.Repeat("b", 32), refreshTTLMin: 60, want: "access token manager is required"},
		{name: "short refresh secret", store: store, clock: clk, accessTokens: accessTokens, refreshSecret: "short", refreshTTLMin: 60, want: "refresh token secret must be at least 32 chars"},
		{name: "non-positive refresh ttl", store: store, clock: clk, accessTokens: accessTokens, refreshSecret: strings.Repeat("b", 32), refreshTTLMin: 0, want: "refresh token ttl must be positive"},
		{name: "nil profanity filter", store: store, clock: clk, accessTokens: accessTokens, refreshSecret: strings.Repeat("b", 32), refreshTTLMin: 60, want: "profanity filter is required"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var clk clock.Clock
			if tt.want != "clock is required" {
				clk = tt.clock
			}

			var f *profanity.Filter
			if tt.want != "profanity filter is required" {
				f = profanity.NewDefault()
			}

			_, err := NewService(tt.store, clk, tt.accessTokens, tt.refreshSecret, tt.refreshTTLMin, false, "", "", "", f)
			if err == nil {
				t.Fatalf("expected error")
			}
			if !strings.Contains(err.Error(), tt.want) {
				t.Fatalf("error: got %q, want contains %q", err.Error(), tt.want)
			}
		})
	}
}

func TestVerifyProviderDev(t *testing.T) {
	s := &Service{
		devAuthEnabled: true,
		devAuthSecret:  "secret",
	}

	tests := []struct {
		name     string
		provider string
		idToken  string
		deviceID string
		header   string
		wantSub  string
		wantCode string
		wantMsg  string
		wantHTTP int
	}{
		{name: "valid uses id_token", provider: "dev", idToken: "user1", deviceID: "device1", header: "secret", wantSub: "user1"},
		{name: "valid falls back to device id", provider: "dev", idToken: "", deviceID: "device1", header: "secret", wantSub: "device1"},
		{name: "invalid secret", provider: "dev", idToken: "user1", deviceID: "device1", header: "nope", wantCode: "unauthorized", wantMsg: "invalid dev auth secret", wantHTTP: http.StatusUnauthorized},
		{name: "missing subject", provider: "dev", idToken: "", deviceID: "", header: "secret", wantCode: "validation", wantMsg: "id_token is required for dev auth", wantHTTP: http.StatusBadRequest},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			sub, _, err := s.verifyProvider(context.Background(), tt.provider, tt.idToken, tt.deviceID, tt.header)
			if tt.wantCode == "" {
				if err != nil {
					t.Fatalf("unexpected error: %v", err)
				}
				if sub != tt.wantSub {
					t.Fatalf("sub: got %q, want %q", sub, tt.wantSub)
				}
				return
			}

			if err == nil {
				t.Fatalf("expected error")
			}
			e, ok := apierr.As(err)
			if !ok {
				t.Fatalf("expected apierr, got %T", err)
			}
			if e.Status != tt.wantHTTP {
				t.Fatalf("status: got %d, want %d", e.Status, tt.wantHTTP)
			}
			if e.Code != tt.wantCode {
				t.Fatalf("code: got %q, want %q", e.Code, tt.wantCode)
			}
			if e.Message != tt.wantMsg {
				t.Fatalf("message: got %q, want %q", e.Message, tt.wantMsg)
			}
		})
	}
}

func TestVerifyProviderDevDisabled(t *testing.T) {
	s := &Service{
		devAuthEnabled: false,
		devAuthSecret:  "secret",
	}

	_, _, err := s.verifyProvider(context.Background(), "dev", "user1", "device1", "secret")
	if err == nil {
		t.Fatalf("expected error")
	}
	e, ok := apierr.As(err)
	if !ok || e.Status != http.StatusUnauthorized || e.Message != "dev auth is disabled" {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestVerifyProviderNotConfigured(t *testing.T) {
	s := &Service{}

	_, _, err := s.verifyProvider(context.Background(), "google", "token", "device1", "")
	if err == nil {
		t.Fatalf("expected error")
	}
	e, ok := apierr.As(err)
	if !ok || e.Status != http.StatusInternalServerError || e.Code != "provider_not_configured" {
		t.Fatalf("unexpected error: %v", err)
	}

	_, _, err = s.verifyProvider(context.Background(), "apple", "token", "device1", "")
	if err == nil {
		t.Fatalf("expected error")
	}
	e, ok = apierr.As(err)
	if !ok || e.Status != http.StatusInternalServerError || e.Code != "provider_not_configured" {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestVerifyProviderUnsupportedProvider(t *testing.T) {
	s := &Service{}
	_, _, err := s.verifyProvider(context.Background(), "nope", "token", "device1", "")
	if err == nil {
		t.Fatalf("expected error")
	}
	e, ok := apierr.As(err)
	if !ok || e.Status != http.StatusBadRequest || e.Code != "validation" {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestGetGoogleAndAppleVerifierInitializedOnce(t *testing.T) {
	s := &Service{
		googleClientID: "google",
		appleAudience:  "apple",
	}

	g1 := s.getGoogleVerifier()
	if g1 == nil {
		t.Fatalf("expected google verifier")
	}
	if g1.issuer != "https://accounts.google.com" || g1.clientID != "google" {
		t.Fatalf("unexpected google verifier config")
	}

	a1 := s.getAppleVerifier()
	if a1 == nil {
		t.Fatalf("expected apple verifier")
	}
	if a1.issuer != "https://appleid.apple.com" || a1.clientID != "apple" {
		t.Fatalf("unexpected apple verifier config")
	}

	g2 := s.getGoogleVerifier()
	a2 := s.getAppleVerifier()

	if g1 != g2 {
		t.Fatalf("expected google verifier singleton")
	}
	if a1 != a2 {
		t.Fatalf("expected apple verifier singleton")
	}
}

func TestGetAppleVerifierInitializedOnce(t *testing.T) {
	s := &Service{
		googleClientID: "google",
		appleAudience:  "apple",
	}

	a1 := s.getAppleVerifier()
	if a1 == nil {
		t.Fatalf("expected apple verifier")
	}
	if a1.issuer != "https://appleid.apple.com" || a1.clientID != "apple" {
		t.Fatalf("unexpected apple verifier config")
	}

	g1 := s.getGoogleVerifier()
	if g1 == nil {
		t.Fatalf("expected google verifier")
	}
	if g1.issuer != "https://accounts.google.com" || g1.clientID != "google" {
		t.Fatalf("unexpected google verifier config")
	}

	a2 := s.getAppleVerifier()
	g2 := s.getGoogleVerifier()

	if a1 != a2 {
		t.Fatalf("expected apple verifier singleton")
	}
	if g1 != g2 {
		t.Fatalf("expected google verifier singleton")
	}
}

func TestProviderSignInValidation(t *testing.T) {
	now := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	s := &Service{
		clock: fixedClock{t: now},
	}

	tests := []struct {
		name   string
		in     ProviderSignInInput
		status int
		code   string
		msg    string
	}{
		{name: "missing provider", in: ProviderSignInInput{Provider: "", DeviceID: "d"}, status: http.StatusBadRequest, code: "validation", msg: "provider is required"},
		{name: "missing device id", in: ProviderSignInInput{Provider: "dev", DeviceID: ""}, status: http.StatusBadRequest, code: "validation", msg: "device_id is required"},
		{name: "device id too long", in: ProviderSignInInput{Provider: "dev", DeviceID: strings.Repeat("d", 201)}, status: http.StatusBadRequest, code: "validation", msg: "device_id is too long"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := s.ProviderSignIn(context.Background(), tt.in)
			if err == nil {
				t.Fatalf("expected error")
			}

			e, ok := apierr.As(err)
			if !ok {
				t.Fatalf("expected apierr, got %T", err)
			}
			if e.Status != tt.status {
				t.Fatalf("status: got %d, want %d", e.Status, tt.status)
			}
			if e.Code != tt.code {
				t.Fatalf("code: got %q, want %q", e.Code, tt.code)
			}
			if e.Message != tt.msg {
				t.Fatalf("message: got %q, want %q", e.Message, tt.msg)
			}
		})
	}
}

func TestRefreshValidation(t *testing.T) {
	s := &Service{}

	tests := []struct {
		name   string
		in     RefreshInput
		status int
		code   string
		msg    string
	}{
		{name: "missing refresh token", in: RefreshInput{RefreshToken: "", DeviceID: "d"}, status: http.StatusBadRequest, code: "validation", msg: "refresh_token is required"},
		{name: "missing device id", in: RefreshInput{RefreshToken: "t", DeviceID: ""}, status: http.StatusBadRequest, code: "validation", msg: "device_id is required"},
		{name: "device id too long", in: RefreshInput{RefreshToken: "t", DeviceID: strings.Repeat("d", 201)}, status: http.StatusBadRequest, code: "validation", msg: "device_id is too long"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := s.Refresh(context.Background(), tt.in)
			if err == nil {
				t.Fatalf("expected error")
			}

			e, ok := apierr.As(err)
			if !ok {
				t.Fatalf("expected apierr, got %T", err)
			}
			if e.Status != tt.status {
				t.Fatalf("status: got %d, want %d", e.Status, tt.status)
			}
			if e.Code != tt.code {
				t.Fatalf("code: got %q, want %q", e.Code, tt.code)
			}
			if e.Message != tt.msg {
				t.Fatalf("message: got %q, want %q", e.Message, tt.msg)
			}
		})
	}
}

func TestLogoutValidation(t *testing.T) {
	s := &Service{}

	tests := []struct {
		name   string
		device string
		status int
		code   string
		msg    string
	}{
		{name: "missing device id", device: "", status: http.StatusBadRequest, code: "validation", msg: "device_id is required"},
		{name: "device id too long", device: strings.Repeat("d", 201), status: http.StatusBadRequest, code: "validation", msg: "device_id is too long"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := s.Logout(context.Background(), uuid.MustParse("3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11"), tt.device)
			if err == nil {
				t.Fatalf("expected error")
			}

			e, ok := apierr.As(err)
			if !ok {
				t.Fatalf("expected apierr, got %T", err)
			}
			if e.Status != tt.status {
				t.Fatalf("status: got %d, want %d", e.Status, tt.status)
			}
			if e.Code != tt.code {
				t.Fatalf("code: got %q, want %q", e.Code, tt.code)
			}
			if e.Message != tt.msg {
				t.Fatalf("message: got %q, want %q", e.Message, tt.msg)
			}
		})
	}
}

func TestIsUniqueViolation(t *testing.T) {
	if !isUniqueViolation(&pgconn.PgError{Code: "23505"}) {
		t.Fatalf("expected true")
	}
	if isUniqueViolation(&pgconn.PgError{Code: "99999"}) {
		t.Fatalf("expected false")
	}
	if isUniqueViolation(errors.New("nope")) {
		t.Fatalf("expected false")
	}
}

func TestIsAutoGeneratedUsername(t *testing.T) {
	tests := []struct {
		name string
		in   string
		want bool
	}{
		{name: "valid auto username", in: "breather123456", want: true},
		{name: "valid all zeros", in: "breather000000", want: true},
		{name: "too short", in: "breather12345", want: false},
		{name: "custom name", in: "alice", want: false},
		{name: "too long", in: "breather1234567", want: false},
		{name: "empty", in: "", want: false},
		{name: "uppercase prefix rejected", in: "Breather123456", want: false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := isAutoGeneratedUsername(tt.in)
			if got != tt.want {
				t.Fatalf("isAutoGeneratedUsername(%q): got %v, want %v", tt.in, got, tt.want)
			}
		})
	}
}

func TestGenerateUsernameFromEmail(t *testing.T) {
	tests := []struct {
		name string
		in   string
		want string
	}{
		{name: "simple email", in: "alice@example.com", want: "alice"},
		{name: "dots stripped", in: "a.l.i.c.e@example.com", want: "alice"},
		{name: "hyphens stripped", in: "al-ice@example.com", want: "alice"},
		{name: "uppercase lowered", in: "Alice@example.com", want: "alice"},
		{name: "numbers kept", in: "alice42@example.com", want: "alice42"},
		{name: "underscores kept", in: "alice_b@example.com", want: "alice_b"},
		{name: "special chars removed", in: "al!ce+tag@example.com", want: "alcetag"},
		{name: "too short result", in: "ab@example.com", want: ""},
		{name: "empty string", in: "", want: ""},
		{name: "no at sign", in: "nope", want: ""},
		{name: "at start", in: "@example.com", want: ""},
		{name: "long local part truncated", in: "abcdefghijklmnopqrstuvwxyz@example.com", want: "abcdefghijklmnopqrst"},
		{name: "leading underscores trimmed", in: "__abc@example.com", want: "abc"},
		{name: "trailing underscores trimmed", in: "abc__@example.com", want: "abc"},
		{name: "whitespace trimmed", in: "  alice@example.com  ", want: "alice"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := generateUsernameFromEmail(tt.in)
			if got != tt.want {
				t.Fatalf("generateUsernameFromEmail(%q): got %q, want %q", tt.in, got, tt.want)
			}
		})
	}
}
