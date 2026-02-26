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
	"github.com/clearbreath/server/internal/repository/sqlcgen"
	authsvc "github.com/clearbreath/server/internal/service/auth"
	lbsvc "github.com/clearbreath/server/internal/service/leaderboard"
	xpsvc "github.com/clearbreath/server/internal/service/xp"
	"github.com/clearbreath/server/internal/technique"
)

func TestLeaderboardListRanksAreContiguousAfterFiltering(t *testing.T) {
	if os.Getenv("CLEARBREATH_INTEGRATION") != "1" {
		t.Skip("integration disabled")
	}

	if envPath, _ := resolveExistingFilePath(".env", "../../.env"); envPath != "" {
		_ = godotenv.Load(envPath)
	}
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
	if _, err := technique.Load(cfg.TechniqueRegistryPath); err != nil {
		t.Fatalf("load registry: %v", err)
	}

	now := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	clk := fixedClock{t: now}

	accessTokens, err := auth.NewAccessTokenManager(cfg.JWTAccessSecret, cfg.JWTAccessTTLMinutes)
	if err != nil {
		t.Fatalf("access token manager: %v", err)
	}

	authService, err := authsvc.NewService(store, clk, accessTokens, cfg.JWTRefreshSecret, cfg.JWTRefreshTTLMinutes, true, cfg.DevAuthSecret, cfg.GoogleOAuthClientID, cfg.AppleOAuthAudience, profanity.NewDefault())
	if err != nil {
		t.Fatalf("auth service: %v", err)
	}

	u1, err := authService.ProviderSignIn(ctx, authsvc.ProviderSignInInput{
		Provider:      "dev",
		IDToken:       "user1",
		DeviceID:      "device1",
		DevAuthHeader: cfg.DevAuthSecret,
	})
	if err != nil {
		t.Fatalf("sign in user1: %v", err)
	}
	u2, err := authService.ProviderSignIn(ctx, authsvc.ProviderSignInInput{
		Provider:      "dev",
		IDToken:       "user2",
		DeviceID:      "device2",
		DevAuthHeader: cfg.DevAuthSecret,
	})
	if err != nil {
		t.Fatalf("sign in user2: %v", err)
	}

	user1ID, err := accessTokens.Parse(u1.AccessToken, now.Add(1*time.Minute))
	if err != nil {
		t.Fatalf("parse user1 access token: %v", err)
	}
	user2ID, err := accessTokens.Parse(u2.AccessToken, now.Add(1*time.Minute))
	if err != nil {
		t.Fatalf("parse user2 access token: %v", err)
	}

	if _, err := store.Queries().UpsertStatsSnapshot(ctx, sqlcgen.UpsertStatsSnapshotParams{
		UserID:             user1ID,
		CurrentStreakDays:  10,
		LongestStreakDays:  10,
		MinutesThisWeek:    0,
		MinutesAllTime:     0,
		SessionsAllTime:    0,
		MinutesByTechnique: []byte("{}"),
	}); err != nil {
		t.Fatalf("upsert stats snapshot user1: %v", err)
	}
	if _, err := store.Queries().UpsertStatsSnapshot(ctx, sqlcgen.UpsertStatsSnapshotParams{
		UserID:             user2ID,
		CurrentStreakDays:  5,
		LongestStreakDays:  5,
		MinutesThisWeek:    0,
		MinutesAllTime:     0,
		SessionsAllTime:    0,
		MinutesByTechnique: []byte("{}"),
	}); err != nil {
		t.Fatalf("upsert stats snapshot user2: %v", err)
	}

	xpService := xpsvc.NewService(store, clk)

	leaderboardService, err := lbsvc.NewService(store, rdb, clk, xpService)
	if err != nil {
		t.Fatalf("leaderboard service: %v", err)
	}

	if err := leaderboardService.Refresh(ctx); err != nil {
		t.Fatalf("refresh leaderboard: %v", err)
	}

	if _, err := store.Queries().UpdateUserLeaderboardPrefs(ctx, sqlcgen.UpdateUserLeaderboardPrefsParams{
		ID:                      user1ID,
		LeaderboardOptIn:        false,
		LeaderboardInitialsOnly: false,
	}); err != nil {
		t.Fatalf("opt out user1: %v", err)
	}

	out, err := leaderboardService.List(ctx, lbsvc.RankingStreak, 50)
	if err != nil {
		t.Fatalf("list: %v", err)
	}

	if len(out.Top) != 1 {
		t.Fatalf("top len: got %d, want 1", len(out.Top))
	}
	if out.Top[0].UserID != user2ID.String() {
		t.Fatalf("user_id: got %q, want %q", out.Top[0].UserID, user2ID.String())
	}
	if out.Top[0].Rank != 1 {
		t.Fatalf("rank: got %d, want 1", out.Top[0].Rank)
	}
}
