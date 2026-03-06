package fcm

import "context"

// Message represents a push notification to be sent to a single device.
type Message struct {
	Token    string
	Platform string // "android" or "ios"
	Title    string
	Body     string
	Data     map[string]string
}

// SendResult reports per-token outcome.
type SendResult struct {
	Token        string
	Success      bool
	Unregistered bool // true if token is invalid/expired; caller should delete
	Error        error
}

// Sender abstracts FCM message delivery.
type Sender interface {
	Send(ctx context.Context, msg Message) (SendResult, error)
	SendBatch(ctx context.Context, msgs []Message) ([]SendResult, error)
}
