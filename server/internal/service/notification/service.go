package notification

import (
	"context"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/fcm"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
)

type Service struct {
	store  *repository.Store
	sender fcm.Sender
}

type UpsertInput struct {
	DeviceID              string
	UserID                *uuid.UUID // nil for guests
	Platform              string
	FCMToken              string
	PermissionStatus      string
	ReminderEnabled       bool
	ReminderTimeMinutes   int32
	StreakWarningEnabled  bool
	TimezoneIANA          string
	TimezoneOffsetMinutes int32
	AppVersion            string
	BuildNumber           string
	Locale                string
}

func NewService(store *repository.Store, sender fcm.Sender) (*Service, error) {
	if store == nil {
		return nil, fmt.Errorf("store is required")
	}
	if sender == nil {
		return nil, fmt.Errorf("sender is required")
	}
	return &Service{store: store, sender: sender}, nil
}

func (s *Service) UpsertInstallation(ctx context.Context, in UpsertInput) (sqlcgen.NotificationInstallation, error) {
	if err := validateUpsertInput(in); err != nil {
		return sqlcgen.NotificationInstallation{}, err
	}

	var userID pgtype.UUID
	if in.UserID != nil {
		userID = pgtype.UUID{Bytes: [16]byte(*in.UserID), Valid: true}
	}

	return s.store.Queries().UpsertInstallation(ctx, sqlcgen.UpsertInstallationParams{
		DeviceID:              in.DeviceID,
		UserID:                userID,
		Platform:              in.Platform,
		FcmToken:              in.FCMToken,
		PermissionStatus:      in.PermissionStatus,
		ReminderEnabled:       in.ReminderEnabled,
		ReminderTimeMinutes:   in.ReminderTimeMinutes,
		StreakWarningEnabled:  in.StreakWarningEnabled,
		TimezoneIana:          in.TimezoneIANA,
		TimezoneOffsetMinutes: in.TimezoneOffsetMinutes,
		AppVersion:            in.AppVersion,
		BuildNumber:           in.BuildNumber,
		Locale:                in.Locale,
	})
}

func (s *Service) GetInstallation(ctx context.Context, deviceID string) (sqlcgen.NotificationInstallation, error) {
	if strings.TrimSpace(deviceID) == "" {
		return sqlcgen.NotificationInstallation{}, apierr.New(http.StatusBadRequest, "validation", "device_id is required")
	}
	return s.store.Queries().GetInstallationByDeviceID(ctx, deviceID)
}

func (s *Service) BindToUser(ctx context.Context, deviceID string, userID uuid.UUID) error {
	if strings.TrimSpace(deviceID) == "" {
		return nil // silently skip if no device_id
	}
	return s.store.Queries().BindInstallationToUser(ctx, sqlcgen.BindInstallationToUserParams{
		DeviceID: deviceID,
		UserID:   pgtype.UUID{Bytes: [16]byte(userID), Valid: true},
	})
}

func (s *Service) UnbindFromUser(ctx context.Context, deviceID string, userID uuid.UUID) error {
	if strings.TrimSpace(deviceID) == "" {
		return apierr.New(http.StatusBadRequest, "validation", "device_id is required")
	}
	return s.store.Queries().UnbindInstallation(ctx, sqlcgen.UnbindInstallationParams{
		DeviceID: deviceID,
		UserID:   pgtype.UUID{Bytes: [16]byte(userID), Valid: true},
	})
}

func (s *Service) DeleteInstallation(ctx context.Context, deviceID string) error {
	if strings.TrimSpace(deviceID) == "" {
		return apierr.New(http.StatusBadRequest, "validation", "device_id is required")
	}
	return s.store.Queries().DeleteInstallationByDeviceID(ctx, deviceID)
}

func (s *Service) SendTest(ctx context.Context, deviceID string, kind string, customTitle string, customBody string) error {
	inst, err := s.store.Queries().GetInstallationByDeviceID(ctx, deviceID)
	if err != nil {
		return fmt.Errorf("get installation: %w", err)
	}

	title := "Test notification"
	body := "This is a test push from ClearBreath."
	if kind == "daily_reminder" {
		title = "Daily reminder"
		body = "Take 2 minutes to breathe today."
	} else if kind == "streak_warning" {
		title = "Streak at risk"
		body = "Practice 2 minutes before midnight to keep your streak."
	}
	if customTitle != "" {
		title = customTitle
	}
	if customBody != "" {
		body = customBody
	}

	result, err := s.sender.Send(ctx, fcm.Message{
		Token:    inst.FcmToken,
		Platform: inst.Platform,
		Title:    title,
		Body:     body,
		Data:     map[string]string{"kind": kind},
	})
	if err != nil {
		return fmt.Errorf("send: %w", err)
	}
	if result.Unregistered {
		_ = s.store.Queries().DeleteInstallationByFCMToken(ctx, inst.FcmToken)
		return apierr.New(http.StatusGone, "token_expired", "FCM token is no longer valid")
	}
	if result.Error != nil {
		errMsg := result.Error.Error()
		_ = s.store.Queries().MarkSendError(ctx, sqlcgen.MarkSendErrorParams{
			DeviceID:      deviceID,
			LastSendError: &errMsg,
		})
		return result.Error
	}
	return nil
}

func (s *Service) Sender() fcm.Sender {
	return s.sender
}

func (s *Service) Store() *repository.Store {
	return s.store
}

func validateUpsertInput(in UpsertInput) error {
	if strings.TrimSpace(in.DeviceID) == "" {
		return apierr.New(http.StatusBadRequest, "validation", "device_id is required")
	}
	if len(in.DeviceID) > 200 {
		return apierr.New(http.StatusBadRequest, "validation", "device_id is too long")
	}

	p := strings.ToLower(strings.TrimSpace(in.Platform))
	if p != "android" && p != "ios" {
		return apierr.New(http.StatusBadRequest, "validation", "platform must be 'android' or 'ios'")
	}

	if strings.TrimSpace(in.FCMToken) == "" {
		return apierr.New(http.StatusBadRequest, "validation", "fcm_token is required")
	}

	if in.ReminderTimeMinutes < 0 || in.ReminderTimeMinutes > 1439 {
		return apierr.New(http.StatusBadRequest, "validation", "reminder_time_minutes must be 0-1439")
	}

	if in.TimezoneOffsetMinutes < -840 || in.TimezoneOffsetMinutes > 840 {
		return apierr.New(http.StatusBadRequest, "validation", "timezone_offset_minutes must be -840..840")
	}

	if strings.TrimSpace(in.TimezoneIANA) == "" {
		return apierr.New(http.StatusBadRequest, "validation", "timezone_iana is required")
	}
	if _, err := time.LoadLocation(in.TimezoneIANA); err != nil {
		return apierr.New(http.StatusBadRequest, "validation", "invalid timezone_iana")
	}

	return nil
}
