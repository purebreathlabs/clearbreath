package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestClientIP(t *testing.T) {
	tests := []struct {
		name       string
		remoteAddr string
		headers    map[string]string
		want       string
	}{
		{
			name:       "public remote ignores forwarded headers",
			remoteAddr: "203.0.113.1:1234",
			headers: map[string]string{
				"X-Forwarded-For": "198.51.100.2, 198.51.100.3",
				"X-Real-IP":       "198.51.100.9",
			},
			want: "203.0.113.1",
		},
		{
			name:       "loopback trusts x-real-ip",
			remoteAddr: "127.0.0.1:1234",
			headers: map[string]string{
				"X-Real-IP": "203.0.113.9",
			},
			want: "203.0.113.9",
		},
		{
			name:       "loopback trusts last x-forwarded-for ip",
			remoteAddr: "127.0.0.1:1234",
			headers: map[string]string{
				"X-Forwarded-For": "198.51.100.2, 203.0.113.10",
			},
			want: "203.0.113.10",
		},
		{
			name:       "loopback skips invalid forwarded entries",
			remoteAddr: "127.0.0.1:1234",
			headers: map[string]string{
				"X-Real-IP":       "not-an-ip",
				"X-Forwarded-For": "bad, 203.0.113.11",
			},
			want: "203.0.113.11",
		},
		{
			name:       "private remote trusts forwarded headers",
			remoteAddr: "10.0.0.1:1234",
			headers: map[string]string{
				"X-Real-IP": "203.0.113.12",
			},
			want: "203.0.113.12",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := &http.Request{
				Header:     make(http.Header),
				RemoteAddr: tt.remoteAddr,
			}
			for k, v := range tt.headers {
				r.Header.Set(k, v)
			}
			if got := clientIP(r); got != tt.want {
				t.Fatalf("got %q, want %q", got, tt.want)
			}
		})
	}
}

func TestRateLimitDisabledIsNoop(t *testing.T) {
	called := false
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		w.WriteHeader(http.StatusOK)
	})

	mw := rateLimit(nil, "rl:test", 0, time.Second, func(r *http.Request) string { return "x" })
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	mw(next).ServeHTTP(rec, req)

	if !called {
		t.Fatalf("expected handler called")
	}
	if rec.Code != http.StatusOK {
		t.Fatalf("status: got %d, want %d", rec.Code, http.StatusOK)
	}
}

func TestRateLimitSkipsWhenIDEmpty(t *testing.T) {
	called := false
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		w.WriteHeader(http.StatusOK)
	})

	mw := rateLimit(nil, "rl:test", 10, time.Second, func(r *http.Request) string { return "" })
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	mw(next).ServeHTTP(rec, req)

	if !called {
		t.Fatalf("expected handler called")
	}
	if rec.Code != http.StatusOK {
		t.Fatalf("status: got %d, want %d", rec.Code, http.StatusOK)
	}
}
