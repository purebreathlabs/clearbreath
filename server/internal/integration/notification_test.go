package integration

import (
	"context"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/joho/godotenv"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/config"
	"github.com/clearbreath/server/internal/fcm"
	"github.com/clearbreath/server/internal/profanity"
	"github.com/clearbreath/server/internal/repository"
	authsvc "github.com/clearbreath/server/internal/service/auth"
	notifsvc "github.com/clearbreath/server/internal/service/notification"

	"time"
)

func TestNotificationInstallationRoundTrip(t *testing.T) {
	if os.Getenv("CLEARBREATH_INTEGRATION") != "1" {
		t.Skip("integration disabled")
	}

	if envPath, _ := resolveExistingFilePath(".env", "../../.env"); envPath != "" {
		_ = godotenv.Load(envPath)
	}
	setBaseIntegrationEnv(t)

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("load config: %v", err)
	}

	if err := migrate(cfg.DatabaseURL); err != nil {
		t.Fatalf("migrate: %v", err)
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err != nil {
		t.Fatalf("pgxpool: %v", err)
	}
	defer pool.Close()

	rdb := redis.NewClient(&redis.Options{
		Addr:     cfg.RedisAddr,
		Password: cfg.RedisPassword,
	})
	defer func() { _ = rdb.Close() }()

	if err := resetState(ctx, pool, rdb); err != nil {
		t.Fatalf("reset state: %v", err)
	}
	// Also truncate notification_installations
	if _, err := pool.Exec(ctx, "TRUNCATE TABLE notification_installations RESTART IDENTITY CASCADE"); err != nil {
		t.Fatalf("truncate notification_installations: %v", err)
	}

	store := repository.NewStore(pool)
	sender := fcm.NewNoopSender()

	notifSvc, err := notifsvc.NewService(store, sender)
	if err != nil {
		t.Fatalf("notification service: %v", err)
	}

	// 1. Guest upsert (no user_id)
	inst, err := notifSvc.UpsertInstallation(ctx, notifsvc.UpsertInput{
		DeviceID:              "test-device-001",
		UserID:                nil,
		Platform:              "android",
		FCMToken:              "fcm-token-abc",
		PermissionStatus:      "authorized",
		ReminderEnabled:       true,
		ReminderTimeMinutes:   1320, // 22:00
		StreakWarningEnabled:  true,
		TimezoneIANA:          "Asia/Kolkata",
		TimezoneOffsetMinutes: 330,
		AppVersion:            "1.0.0",
		BuildNumber:           "42",
		Locale:                "en_IN",
	})
	if err != nil {
		t.Fatalf("guest upsert: %v", err)
	}
	if inst.UserID.Valid {
		t.Fatal("expected null user_id for guest")
	}
	if inst.Platform != "android" {
		t.Fatalf("platform: got %q, want android", inst.Platform)
	}
	if inst.ReminderTimeMinutes != 1320 {
		t.Fatalf("reminder_time: got %d, want 1320", inst.ReminderTimeMinutes)
	}

	// 2. Get installation
	got, err := notifSvc.GetInstallation(ctx, "test-device-001")
	if err != nil {
		t.Fatalf("get installation: %v", err)
	}
	if got.DeviceID != "test-device-001" {
		t.Fatalf("device_id: got %q, want test-device-001", got.DeviceID)
	}

	// 3. Sign in a user and bind installation
	now := time.Date(2026, 3, 6, 12, 0, 0, 0, time.UTC)
	clk := fixedClock{t: now}
	accessTokens, err := auth.NewAccessTokenManager(cfg.JWTAccessSecret, cfg.JWTAccessTTLMinutes)
	if err != nil {
		t.Fatalf("access tokens: %v", err)
	}
	authService, err := authsvc.NewService(store, clk, accessTokens, cfg.JWTRefreshSecret, cfg.JWTRefreshTTLMinutes, true, cfg.DevAuthSecret, cfg.GoogleOAuthClientIDs, cfg.AppleOAuthAudience, profanity.NewDefault())
	if err != nil {
		t.Fatalf("auth service: %v", err)
	}
	signIn, err := authService.ProviderSignIn(ctx, authsvc.ProviderSignInInput{
		Provider:      "dev",
		IDToken:       "notif-test-user",
		DeviceID:      "test-device-001",
		DevAuthHeader: cfg.DevAuthSecret,
	})
	if err != nil {
		t.Fatalf("sign in: %v", err)
	}
	userID, err := accessTokens.Parse(signIn.AccessToken, now.Add(time.Minute))
	if err != nil {
		t.Fatalf("parse token: %v", err)
	}

	// Bind installation to user
	if err := notifSvc.BindToUser(ctx, "test-device-001", userID); err != nil {
		t.Fatalf("bind to user: %v", err)
	}

	// Verify user_id is now set
	got, err = notifSvc.GetInstallation(ctx, "test-device-001")
	if err != nil {
		t.Fatalf("get after bind: %v", err)
	}
	if !got.UserID.Valid {
		t.Fatal("expected non-null user_id after bind")
	}

	// 4. Update preferences via upsert
	inst, err = notifSvc.UpsertInstallation(ctx, notifsvc.UpsertInput{
		DeviceID:              "test-device-001",
		UserID:                &userID,
		Platform:              "android",
		FCMToken:              "fcm-token-abc-v2",
		PermissionStatus:      "authorized",
		ReminderEnabled:       true,
		ReminderTimeMinutes:   480, // change to 8:00
		StreakWarningEnabled:  false,
		TimezoneIANA:          "Asia/Kolkata",
		TimezoneOffsetMinutes: 330,
		AppVersion:            "1.0.1",
		BuildNumber:           "43",
		Locale:                "en_IN",
	})
	if err != nil {
		t.Fatalf("update upsert: %v", err)
	}
	if inst.ReminderTimeMinutes != 480 {
		t.Fatalf("updated reminder_time: got %d, want 480", inst.ReminderTimeMinutes)
	}
	if inst.FcmToken != "fcm-token-abc-v2" {
		t.Fatalf("updated fcm_token: got %q", inst.FcmToken)
	}
	if inst.StreakWarningEnabled {
		t.Fatal("expected streak_warning_enabled = false after update")
	}

	// 5. Unbind (sign-out) - keeps record but nulls user_id
	if err := notifSvc.UnbindFromUser(ctx, "test-device-001", userID); err != nil {
		t.Fatalf("unbind: %v", err)
	}
	got, err = notifSvc.GetInstallation(ctx, "test-device-001")
	if err != nil {
		t.Fatalf("get after unbind: %v", err)
	}
	if got.UserID.Valid {
		t.Fatal("expected null user_id after unbind")
	}
	// Record still exists
	if got.DeviceID != "test-device-001" {
		t.Fatalf("device_id missing after unbind")
	}

	// 6. Delete installation
	if err := notifSvc.DeleteInstallation(ctx, "test-device-001"); err != nil {
		t.Fatalf("delete: %v", err)
	}
	_, err = notifSvc.GetInstallation(ctx, "test-device-001")
	if err == nil {
		t.Fatal("expected error after delete")
	}
}

