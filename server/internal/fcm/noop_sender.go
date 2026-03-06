package fcm

import (
	"context"
	"log/slog"
)

// NoopSender logs message intent without actually sending. Used in development
// when no FCM credentials are configured.
type NoopSender struct{}

func NewNoopSender() *NoopSender {
	return &NoopSender{}
}

func (n *NoopSender) Send(_ context.Context, msg Message) (SendResult, error) {
	slog.Info("fcm noop: would send",
		"token_prefix", truncateToken(msg.Token),
		"platform", msg.Platform,
		"title", msg.Title,
	)
	return SendResult{Token: msg.Token, Success: true}, nil
}

func (n *NoopSender) SendBatch(_ context.Context, msgs []Message) ([]SendResult, error) {
	results := make([]SendResult, len(msgs))
	for i, msg := range msgs {
		slog.Info("fcm noop: would send",
			"token_prefix", truncateToken(msg.Token),
			"platform", msg.Platform,
			"title", msg.Title,
		)
		results[i] = SendResult{Token: msg.Token, Success: true}
	}
	return results, nil
}

func truncateToken(token string) string {
	if len(token) <= 8 {
		return token + "..."
	}
	return token[:8] + "..."
}
