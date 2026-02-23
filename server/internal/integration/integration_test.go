package integration

import (
	"context"
	"database/sql"
	"fmt"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/joho/godotenv"
	"github.com/pressly/goose/v3"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/config"
	"github.com/clearbreath/server/internal/profanity"
	"github.com/clearbreath/server/internal/repository"
	authsvc "github.com/clearbreath/server/internal/service/auth"
	lbsvc "github.com/clearbreath/server/internal/service/leaderboard"
	sessionsvc "github.com/clearbreath/server/internal/service/session"
	statssvc "github.com/clearbreath/server/internal/service/stats"
	usersvc "github.com/clearbreath/server/internal/service/user"
	"github.com/clearbreath/server/internal/technique"
)

type fixedClock struct{ t time.Time }

func (c fixedClock) Now() time.Time { return c.t }

func TestEndToEndDevAuthSessionsLeaderboard(t *testing.T) {
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

	authService, err := authsvc.NewService(store, clk, accessTokens, cfg.JWTRefreshSecret, cfg.JWTRefreshTTLMinutes, true, cfg.DevAuthSecret, cfg.GoogleOAuthClientID, cfg.AppleOAuthAudience, profanity.NewDefault())
	if err != nil {
		t.Fatalf("auth service: %v", err)
	}

	userService, err := usersvc.NewService(store, profanity.NewDefault())
	if err != nil {
		t.Fatalf("user service: %v", err)
	}
	_ = userService

	statsService, err := statssvc.NewService(store, clk)
	if err != nil {
		t.Fatalf("stats service: %v", err)
	}

	sessionService, err := sessionsvc.NewService(store, reg, statsService, clk)
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
	if strings.TrimSpace(signIn.RefreshToken) == "" {
		t.Fatalf("expected refresh token")
	}

	userID, err := accessTokens.Parse(signIn.AccessToken, now.Add(1*time.Minute))
	if err != nil {
		t.Fatalf("parse access token: %v", err)
	}

	rotated, err := authService.Refresh(ctx, authsvc.RefreshInput{
		RefreshToken: signIn.RefreshToken,
		DeviceID:     "device1",
	})
	if err != nil {
		t.Fatalf("refresh: %v", err)
	}
	if rotated.RefreshToken == signIn.RefreshToken {
		t.Fatalf("expected refresh token rotation")
	}
	if _, err := authService.Refresh(ctx, authsvc.RefreshInput{
		RefreshToken: signIn.RefreshToken,
		DeviceID:     "device1",
	}); err == nil {
		t.Fatalf("expected replay error")
	} else {
		e, ok := apierr.As(err)
		if !ok || e.Status != http.StatusConflict || e.Code != "refresh_replay" {
			t.Fatalf("unexpected replay error: %v", err)
		}
	}
	if err := authService.Logout(ctx, userID, "device1"); err != nil {
		t.Fatalf("logout: %v", err)
	}
	if _, err := authService.Refresh(ctx, authsvc.RefreshInput{
		RefreshToken: rotated.RefreshToken,
		DeviceID:     "device1",
	}); err == nil {
		t.Fatalf("expected revoked refresh token error")
	}

	start := now.Add(-10 * time.Minute)
	end := now.Add(-5 * time.Minute)
	sessID := "3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11"

	ingest, err := sessionService.Submit(ctx, userID, []sessionsvc.SessionInput{
		{
			ClientSessionID:           sessID,
			TechniqueID:               "hrv_resonance",
			PresetID:                  "beginner",
			StartedAtUTC:              start,
			EndedAtUTC:                end,
			TimezoneOffsetMinutes:     0,
			BreathsCompletedEstimated: 30,
			EndedEarly:                false,
		},
	})
	if err != nil {
		t.Fatalf("submit session: %v", err)
	}
	if ingest.AcceptedCount != 1 {
		t.Fatalf("accepted: got %d, want 1", ingest.AcceptedCount)
	}
	if ingest.StatsSnapshot.SessionsAllTime != 1 {
		t.Fatalf("sessions_all_time: got %d, want 1", ingest.StatsSnapshot.SessionsAllTime)
	}

	dup, err := sessionService.Submit(ctx, userID, []sessionsvc.SessionInput{
		{
			ClientSessionID:           sessID,
			TechniqueID:               "hrv_resonance",
			PresetID:                  "beginner",
			StartedAtUTC:              start,
			EndedAtUTC:                end,
			TimezoneOffsetMinutes:     0,
			BreathsCompletedEstimated: 30,
			EndedEarly:                false,
		},
	})
	if err != nil {
		t.Fatalf("submit duplicate: %v", err)
	}
	if dup.DuplicateCount != 1 {
		t.Fatalf("duplicate: got %d, want 1", dup.DuplicateCount)
	}

	leaderboardService, err := lbsvc.NewService(store, rdb, clk, cfg.LeaderboardDailyCapMin)
	if err != nil {
		t.Fatalf("leaderboard service: %v", err)
	}

	if err := leaderboardService.Refresh(ctx); err != nil {
		t.Fatalf("refresh leaderboard: %v", err)
	}

	self, err := leaderboardService.Self(ctx, userID, lbsvc.RankingAllTime)
	if err != nil {
		t.Fatalf("self rank: %v", err)
	}
	if self.User == nil || self.User.Rank == nil {
		t.Fatalf("expected rank")
	}
	if self.User.MetricValue <= 0 {
		t.Fatalf("expected metric >0")
	}
}

func migrate(databaseURL string) error {
	db, err := sql.Open("pgx", databaseURL)
	if err != nil {
		return fmt.Errorf("open db: %w", err)
	}
	defer func() { _ = db.Close() }()

	if err := goose.SetDialect("postgres"); err != nil {
		return fmt.Errorf("set dialect: %w", err)
	}
	migrationsDir, err := resolveExistingDirPath("migrations", "../../migrations")
	if err != nil {
		return fmt.Errorf("resolve migrations dir: %w", err)
	}
	if err := goose.Up(db, migrationsDir); err != nil {
		return fmt.Errorf("goose up: %w", err)
	}
	return nil
}

func resetState(ctx context.Context, pool *pgxpool.Pool, rdb *redis.Client) error {
	if _, err := pool.Exec(ctx, "TRUNCATE TABLE sessions, stats_snapshots, refresh_tokens, auth_identities, users RESTART IDENTITY CASCADE"); err != nil {
		return fmt.Errorf("truncate tables: %w", err)
	}

	if err := rdb.FlushDB(ctx).Err(); err != nil {
		return fmt.Errorf("flush redis: %w", err)
	}

	return nil
}

func resolveExistingFilePath(paths ...string) (string, error) {
	for _, p := range paths {
		if p == "" {
			continue
		}
		info, err := os.Stat(p)
		if err != nil {
			continue
		}
		if info.IsDir() {
			continue
		}
		return p, nil
	}
	return "", fmt.Errorf("no existing file path found")
}

func resolveExistingDirPath(paths ...string) (string, error) {
	for _, p := range paths {
		if p == "" {
			continue
		}
		info, err := os.Stat(p)
		if err != nil {
			continue
		}
		if !info.IsDir() {
			continue
		}
		return p, nil
	}
	return "", fmt.Errorf("no existing dir path found")
}

func fileExists(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false
	}
	return !info.IsDir()
}
