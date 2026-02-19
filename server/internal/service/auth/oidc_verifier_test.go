package auth

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"encoding/base64"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

func TestOIDCVerifierVerifySuccessAndCaching(t *testing.T) {
	priv, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatalf("generate key: %v", err)
	}

	kid := "kid1"
	jwks := map[string]any{
		"keys": []map[string]any{
			{
				"kty": "RSA",
				"use": "sig",
				"alg": "RS256",
				"kid": kid,
				"n":   base64.RawURLEncoding.EncodeToString(priv.N.Bytes()),
				"e":   base64.RawURLEncoding.EncodeToString([]byte{0x01, 0x00, 0x01}),
			},
		},
	}

	var issuer string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/.well-known/openid-configuration":
			w.Header().Set("Content-Type", "application/json")
			_ = json.NewEncoder(w).Encode(map[string]any{
				"issuer":   issuer,
				"jwks_uri": issuer + "/keys",
			})
		case "/keys":
			w.Header().Set("Content-Type", "application/json")
			_ = json.NewEncoder(w).Encode(jwks)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()
	issuer = srv.URL

	clientID := "client1"
	raw := signIDToken(t, priv, kid, issuer, clientID, "user1", time.Now().Add(2*time.Minute))

	v := newOIDCVerifier(issuer, clientID)

	sub, err := v.Verify(context.Background(), raw)
	if err != nil {
		t.Fatalf("verify: %v", err)
	}
	if sub != "user1" {
		t.Fatalf("sub: got %q, want %q", sub, "user1")
	}

	sub, err = v.Verify(context.Background(), raw)
	if err != nil {
		t.Fatalf("verify cached: %v", err)
	}
	if sub != "user1" {
		t.Fatalf("sub cached: got %q, want %q", sub, "user1")
	}
}

func TestOIDCVerifierVerifyRejectsInvalidToken(t *testing.T) {
	priv, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatalf("generate key: %v", err)
	}

	kid := "kid1"
	jwks := map[string]any{
		"keys": []map[string]any{
			{
				"kty": "RSA",
				"use": "sig",
				"alg": "RS256",
				"kid": kid,
				"n":   base64.RawURLEncoding.EncodeToString(priv.N.Bytes()),
				"e":   base64.RawURLEncoding.EncodeToString([]byte{0x01, 0x00, 0x01}),
			},
		},
	}

	var issuer string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/.well-known/openid-configuration":
			w.Header().Set("Content-Type", "application/json")
			_ = json.NewEncoder(w).Encode(map[string]any{
				"issuer":   issuer,
				"jwks_uri": issuer + "/keys",
			})
		case "/keys":
			w.Header().Set("Content-Type", "application/json")
			_ = json.NewEncoder(w).Encode(jwks)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()
	issuer = srv.URL

	clientID := "client1"
	raw := "not-a-jwt"

	v := newOIDCVerifier(issuer, clientID)

	if _, err := v.Verify(context.Background(), raw); err == nil {
		t.Fatalf("expected error")
	}
}

func TestOIDCVerifierVerifyRejectsEmptySubject(t *testing.T) {
	priv, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatalf("generate key: %v", err)
	}

	kid := "kid1"
	jwks := map[string]any{
		"keys": []map[string]any{
			{
				"kty": "RSA",
				"use": "sig",
				"alg": "RS256",
				"kid": kid,
				"n":   base64.RawURLEncoding.EncodeToString(priv.N.Bytes()),
				"e":   base64.RawURLEncoding.EncodeToString([]byte{0x01, 0x00, 0x01}),
			},
		},
	}

	var issuer string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/.well-known/openid-configuration":
			w.Header().Set("Content-Type", "application/json")
			_ = json.NewEncoder(w).Encode(map[string]any{
				"issuer":   issuer,
				"jwks_uri": issuer + "/keys",
			})
		case "/keys":
			w.Header().Set("Content-Type", "application/json")
			_ = json.NewEncoder(w).Encode(jwks)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()
	issuer = srv.URL

	clientID := "client1"
	raw := signIDToken(t, priv, kid, issuer, clientID, "", time.Now().Add(2*time.Minute))

	v := newOIDCVerifier(issuer, clientID)

	if _, err := v.Verify(context.Background(), raw); err == nil {
		t.Fatalf("expected error")
	}
}

