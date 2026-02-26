package integration

import (
	"context"
	"net/http"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/config"
	"github.com/clearbreath/server/internal/profanity"
	"github.com/clearbreath/server/internal/repository"
	statssvc "github.com/clearbreath/server/internal/service/stats"
	usersvc "github.com/clearbreath/server/internal/service/user"
)

func TestServiceUnauthorizedBranches(t *testing.T) {
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
	clk := fixedClock{t: time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)}

	userService, err := usersvc.NewService(store, profanity.NewDefault())
	if err != nil {
		t.Fatalf("user service: %v", err)
	}

	_, err = userService.GetProfile(ctx, uuid.New())
	if err == nil {
		t.Fatalf("expected error")
	}
	if e, ok := apierr.As(err); !ok || e.Status != http.StatusUnauthorized {
		t.Fatalf("unexpected error: %v", err)
	}

	if err := userService.DeleteAccount(ctx, uuid.New()); err != nil {
		t.Fatalf("delete account: %v", err)
	}

	statsService, err := statssvc.NewService(store, clk)
	if err != nil {
		t.Fatalf("stats service: %v", err)
	}

	_, err = statsService.Recompute(ctx, uuid.New())
	if err == nil {
		t.Fatalf("expected error")
	}
	if e, ok := apierr.As(err); !ok || e.Status != http.StatusUnauthorized {
		t.Fatalf("unexpected error: %v", err)
	}
}
