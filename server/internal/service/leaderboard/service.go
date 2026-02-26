package leaderboard

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"
	"unicode"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
	"github.com/clearbreath/server/internal/service/xp"
)

type Service struct {
	store *repository.Store
	redis redisOps
	clock clock.Clock
	xp    *xp.Service
}

type redisOps interface {
	Del(ctx context.Context, keys ...string) error
	ZAdd(ctx context.Context, key string, members ...redis.Z) error
	Rename(ctx context.Context, key string, newkey string) error
	ZRevRangeWithScores(ctx context.Context, key string, start int64, stop int64) ([]redis.Z, error)
	ZRevRank(ctx context.Context, key string, member string) (int64, error)
	ZScore(ctx context.Context, key string, member string) (float64, error)
}

type redisClientOps struct {
	c *redis.Client
}

func (r redisClientOps) Del(ctx context.Context, keys ...string) error {
	return r.c.Del(ctx, keys...).Err()
}

func (r redisClientOps) ZAdd(ctx context.Context, key string, members ...redis.Z) error {
	return r.c.ZAdd(ctx, key, members...).Err()
}

func (r redisClientOps) Rename(ctx context.Context, key string, newkey string) error {
	return r.c.Rename(ctx, key, newkey).Err()
}

func (r redisClientOps) ZRevRangeWithScores(ctx context.Context, key string, start int64, stop int64) ([]redis.Z, error) {
	return r.c.ZRevRangeWithScores(ctx, key, start, stop).Result()
}

func (r redisClientOps) ZRevRank(ctx context.Context, key string, member string) (int64, error) {
	return r.c.ZRevRank(ctx, key, member).Result()
}

func (r redisClientOps) ZScore(ctx context.Context, key string, member string) (float64, error) {
	return r.c.ZScore(ctx, key, member).Result()
}

type Ranking string

const (
	RankingXP      Ranking = "xp"
	RankingStreak  Ranking = "streak"
	RankingWeekly  Ranking = "weekly"
	RankingAllTime Ranking = "all_time"
)

const redisKey = "lb:xp"

type Row struct {
	Rank                  int    `json:"rank"`
	DisplayNameOrInitials string `json:"display_name_or_initials"`
	AvatarSeed            string `json:"avatar_seed"`
	TotalXP               int64  `json:"total_xp"`
	Level                 int32  `json:"level"`
	UserID                string `json:"user_id"`
}

type ListResponse struct {
	Ranking        Ranking `json:"ranking"`
	GeneratedAtUTC string  `json:"generated_at_utc"`
	Top            []Row   `json:"top"`
}

type SelfResponse struct {
	Ranking Ranking   `json:"ranking"`
	User    *SelfRank `json:"user"`
}

type SelfRank struct {
	Rank    *int  `json:"rank"`
	TotalXP int64 `json:"total_xp"`
	Level   int32 `json:"level"`
}

func NewService(store *repository.Store, rdb *redis.Client, clk clock.Clock, xpSvc *xp.Service) (*Service, error) {
	if store == nil {
		return nil, fmt.Errorf("store is required")
	}
	if rdb == nil {
		return nil, fmt.Errorf("redis is required")
	}
	if clk == nil {
		return nil, fmt.Errorf("clock is required")
	}
	if xpSvc == nil {
		return nil, fmt.Errorf("xp service is required")
	}

	return &Service{
		store: store,
		redis: redisClientOps{c: rdb},
		clock: clk,
		xp:    xpSvc,
	}, nil
}

func (s *Service) Refresh(ctx context.Context) error {
	rows, err := s.store.Queries().GetLeaderboardXPMetrics(ctx)
	if err != nil {
		return fmt.Errorf("get xp metrics: %w", err)
	}

	if err := s.writeZSet(ctx, redisKey, rows); err != nil {
		return fmt.Errorf("write xp zset: %w", err)
	}

	_ = s.redis.Del(ctx, "lb:streak", "lb:weekly", "lb:all_time")

	return nil
}

func (s *Service) writeZSet(ctx context.Context, key string, rows []sqlcgen.GetLeaderboardXPMetricsRow) error {
	tmp := key + ":tmp"

	if err := s.redis.Del(ctx, tmp); err != nil {
		return err
	}

	if len(rows) == 0 {
		if err := s.redis.Del(ctx, key); err != nil {
			return err
		}
		return nil
	}

	zs := make([]redis.Z, 0, len(rows))
	for _, r := range rows {
		zs = append(zs, redis.Z{Score: float64(r.TotalXp), Member: r.UserID.String()})
	}

	if err := s.redis.ZAdd(ctx, tmp, zs...); err != nil {
		return err
	}

	if err := s.redis.Rename(ctx, tmp, key); err != nil {
		if errors.Is(err, redis.Nil) {
			return nil
		}
		return err
	}

	return nil
}

