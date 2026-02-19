package leaderboard

import (
	"context"
	"errors"
	"sort"
	"testing"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/repository/sqlcgen"
)

type memRedis struct {
	zsets     map[string]map[string]float64
	delErr    error
	zaddErr   error
	renameErr error
	rangeErr  error
	rankErr   error
	scoreErr  error
}

func newMemRedis() *memRedis {
	return &memRedis{
		zsets: make(map[string]map[string]float64),
	}
}

func (m *memRedis) Del(_ context.Context, keys ...string) error {
	if m.delErr != nil {
		return m.delErr
	}
	for _, k := range keys {
		delete(m.zsets, k)
	}
	return nil
}

func (m *memRedis) ZAdd(_ context.Context, key string, members ...redis.Z) error {
	if m.zaddErr != nil {
		return m.zaddErr
	}
	if m.zsets[key] == nil {
		m.zsets[key] = make(map[string]float64)
	}
	for _, z := range members {
		s, ok := z.Member.(string)
		if !ok {
			continue
		}
		m.zsets[key][s] = z.Score
	}
	return nil
}

func (m *memRedis) Rename(_ context.Context, key string, newkey string) error {
	if m.renameErr != nil {
		return m.renameErr
	}
	v, ok := m.zsets[key]
	if !ok {
		return redis.Nil
	}
	m.zsets[newkey] = v
	delete(m.zsets, key)
	return nil
}

func (m *memRedis) ZRevRangeWithScores(_ context.Context, key string, start int64, stop int64) ([]redis.Z, error) {
	if m.rangeErr != nil {
		return nil, m.rangeErr
	}
	z := m.zsets[key]
	if len(z) == 0 {
		return []redis.Z{}, nil
	}

	out := make([]redis.Z, 0, len(z))
	for member, score := range z {
		out = append(out, redis.Z{Member: member, Score: score})
	}

	sort.Slice(out, func(i, j int) bool {
		if out[i].Score == out[j].Score {
			return out[i].Member.(string) > out[j].Member.(string)
		}
		return out[i].Score > out[j].Score
	})

	if start < 0 {
		start = 0
	}
	if stop < start {
		return []redis.Z{}, nil
	}
	if start >= int64(len(out)) {
		return []redis.Z{}, nil
	}
	if stop >= int64(len(out)) {
		stop = int64(len(out)) - 1
	}
	return out[start : stop+1], nil
}

func (m *memRedis) ZRevRank(_ context.Context, key string, member string) (int64, error) {
	if m.rankErr != nil {
		return 0, m.rankErr
	}
	zs, err := m.ZRevRangeWithScores(context.Background(), key, 0, int64(len(m.zsets[key])-1))
	if err != nil {
		return 0, err
	}
	for i, z := range zs {
		if z.Member.(string) == member {
			return int64(i), nil
		}
	}
	return 0, redis.Nil
}

func (m *memRedis) ZScore(_ context.Context, key string, member string) (float64, error) {
	if m.scoreErr != nil {
		return 0, m.scoreErr
	}
	if m.zsets[key] == nil {
		return 0, redis.Nil
	}
	score, ok := m.zsets[key][member]
	if !ok {
		return 0, redis.Nil
	}
	return score, nil
}

func TestWriteZSetDeletesFinalOnEmptyDataset(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	s := &Service{redis: r}

	_ = r.ZAdd(ctx, "lb:streak", redis.Z{Member: uuid.New().String(), Score: 1})

	if err := s.writeZSet(ctx, "lb:streak", []sqlcgen.GetLeaderboardStreakMetricsRow{}); err != nil {
		t.Fatalf("writeZSet: %v", err)
	}

	if _, ok := r.zsets["lb:streak"]; ok {
		t.Fatalf("expected lb:streak to be deleted")
	}
}

func TestWriteZSetRenameFailureLeavesFinalUntouchedAndRecovers(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	s := &Service{redis: r}

	oldID := uuid.New().String()
	newID := uuid.New().String()

	_ = r.ZAdd(ctx, "lb:streak", redis.Z{Member: oldID, Score: 1})
	r.renameErr = errors.New("rename failed")

	rows := []sqlcgen.GetLeaderboardStreakMetricsRow{
		{UserID: uuid.MustParse(newID), MetricValue: 10},
	}

	if err := s.writeZSet(ctx, "lb:streak", rows); err == nil {
		t.Fatalf("expected error")
	}

	if score, ok := r.zsets["lb:streak"][oldID]; !ok || score != 1 {
		t.Fatalf("expected final key to remain unchanged")
	}
	if _, ok := r.zsets["lb:streak:tmp"][newID]; !ok {
		t.Fatalf("expected tmp key to exist after rename failure")
	}

	r.renameErr = nil

	if err := s.writeZSet(ctx, "lb:streak", rows); err != nil {
		t.Fatalf("writeZSet: %v", err)
	}

	if _, ok := r.zsets["lb:streak:tmp"]; ok {
		t.Fatalf("expected tmp key to be removed")
	}
	if _, ok := r.zsets["lb:streak"][newID]; !ok {
		t.Fatalf("expected final key to be updated")
	}
}

func TestListReturnsRedisError(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	r.rangeErr = errors.New("redis down")
	s := &Service{
		redis: r,
	}

	if _, err := s.List(ctx, RankingWeekly, 50); err == nil {
		t.Fatalf("expected error")
	}
}

func TestWriteZSetDelFailureReturnsError(t *testing.T) {
	ctx := context.Background()
	r := newMemRedis()
	r.delErr = errors.New("redis down")
	s := &Service{redis: r}

	rows := []sqlcgen.GetLeaderboardStreakMetricsRow{
		{UserID: uuid.New(), MetricValue: 1},
	}

	if err := s.writeZSet(ctx, "lb:streak", rows); err == nil {
		t.Fatalf("expected error")
	}
}