func TestVerifyProviderGoogleAndAppleSuccessWithLocalOIDC(t *testing.T) {
	priv, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatalf("generate key: %v", err)
	}

	kid := "kid1"
	jwks := map[string]any{
		"keys": []map[string]any{
			{
				"kty": "RSA",
				"use": "sig",
				"alg": "RS256",
				"kid": kid,
				"n":   base64.RawURLEncoding.EncodeToString(priv.N.Bytes()),
				"e":   base64.RawURLEncoding.EncodeToString([]byte{0x01, 0x00, 0x01}),
			},
		},
	}

	var issuer string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/.well-known/openid-configuration":
			w.Header().Set("Content-Type", "application/json")
			_ = json.NewEncoder(w).Encode(map[string]any{
				"issuer":   issuer,
				"jwks_uri": issuer + "/keys",
			})
		case "/keys":
			w.Header().Set("Content-Type", "application/json")
			_ = json.NewEncoder(w).Encode(jwks)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()
	issuer = srv.URL

	clientID := "client1"
	raw := signIDToken(t, priv, kid, issuer, clientID, "user1", time.Now().Add(2*time.Minute))

	s := &Service{
		googleClientID: clientID,
		appleAudience:  clientID,
	}
	s.verifierInitOnce.Do(func() {
		s.googleVerifier = newOIDCVerifier(issuer, clientID)
		s.appleVerifier = newOIDCVerifier(issuer, clientID)
	})

	sub, err := s.verifyProvider(context.Background(), "google", raw, "device1", "")
	if err != nil {
		t.Fatalf("verify google: %v", err)
	}
	if sub != "user1" {
		t.Fatalf("sub: got %q, want %q", sub, "user1")
	}

	sub, err = s.verifyProvider(context.Background(), "apple", raw, "device1", "")
	if err != nil {
		t.Fatalf("verify apple: %v", err)
	}
	if sub != "user1" {
		t.Fatalf("sub: got %q, want %q", sub, "user1")
	}
}

func TestVerifyProviderReturnsProviderTokenError(t *testing.T) {
	priv, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatalf("generate key: %v", err)
	}

	kid := "kid1"
	jwks := map[string]any{
		"keys": []map[string]any{
			{
				"kty": "RSA",
				"use": "sig",
				"alg": "RS256",
				"kid": kid,
				"n":   base64.RawURLEncoding.EncodeToString(priv.N.Bytes()),
				"e":   base64.RawURLEncoding.EncodeToString([]byte{0x01, 0x00, 0x01}),
			},
		},
	}

	var issuer string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/.well-known/openid-configuration":
			w.Header().Set("Content-Type", "application/json")
			_ = json.NewEncoder(w).Encode(map[string]any{
				"issuer":   issuer,
				"jwks_uri": issuer + "/keys",
			})
		case "/keys":
			w.Header().Set("Content-Type", "application/json")
			_ = json.NewEncoder(w).Encode(jwks)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()
	issuer = srv.URL

	clientID := "client1"

	s := &Service{
		googleClientID: clientID,
	}
	s.verifierInitOnce.Do(func() {
		s.googleVerifier = newOIDCVerifier(issuer, clientID)
		s.appleVerifier = newOIDCVerifier(issuer, clientID)
	})

	if _, err := s.verifyProvider(context.Background(), "google", "not-a-jwt", "device1", ""); err == nil {
		t.Fatalf("expected error")
	}
}

func signIDToken(t *testing.T, key *rsa.PrivateKey, kid string, issuer string, clientID string, subject string, exp time.Time) string {
	t.Helper()

	now := time.Now().UTC()
	claims := jwt.MapClaims{
		"iss": issuer,
		"aud": clientID,
		"sub": subject,
		"iat": now.Unix(),
		"exp": exp.UTC().Unix(),
	}

	tok := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
	tok.Header["kid"] = kid

	raw, err := tok.SignedString(key)
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	return raw
}
