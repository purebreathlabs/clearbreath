package leaderboard

import (
	"context"
	"errors"
	"strings"
	"testing"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
	"github.com/clearbreath/server/internal/service/xp"
)

func TestNewServiceValidation(t *testing.T) {
	clk := clock.RealClock{}
	store := &repository.Store{}
	xpSvc := xp.NewService(nil, nil)
	rdb := redis.NewClient(&redis.Options{Addr: "localhost:6380"})
	defer func() { _ = rdb.Close() }()

	if _, err := NewService(nil, rdb, clk, xpSvc); err == nil {
		t.Fatalf("expected error")
	}
	if _, err := NewService(store, nil, clk, xpSvc); err == nil {
		t.Fatalf("expected error")
	}
	if _, err := NewService(store, rdb, nil, xpSvc); err == nil {
		t.Fatalf("expected error")
	}
	if _, err := NewService(store, rdb, clk, nil); err == nil {
		t.Fatalf("expected error")
	}
}

func TestWriteZSetRenameRedisNilIsIgnored(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	r.renameErr = redis.Nil
	s := &Service{redis: r}

	rows := []sqlcgen.GetLeaderboardXPMetricsRow{
		{UserID: uuid.MustParse("3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11"), TotalXp: 1},
	}

	if err := s.writeZSet(ctx, "lb:xp", rows); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if _, ok := r.zsets["lb:xp"]; ok {
		t.Fatalf("expected lb:xp to remain absent")
	}
	if _, ok := r.zsets["lb:xp:tmp"]; !ok {
		t.Fatalf("expected tmp key to exist")
	}
}

func TestInitialsReturnsUOnEmptyOrNonWord(t *testing.T) {
	if got := initials(""); got != "U" {
		t.Fatalf("got %q, want %q", got, "U")
	}
	if got := initials("   "); got != "U" {
		t.Fatalf("got %q, want %q", got, "U")
	}
	if got := initials(strings.Repeat("-", 10)); got != "U" {
		t.Fatalf("got %q, want %q", got, "U")
	}
	if got := initials("A"); got != "A" {
		t.Fatalf("got %q, want %q", got, "A")
	}
	if got := initials("A B"); got != "AB" {
		t.Fatalf("got %q, want %q", got, "AB")
	}
}

func TestSelfReturnsRankError(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	r.rankErr = errors.New("redis down")
	s := &Service{redis: r, xp: xp.NewService(nil, nil)}

	if _, err := s.Self(ctx, uuid.New(), RankingAllTime); err == nil {
		t.Fatalf("expected error")
	}
}

func TestSelfReturnsScoreError(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	r.scoreErr = errors.New("redis down")
	s := &Service{redis: r, xp: xp.NewService(nil, nil)}

	if _, err := s.Self(ctx, uuid.New(), RankingAllTime); err == nil {
		t.Fatalf("expected error")
	}
}

func TestSelfHandlesRankWithoutScore(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	userID := uuid.New()
	r.zsets["lb:xp"] = map[string]float64{userID.String(): 10}
	r.scoreErr = redis.Nil

	s := &Service{redis: r, xp: xp.NewService(nil, nil)}
	out, err := s.Self(ctx, userID, RankingAllTime)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if out.User == nil || out.User.Rank == nil || *out.User.Rank != 1 {
		t.Fatalf("expected rank 1")
	}
	if out.User.TotalXP != 0 {
		t.Fatalf("total_xp: got %d, want 0", out.User.TotalXP)
	}
}

func TestSelfHandlesScoreWithoutRank(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	userID := uuid.New()
	r.zsets["lb:xp"] = map[string]float64{userID.String(): 7}
	r.rankErr = redis.Nil

	s := &Service{redis: r, xp: xp.NewService(nil, nil)}
	out, err := s.Self(ctx, userID, RankingAllTime)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if out.User == nil || out.User.Rank != nil {
		t.Fatalf("expected nil rank")
	}
	if out.User.TotalXP != 7 {
		t.Fatalf("total_xp: got %d, want 7", out.User.TotalXP)
	}
}
