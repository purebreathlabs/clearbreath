package fcm

import (
	"context"
	"testing"
)

func TestNoopSenderSend(t *testing.T) {
	sender := NewNoopSender()
	result, err := sender.Send(context.Background(), Message{
		Token:    "test-token-12345678",
		Platform: "android",
		Title:    "Test",
		Body:     "Test body",
		Data:     map[string]string{"kind": "daily_reminder"},
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !result.Success {
		t.Fatal("expected success")
	}
	if result.Token != "test-token-12345678" {
		t.Fatalf("got token %q, want %q", result.Token, "test-token-12345678")
	}
	if result.Unregistered {
		t.Fatal("expected not unregistered")
	}
}

func TestNoopSenderSendBatch(t *testing.T) {
	sender := NewNoopSender()
	msgs := []Message{
		{Token: "token-1", Platform: "android", Title: "A"},
		{Token: "token-2", Platform: "ios", Title: "B"},
	}
	results, err := sender.SendBatch(context.Background(), msgs)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(results) != 2 {
		t.Fatalf("got %d results, want 2", len(results))
	}
	for i, r := range results {
		if !r.Success {
			t.Fatalf("result[%d] not success", i)
		}
	}
}

func TestTruncateToken(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		{"", "..."},
		{"short", "short..."},
		{"12345678", "12345678..."},
		{"123456789", "12345678..."},
		{"abcdefghijklmnop", "abcdefgh..."},
	}
	for _, tt := range tests {
		got := truncateToken(tt.input)
		if got != tt.want {
			t.Errorf("truncateToken(%q) = %q, want %q", tt.input, got, tt.want)
		}
	}
}