func (s *Service) List(ctx context.Context, ranking Ranking, limit int) (ListResponse, error) {
	_ = normalizeRanking(ranking)
	if limit <= 0 || limit > 50 {
		limit = 50
	}

	zs, err := s.redis.ZRevRangeWithScores(ctx, redisKey, 0, int64(limit-1))
	if err != nil {
		return ListResponse{}, fmt.Errorf("redis zrevrange: %w", err)
	}

	ids := make([]uuid.UUID, 0, len(zs))
	totalXPs := make([]int64, 0, len(zs))
	for _, z := range zs {
		sid, ok := z.Member.(string)
		if !ok {
			continue
		}
		id, err := uuid.Parse(sid)
		if err != nil {
			continue
		}
		ids = append(ids, id)
		totalXPs = append(totalXPs, int64(z.Score))
	}

	users, err := s.store.Queries().GetUsersByIDs(ctx, ids)
	if err != nil {
		return ListResponse{}, fmt.Errorf("get users: %w", err)
	}
	userMap := make(map[uuid.UUID]sqlcgen.GetUsersByIDsRow, len(users))
	for _, u := range users {
		userMap[u.ID] = u
	}

	top := make([]Row, 0, len(ids))
	rank := 1
	for i, id := range ids {
		u, ok := userMap[id]
		if !ok {
			continue
		}
		name := u.DisplayName
		if u.LeaderboardInitialsOnly {
			name = initials(name)
		}
		totalXP := totalXPs[i]
		level := s.xp.LevelFromTotalXP(totalXP)
		top = append(top, Row{
			Rank:                  rank,
			DisplayNameOrInitials: name,
			AvatarSeed:            u.AvatarSeed,
			TotalXP:               totalXP,
			Level:                 level,
			UserID:                id.String(),
		})
		rank++
	}

	return ListResponse{
		Ranking:        RankingXP,
		GeneratedAtUTC: s.clock.Now().UTC().Format(time.RFC3339),
		Top:            top,
	}, nil
}

func (s *Service) Self(ctx context.Context, userID uuid.UUID, ranking Ranking) (SelfResponse, error) {
	_ = normalizeRanking(ranking)

	rankRes, rankErr := s.redis.ZRevRank(ctx, redisKey, userID.String())
	if rankErr != nil && !errors.Is(rankErr, redis.Nil) {
		return SelfResponse{}, fmt.Errorf("redis rank: %w", rankErr)
	}

	scoreRes, scoreErr := s.redis.ZScore(ctx, redisKey, userID.String())
	if scoreErr != nil && !errors.Is(scoreErr, redis.Nil) {
		return SelfResponse{}, fmt.Errorf("redis score: %w", scoreErr)
	}

	var rank *int
	if rankErr == nil {
		v := int(rankRes) + 1
		rank = &v
	}

	totalXP := int64(scoreRes)
	level := s.xp.LevelFromTotalXP(totalXP)

	return SelfResponse{
		Ranking: RankingXP,
		User: &SelfRank{
			Rank:    rank,
			TotalXP: totalXP,
			Level:   level,
		},
	}, nil
}

func normalizeRanking(r Ranking) Ranking {
	return RankingXP
}

func initials(name string) string {
	name = strings.TrimSpace(name)
	if name == "" {
		return "U"
	}

	var parts []string
	var b strings.Builder
	for _, r := range name {
		if unicode.IsSpace(r) {
			if b.Len() > 0 {
				parts = append(parts, b.String())
				b.Reset()
			}
			continue
		}
		if unicode.IsLetter(r) || unicode.IsNumber(r) {
			b.WriteRune(r)
		}
	}
	if b.Len() > 0 {
		parts = append(parts, b.String())
	}

	if len(parts) == 0 {
		return "U"
	}

	first := []rune(parts[0])
	if len(first) == 0 {
		return "U"
	}

	out := strings.ToUpper(string(first[0]))
	if len(parts) > 1 {
		second := []rune(parts[1])
		if len(second) > 0 {
			out += strings.ToUpper(string(second[0]))
		}
	}

	return out
}
