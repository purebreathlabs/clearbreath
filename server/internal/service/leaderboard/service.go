package leaderboard

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"
	"unicode"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
)

type Service struct {
	store        *repository.Store
	redis        redisOps
	clock        clock.Clock
	dailyCapMins int64
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
	RankingStreak  Ranking = "streak"
	RankingWeekly  Ranking = "weekly"
	RankingAllTime Ranking = "all_time"
)

type Row struct {
	Rank                  int    `json:"rank"`
	DisplayNameOrInitials string `json:"display_name_or_initials"`
	AvatarSeed            string `json:"avatar_seed"`
	MetricValue           int64  `json:"metric_value"`
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
	Rank        *int  `json:"rank"`
	MetricValue int64 `json:"metric_value"`
}

func NewService(store *repository.Store, rdb *redis.Client, clk clock.Clock, dailyCapMinutes int) (*Service, error) {
	if store == nil {
		return nil, fmt.Errorf("store is required")
	}
	if rdb == nil {
		return nil, fmt.Errorf("redis is required")
	}
	if clk == nil {
		return nil, fmt.Errorf("clock is required")
	}
	if dailyCapMinutes <= 0 {
		return nil, fmt.Errorf("daily cap must be positive")
	}

	return &Service{
		store:        store,
		redis:        redisClientOps{c: rdb},
		clock:        clk,
		dailyCapMins: int64(dailyCapMinutes),
	}, nil
}

func (s *Service) Refresh(ctx context.Context) error {
	now := s.clock.Now().UTC()

	streak, err := s.store.Queries().GetLeaderboardStreakMetrics(ctx)
	if err != nil {
		return fmt.Errorf("get streak metrics: %w", err)
	}
	if err := s.writeZSet(ctx, "lb:streak", streak); err != nil {
		return fmt.Errorf("write streak zset: %w", err)
	}

	weekly, err := s.store.Queries().GetLeaderboardWeeklyMinutesMetrics(ctx, sqlcgen.GetLeaderboardWeeklyMinutesMetricsParams{
		Column1: now,
		Column2: s.dailyCapMins,
	})
	if err != nil {
		return fmt.Errorf("get weekly metrics: %w", err)
	}
	if err := s.writeZSet(ctx, "lb:weekly", weekly); err != nil {
		return fmt.Errorf("write weekly zset: %w", err)
	}

	allTime, err := s.store.Queries().GetLeaderboardAllTimeMinutesMetrics(ctx, s.dailyCapMins)
	if err != nil {
		return fmt.Errorf("get all_time metrics: %w", err)
	}
	if err := s.writeZSet(ctx, "lb:all_time", allTime); err != nil {
		return fmt.Errorf("write all_time zset: %w", err)
	}

	return nil
}

func (s *Service) writeZSet(ctx context.Context, key string, rows any) error {
	tmp := key + ":tmp"

	if err := s.redis.Del(ctx, tmp); err != nil {
		return err
	}

	var zs []redis.Z

	switch v := rows.(type) {
	case []sqlcgen.GetLeaderboardStreakMetricsRow:
		zs = make([]redis.Z, 0, len(v))
		for _, r := range v {
			zs = append(zs, redis.Z{Score: float64(r.MetricValue), Member: r.UserID.String()})
		}
	case []sqlcgen.GetLeaderboardWeeklyMinutesMetricsRow:
		zs = make([]redis.Z, 0, len(v))
		for _, r := range v {
			zs = append(zs, redis.Z{Score: float64(r.MetricValue), Member: r.UserID.String()})
		}
	case []sqlcgen.GetLeaderboardAllTimeMinutesMetricsRow:
		zs = make([]redis.Z, 0, len(v))
		for _, r := range v {
			zs = append(zs, redis.Z{Score: float64(r.MetricValue), Member: r.UserID.String()})
		}
	default:
		return fmt.Errorf("unsupported rows type")
	}

	if len(zs) == 0 {
		if err := s.redis.Del(ctx, key); err != nil {
			return err
		}
		return nil
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
	r, err := parseRanking(ranking)
	if err != nil {
		return ListResponse{}, err
	}
	if limit <= 0 || limit > 50 {
		limit = 50
	}

	key := rankingKey(r)
	zs, err := s.redis.ZRevRangeWithScores(ctx, key, 0, int64(limit-1))
	if err != nil {
		return ListResponse{}, fmt.Errorf("redis zrevrange: %w", err)
	}

	ids := make([]uuid.UUID, 0, len(zs))
	metrics := make([]int64, 0, len(zs))
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
		metrics = append(metrics, int64(z.Score))
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
		top = append(top, Row{
			Rank:                  rank,
			DisplayNameOrInitials: name,
			AvatarSeed:            u.AvatarSeed,
			MetricValue:           metrics[i],
			UserID:                id.String(),
		})
		rank++
	}

	return ListResponse{
		Ranking:        r,
		GeneratedAtUTC: s.clock.Now().UTC().Format(time.RFC3339),
		Top:            top,
	}, nil
}

func (s *Service) Self(ctx context.Context, userID uuid.UUID, ranking Ranking) (SelfResponse, error) {
	r, err := parseRanking(ranking)
	if err != nil {
		return SelfResponse{}, err
	}

	key := rankingKey(r)
	rankRes, rankErr := s.redis.ZRevRank(ctx, key, userID.String())
	if rankErr != nil && !errors.Is(rankErr, redis.Nil) {
		return SelfResponse{}, fmt.Errorf("redis rank: %w", rankErr)
	}

	scoreRes, scoreErr := s.redis.ZScore(ctx, key, userID.String())
	if scoreErr != nil && !errors.Is(scoreErr, redis.Nil) {
		return SelfResponse{}, fmt.Errorf("redis score: %w", scoreErr)
	}

	var rank *int
	if rankErr == nil {
		v := int(rankRes) + 1
		rank = &v
	}

	metric := int64(scoreRes)

	return SelfResponse{
		Ranking: r,
		User: &SelfRank{
			Rank:        rank,
			MetricValue: metric,
		},
	}, nil
}

func parseRanking(r Ranking) (Ranking, error) {
	switch r {
	case RankingStreak, RankingWeekly, RankingAllTime:
		return r, nil
	default:
		return "", apierr.New(http.StatusBadRequest, "validation", "invalid ranking")
	}
}

func rankingKey(r Ranking) string {
	switch r {
	case RankingStreak:
		return "lb:streak"
	case RankingWeekly:
		return "lb:weekly"
	case RankingAllTime:
		return "lb:all_time"
	default:
		return "lb:streak"
	}
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
	if len(parts) == 0 || len(first) == 0 {
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
