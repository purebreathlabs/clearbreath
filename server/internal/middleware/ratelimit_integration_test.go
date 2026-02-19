package middleware

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/redis/go-redis/v9"
)

func TestAllowSetsExpiryAndEnforcesLimit(t *testing.T) {
	if os.Getenv("CLEARBREATH_INTEGRATION") != "1" {
		t.Skip("integration disabled")
	}

	addr := os.Getenv("REDIS_ADDR")
	if addr == "" {
		addr = "localhost:6380"
	}
	password := os.Getenv("REDIS_PASSWORD")

	rdb := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: password,
	})
	defer func() { _ = rdb.Close() }()

	ctx := context.Background()

	if err := rdb.FlushDB(ctx).Err(); err != nil {
		t.Fatalf("flushdb: %v", err)
	}

	key := "rl:test:allow"
	window := 10 * time.Second

	allowed, err := allow(ctx, rdb, key, 2, window)
	if err != nil {
		t.Fatalf("allow1: %v", err)
	}
	if !allowed {
		t.Fatalf("expected allowed")
	}

	ttl, err := rdb.TTL(ctx, key).Result()
	if err != nil {
		t.Fatalf("ttl: %v", err)
	}
	if ttl <= 0 {
		t.Fatalf("expected ttl >0, got %v", ttl)
	}

	allowed, err = allow(ctx, rdb, key, 2, window)
	if err != nil {
		t.Fatalf("allow2: %v", err)
	}
	if !allowed {
		t.Fatalf("expected allowed")
	}

	allowed, err = allow(ctx, rdb, key, 2, window)
	if err != nil {
		t.Fatalf("allow3: %v", err)
	}
	if allowed {
		t.Fatalf("expected not allowed")
	}
}

func TestRateLimitMiddlewareEnforcesLimit(t *testing.T) {
	if os.Getenv("CLEARBREATH_INTEGRATION") != "1" {
		t.Skip("integration disabled")
	}

	addr := os.Getenv("REDIS_ADDR")
	if addr == "" {
		addr = "localhost:6380"
	}
	password := os.Getenv("REDIS_PASSWORD")

	rdb := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: password,
	})
	defer func() { _ = rdb.Close() }()

	ctx := context.Background()
	if err := rdb.FlushDB(ctx).Err(); err != nil {
		t.Fatalf("flushdb: %v", err)
	}

	mw := RateLimitIP(rdb, "rl:test:mw", 1, 10*time.Second)

	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})
	h := RequestID(mw(next))

	req := httptest.NewRequest(http.MethodGet, "/", nil)
	req.RemoteAddr = "127.0.0.1:1234"
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	if rec.Code != http.StatusOK {
		t.Fatalf("first: status %d", rec.Code)
	}

	rec2 := httptest.NewRecorder()
	h.ServeHTTP(rec2, req)
	if rec2.Code != http.StatusTooManyRequests {
		t.Fatalf("second: status %d", rec2.Code)
	}

	var e struct {
		Code string `json:"code"`
	}
	if err := json.NewDecoder(rec2.Body).Decode(&e); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if e.Code != "rate_limited" {
		t.Fatalf("code: got %q, want %q", e.Code, "rate_limited")
	}
}

func TestRateLimitMiddlewareReturns500OnRedisError(t *testing.T) {
	if os.Getenv("CLEARBREATH_INTEGRATION") != "1" {
		t.Skip("integration disabled")
	}

	addr := os.Getenv("REDIS_ADDR")
	if addr == "" {
		addr = "localhost:6380"
	}
	password := os.Getenv("REDIS_PASSWORD")

	rdb := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: password,
	})
	_ = rdb.Close()

	mw := RateLimitIP(rdb, "rl:test:mwerr", 1, 10*time.Second)

	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})
	h := RequestID(mw(next))

	req := httptest.NewRequest(http.MethodGet, "/", nil)
	req.RemoteAddr = "127.0.0.1:1234"
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	if rec.Code != http.StatusInternalServerError {
		t.Fatalf("status %d", rec.Code)
	}
}