func TestNotificationValidationErrors(t *testing.T) {
	if os.Getenv("CLEARBREATH_INTEGRATION") != "1" {
		t.Skip("integration disabled")
	}

	if envPath, _ := resolveExistingFilePath(".env", "../../.env"); envPath != "" {
		_ = godotenv.Load(envPath)
	}
	setBaseIntegrationEnv(t)

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("load config: %v", err)
	}

	if err := migrate(cfg.DatabaseURL); err != nil {
		t.Fatalf("migrate: %v", err)
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err != nil {
		t.Fatalf("pgxpool: %v", err)
	}
	defer pool.Close()

	store := repository.NewStore(pool)
	sender := fcm.NewNoopSender()

	notifSvc, err := notifsvc.NewService(store, sender)
	if err != nil {
		t.Fatalf("notification service: %v", err)
	}

	cases := []struct {
		name  string
		input notifsvc.UpsertInput
	}{
		{
			name: "invalid timezone",
			input: notifsvc.UpsertInput{
				DeviceID: "d1", Platform: "android", FCMToken: "tok",
				TimezoneIANA: "Invalid/Zone", TimezoneOffsetMinutes: 0,
			},
		},
		{
			name: "invalid platform",
			input: notifsvc.UpsertInput{
				DeviceID: "d2", Platform: "windows", FCMToken: "tok",
				TimezoneIANA: "UTC", TimezoneOffsetMinutes: 0,
			},
		},
		{
			name: "out of range minutes",
			input: notifsvc.UpsertInput{
				DeviceID: "d3", Platform: "ios", FCMToken: "tok",
				ReminderTimeMinutes: -1, TimezoneIANA: "UTC",
			},
		},
		{
			name: "empty fcm_token",
			input: notifsvc.UpsertInput{
				DeviceID: "d4", Platform: "android", FCMToken: "",
				TimezoneIANA: "UTC",
			},
		},
		{
			name: "timezone_offset too high",
			input: notifsvc.UpsertInput{
				DeviceID: "d5", Platform: "android", FCMToken: "tok",
				TimezoneIANA: "UTC", TimezoneOffsetMinutes: 900,
			},
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			_, err := notifSvc.UpsertInstallation(ctx, tc.input)
			if err == nil {
				t.Fatal("expected validation error")
			}
		})
	}
}
