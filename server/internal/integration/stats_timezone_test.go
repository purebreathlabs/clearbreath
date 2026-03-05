package integration

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/config"
	"github.com/clearbreath/server/internal/profanity"
	"github.com/clearbreath/server/internal/repository"
	authsvc "github.com/clearbreath/server/internal/service/auth"
	sessionsvc "github.com/clearbreath/server/internal/service/session"
	statssvc "github.com/clearbreath/server/internal/service/stats"
	xpsvc "github.com/clearbreath/server/internal/service/xp"
	"github.com/clearbreath/server/internal/technique"
)

func TestTimezoneOffsetUpdateAndWeekBoundaryStats(t *testing.T) {
	if os.Getenv("CLEARBREATH_INTEGRATION") != "1" {
		t.Skip("integration disabled")
	}

	if envPath, _ := resolveExistingFilePath(".env", "../../.env"); envPath != "" {
		_ = godotenv.Load(envPath)
	}
	setBaseIntegrationEnv(t)
	if p := os.Getenv("TECHNIQUE_REGISTRY_PATH"); p == "" || !fileExists(p) {
		registryPath, err := resolveExistingFilePath("registry/techniques.json", "../../registry/techniques.json")
		if err != nil {
			t.Fatalf("resolve technique registry path: %v", err)
		}
		_ = os.Setenv("TECHNIQUE_REGISTRY_PATH", registryPath)
	}

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

	store := repository.NewStore(pool)
	reg, err := technique.Load(cfg.TechniqueRegistryPath)
	if err != nil {
		t.Fatalf("load registry: %v", err)
	}

	now := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	clk := fixedClock{t: now}

	accessTokens, err := auth.NewAccessTokenManager(cfg.JWTAccessSecret, cfg.JWTAccessTTLMinutes)
	if err != nil {
		t.Fatalf("access token manager: %v", err)
	}

	authService, err := authsvc.NewService(store, clk, accessTokens, cfg.JWTRefreshSecret, cfg.JWTRefreshTTLMinutes, true, cfg.DevAuthSecret, cfg.GoogleOAuthClientIDs, cfg.AppleOAuthAudience, profanity.NewDefault())
	if err != nil {
		t.Fatalf("auth service: %v", err)
	}

	statsService, err := statssvc.NewService(store, clk)
	if err != nil {
		t.Fatalf("stats service: %v", err)
	}

	xpService := xpsvc.NewService(store, clk)

	sessionService, err := sessionsvc.NewService(store, reg, statsService, xpService, clk)
	if err != nil {
		t.Fatalf("session service: %v", err)
	}

	signIn, err := authService.ProviderSignIn(ctx, authsvc.ProviderSignInInput{
		Provider:      "dev",
		IDToken:       "user1",
		DeviceID:      "device1",
		DevAuthHeader: cfg.DevAuthSecret,
	})
	if err != nil {
		t.Fatalf("sign in: %v", err)
	}

	userID, err := accessTokens.Parse(signIn.AccessToken, now.Add(1*time.Minute))
	if err != nil {
		t.Fatalf("parse access token: %v", err)
	}

	sundayStart := time.Date(2026, 2, 15, 23, 0, 0, 0, time.UTC)
	sundayEnd := sundayStart.Add(2 * time.Minute)
	mondayStart := time.Date(2026, 2, 16, 1, 0, 0, 0, time.UTC)
	mondayEnd := mondayStart.Add(2 * time.Minute)
	laterStart := time.Date(2026, 2, 16, 11, 0, 0, 0, time.UTC)
	laterEnd := laterStart.Add(2 * time.Minute)

	out, err := sessionService.Submit(ctx, userID, []sessionsvc.SessionInput{
		{
			ClientSessionID:           "3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
			TechniqueID:               "hrv_resonance",
			PresetID:                  "beginner",
			StartedAtUTC:              sundayStart,
			EndedAtUTC:                sundayEnd,
			TimezoneOffsetMinutes:     0,
			BreathsCompletedEstimated: 0,
			EndedEarly:                false,
		},
		{
			ClientSessionID:           "9b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a12",
			TechniqueID:               "hrv_resonance",
			PresetID:                  "beginner",
			StartedAtUTC:              mondayStart,
			EndedAtUTC:                mondayEnd,
			TimezoneOffsetMinutes:     0,
			BreathsCompletedEstimated: 0,
			EndedEarly:                false,
		},
		{
			ClientSessionID:           "ab9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a13",
			TechniqueID:               "hrv_resonance",
			PresetID:                  "beginner",
			StartedAtUTC:              laterStart,
			EndedAtUTC:                laterEnd,
			TimezoneOffsetMinutes:     60,
			BreathsCompletedEstimated: 0,
			EndedEarly:                false,
		},
	})
	if err != nil {
		t.Fatalf("submit sessions: %v", err)
	}

	if out.StatsSnapshot.MinutesThisWeek != 4 {
		t.Fatalf("minutes_this_week: got %d, want 4", out.StatsSnapshot.MinutesThisWeek)
	}
	if out.StatsSnapshot.MinutesAllTime != 6 {
		t.Fatalf("minutes_all_time: got %d, want 6", out.StatsSnapshot.MinutesAllTime)
	}
	if out.StatsSnapshot.SessionsAllTime != 3 {
		t.Fatalf("sessions_all_time: got %d, want 3", out.StatsSnapshot.SessionsAllTime)
	}
	if out.StatsSnapshot.PracticeDaysAllTime != 2 {
		t.Fatalf("practice_days_all_time: got %d, want 2", out.StatsSnapshot.PracticeDaysAllTime)
	}
	if out.StatsSnapshot.CurrentStreakDays != 2 {
		t.Fatalf("current_streak_days: got %d, want 2", out.StatsSnapshot.CurrentStreakDays)
	}
	if out.StatsSnapshot.LongestStreakDays != 2 {
		t.Fatalf("longest_streak_days: got %d, want 2", out.StatsSnapshot.LongestStreakDays)
	}
	wantWeekly := []int32{4, 0, 0, 0, 0, 0, 0}
	if len(out.WeeklyMinutesByDay) != len(wantWeekly) {
		t.Fatalf("weekly_minutes_by_day length: got %d, want %d", len(out.WeeklyMinutesByDay), len(wantWeekly))
	}
	for i := range wantWeekly {
		if out.WeeklyMinutesByDay[i] != wantWeekly[i] {
			t.Fatalf("weekly_minutes_by_day[%d]: got %d, want %d", i, out.WeeklyMinutesByDay[i], wantWeekly[i])
		}
	}

	u, err := store.Queries().GetUserByID(ctx, userID)
	if err != nil {
		t.Fatalf("get user: %v", err)
	}
	if u.TimezoneOffsetMinutesLatest != 60 {
		t.Fatalf("timezone_offset_minutes_latest: got %d, want 60", u.TimezoneOffsetMinutesLatest)
	}
}
