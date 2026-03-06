package notification

import (
	"net/http"
	"testing"

	"github.com/clearbreath/server/internal/apierr"
)

func TestValidateUpsertInput(t *testing.T) {
	valid := UpsertInput{
		DeviceID:              "test-device-123",
		Platform:              "android",
		FCMToken:              "fcm-token-abc",
		PermissionStatus:      "authorized",
		ReminderEnabled:       true,
		ReminderTimeMinutes:   480,
		StreakWarningEnabled:  true,
		TimezoneIANA:          "America/New_York",
		TimezoneOffsetMinutes: -300,
		AppVersion:            "1.0.0",
		BuildNumber:           "42",
		Locale:                "en_US",
	}

	t.Run("valid input", func(t *testing.T) {
		if err := validateUpsertInput(valid); err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
	})

	t.Run("empty device_id", func(t *testing.T) {
		in := valid
		in.DeviceID = ""
		assertValidationError(t, validateUpsertInput(in), "device_id is required")
	})

	t.Run("device_id too long", func(t *testing.T) {
		in := valid
		in.DeviceID = string(make([]byte, 201))
		assertValidationError(t, validateUpsertInput(in), "device_id is too long")
	})

	t.Run("invalid platform", func(t *testing.T) {
		in := valid
		in.Platform = "windows"
		assertValidationError(t, validateUpsertInput(in), "platform must be 'android' or 'ios'")
	})

	t.Run("ios platform accepted", func(t *testing.T) {
		in := valid
		in.Platform = "ios"
		if err := validateUpsertInput(in); err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
	})

	t.Run("empty fcm_token", func(t *testing.T) {
		in := valid
		in.FCMToken = ""
		assertValidationError(t, validateUpsertInput(in), "fcm_token is required")
	})

	t.Run("negative reminder_time_minutes", func(t *testing.T) {
		in := valid
		in.ReminderTimeMinutes = -1
		assertValidationError(t, validateUpsertInput(in), "reminder_time_minutes must be 0-1439")
	})

	t.Run("reminder_time_minutes too high", func(t *testing.T) {
		in := valid
		in.ReminderTimeMinutes = 1440
		assertValidationError(t, validateUpsertInput(in), "reminder_time_minutes must be 0-1439")
	})

	t.Run("reminder_time_minutes boundary 0", func(t *testing.T) {
		in := valid
		in.ReminderTimeMinutes = 0
		if err := validateUpsertInput(in); err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
	})

	t.Run("reminder_time_minutes boundary 1439", func(t *testing.T) {
		in := valid
		in.ReminderTimeMinutes = 1439
		if err := validateUpsertInput(in); err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
	})

	t.Run("timezone_offset_minutes too low", func(t *testing.T) {
		in := valid
		in.TimezoneOffsetMinutes = -841
		assertValidationError(t, validateUpsertInput(in), "timezone_offset_minutes must be -840..840")
	})

	t.Run("timezone_offset_minutes too high", func(t *testing.T) {
		in := valid
		in.TimezoneOffsetMinutes = 841
		assertValidationError(t, validateUpsertInput(in), "timezone_offset_minutes must be -840..840")
	})

	t.Run("empty timezone_iana", func(t *testing.T) {
		in := valid
		in.TimezoneIANA = ""
		assertValidationError(t, validateUpsertInput(in), "timezone_iana is required")
	})

	t.Run("invalid timezone_iana", func(t *testing.T) {
		in := valid
		in.TimezoneIANA = "Invalid/Zone"
		assertValidationError(t, validateUpsertInput(in), "invalid timezone_iana")
	})

	t.Run("UTC timezone accepted", func(t *testing.T) {
		in := valid
		in.TimezoneIANA = "UTC"
		in.TimezoneOffsetMinutes = 0
		if err := validateUpsertInput(in); err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
	})

	t.Run("Asia/Kolkata timezone accepted", func(t *testing.T) {
		in := valid
		in.TimezoneIANA = "Asia/Kolkata"
		in.TimezoneOffsetMinutes = 330
		if err := validateUpsertInput(in); err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
	})
}

func TestNewServiceValidation(t *testing.T) {
	if _, err := NewService(nil, nil); err == nil {
		t.Fatal("expected error for nil store")
	}
}

func assertValidationError(t *testing.T, err error, wantMsg string) {
	t.Helper()
	if err == nil {
		t.Fatal("expected error")
	}
	e, ok := apierr.As(err)
	if !ok {
		t.Fatalf("expected apierr, got %T: %v", err, err)
	}
	if e.Status != http.StatusBadRequest {
		t.Fatalf("expected status 400, got %d", e.Status)
	}
	if e.Message != wantMsg {
		t.Fatalf("error message: got %q, want %q", e.Message, wantMsg)
	}
}
