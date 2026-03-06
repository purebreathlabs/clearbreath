package fcm

import (
	"context"
	"fmt"
	"log/slog"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

// FirebaseSender sends push notifications via Firebase Cloud Messaging using the Admin SDK.
type FirebaseSender struct {
	client *messaging.Client
}

// NewFirebaseSender creates a sender from a service account JSON credential.
func NewFirebaseSender(ctx context.Context, serviceAccountJSON []byte) (*FirebaseSender, error) {
	app, err := firebase.NewApp(ctx, nil, option.WithCredentialsJSON(serviceAccountJSON))
	if err != nil {
		return nil, fmt.Errorf("firebase app init: %w", err)
	}

	client, err := app.Messaging(ctx)
	if err != nil {
		return nil, fmt.Errorf("firebase messaging client: %w", err)
	}

	return &FirebaseSender{client: client}, nil
}

func NewFirebaseSenderFromDefault(ctx context.Context) (*FirebaseSender, error) {
	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		return nil, fmt.Errorf("firebase app init from default credentials: %w", err)
	}

	client, err := app.Messaging(ctx)
	if err != nil {
		return nil, fmt.Errorf("firebase messaging client: %w", err)
	}

	return &FirebaseSender{client: client}, nil
}

func (f *FirebaseSender) Send(ctx context.Context, msg Message) (SendResult, error) {
	fcmMsg := buildFCMMessage(msg)

	_, err := f.client.Send(ctx, fcmMsg)
	if err != nil {
		if messaging.IsUnregistered(err) {
			slog.Warn("fcm: token unregistered",
				"token_prefix", truncateToken(msg.Token),
			)
			return SendResult{Token: msg.Token, Unregistered: true, Error: err}, nil
		}
		slog.Error("fcm: send failed",
			"token_prefix", truncateToken(msg.Token),
			"error", err,
		)
		return SendResult{Token: msg.Token, Error: err}, nil
	}

	return SendResult{Token: msg.Token, Success: true}, nil
}

func (f *FirebaseSender) SendBatch(ctx context.Context, msgs []Message) ([]SendResult, error) {
	if len(msgs) == 0 {
		return nil, nil
	}

	fcmMessages := make([]*messaging.Message, len(msgs))
	for i, msg := range msgs {
		fcmMessages[i] = buildFCMMessage(msg)
	}

	resp, err := f.client.SendEach(ctx, fcmMessages)
	if err != nil {
		return nil, fmt.Errorf("fcm batch send: %w", err)
	}

	results := make([]SendResult, len(resp.Responses))
	for i, r := range resp.Responses {
		result := SendResult{Token: msgs[i].Token}
		if r.Success {
			result.Success = true
		} else if r.Error != nil {
			result.Error = r.Error
			if messaging.IsUnregistered(r.Error) {
				result.Unregistered = true
				slog.Warn("fcm: token unregistered in batch",
					"token_prefix", truncateToken(msgs[i].Token),
				)
			}
		}
		results[i] = result
	}

	return results, nil
}

func buildFCMMessage(msg Message) *messaging.Message {
	m := &messaging.Message{
		Token: msg.Token,
		Notification: &messaging.Notification{
			Title: msg.Title,
			Body:  msg.Body,
		},
		Data: msg.Data,
	}

	switch msg.Platform {
	case "android":
		m.Android = &messaging.AndroidConfig{
			Priority: "high",
		}
	case "ios":
		m.APNS = &messaging.APNSConfig{
			Headers: map[string]string{
				"apns-priority": "10",
			},
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Sound: "default",
				},
			},
		}
	}

	return m
}
