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
)

func TestNewServiceValidation(t *testing.T) {
	clk := clock.RealClock{}
	store := &repository.Store{}
	rdb := redis.NewClient(&redis.Options{Addr: "localhost:6380"})
	defer func() { _ = rdb.Close() }()

	if _, err := NewService(nil, rdb, clk, 60); err == nil {
		t.Fatalf("expected error")
	}
	if _, err := NewService(store, nil, clk, 60); err == nil {
		t.Fatalf("expected error")
	}
	if _, err := NewService(store, rdb, nil, 60); err == nil {
		t.Fatalf("expected error")
	}
	if _, err := NewService(store, rdb, clk, 0); err == nil {
		t.Fatalf("expected error")
	}
}

func TestRankingKeyDefault(t *testing.T) {
	if got := rankingKey(Ranking("nope")); got != "lb:streak" {
		t.Fatalf("got %q, want %q", got, "lb:streak")
	}
}

func TestWriteZSetUnsupportedRowsType(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	s := &Service{redis: r}

	if err := s.writeZSet(ctx, "lb:streak", []int{1}); err == nil {
		t.Fatalf("expected error")
	}
}

func TestWriteZSetRenameRedisNilIsIgnored(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	r.renameErr = redis.Nil
	s := &Service{redis: r}

	rows := []sqlcgen.GetLeaderboardStreakMetricsRow{
		{UserID: uuid.MustParse("3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11"), MetricValue: 1},
	}

	if err := s.writeZSet(ctx, "lb:streak", rows); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if _, ok := r.zsets["lb:streak"]; ok {
		t.Fatalf("expected lb:streak to remain absent")
	}
	if _, ok := r.zsets["lb:streak:tmp"]; !ok {
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
	s := &Service{redis: r}

	if _, err := s.Self(ctx, uuid.New(), RankingAllTime); err == nil {
		t.Fatalf("expected error")
	}
}

func TestSelfReturnsScoreError(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	r.scoreErr = errors.New("redis down")
	s := &Service{redis: r}

	if _, err := s.Self(ctx, uuid.New(), RankingAllTime); err == nil {
		t.Fatalf("expected error")
	}
}

func TestSelfHandlesRankWithoutScore(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	userID := uuid.New()
	r.zsets["lb:all_time"] = map[string]float64{userID.String(): 10}
	r.scoreErr = redis.Nil

	s := &Service{redis: r}
	out, err := s.Self(ctx, userID, RankingAllTime)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if out.User == nil || out.User.Rank == nil || *out.User.Rank != 1 {
		t.Fatalf("expected rank 1")
	}
	if out.User.MetricValue != 0 {
		t.Fatalf("metric: got %d, want 0", out.User.MetricValue)
	}
}

func TestSelfHandlesScoreWithoutRank(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	userID := uuid.New()
	r.zsets["lb:all_time"] = map[string]float64{userID.String(): 7}
	r.rankErr = redis.Nil

	s := &Service{redis: r}
	out, err := s.Self(ctx, userID, RankingAllTime)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if out.User == nil || out.User.Rank != nil {
		t.Fatalf("expected nil rank")
	}
	if out.User.MetricValue != 7 {
		t.Fatalf("metric: got %d, want 7", out.User.MetricValue)
	}
}
