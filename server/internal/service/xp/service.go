package xp

import (
	"context"
	"errors"
	"fmt"
	"math"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
)

const (
	XPPerFullMinute     = 10
	DailyOpenXP         = 5
	EndedEarlyPenalty   = 0.5
	DailyPracticeXPCap  = 300
	MaxStreakMultiplier = 3.0
	CurveVersion        = 1
	MaxLevel            = 999
)

type XPAward struct {
	Amount      int32   `json:"amount"`
	BaseAmount  int32   `json:"base_amount"`
	Multiplier  float64 `json:"multiplier"`
	Source      string  `json:"source"`
	DailyCapped bool    `json:"daily_capped"`
	NewTotalXP  int64   `json:"new_total_xp"`
	NewLevel    int32   `json:"new_level"`
	PrevLevel   int32   `json:"prev_level"`
	LeveledUp   bool    `json:"leveled_up"`
}

type Service struct {
	store      *repository.Store
	clock      clock.Clock
	thresholds []int64
}

func NewService(store *repository.Store, clk clock.Clock) *Service {
	s := &Service{
		store: store,
		clock: clk,
	}
	s.thresholds = buildLevelThresholds()
	return s
}

func buildLevelThresholds() []int64 {
	t := make([]int64, MaxLevel+2)
	t[0] = 0
	var cumulative int64
	for k := 0; k <= MaxLevel; k++ {
		xpForLevel := int64(math.Floor(2.0 + 0.05*float64(k) + 0.0001*float64(k)*float64(k)))
		cumulative += xpForLevel
		t[k+1] = cumulative
	}
	return t
}

func (s *Service) LevelFromTotalXP(totalXP int64) int32 {
	lo, hi := 0, len(s.thresholds)-1
	for lo < hi {
		mid := (lo + hi + 1) / 2
		if s.thresholds[mid] <= totalXP {
			lo = mid
		} else {
			hi = mid - 1
		}
	}
	if lo > MaxLevel {
		return int32(MaxLevel)
	}
	return int32(lo)
}

func (s *Service) CumulativeXPForLevel(level int32) int64 {
	if level < 0 {
		return 0
	}
	if int(level) >= len(s.thresholds) {
		return s.thresholds[len(s.thresholds)-1]
	}
	return s.thresholds[level]
}

func (s *Service) XPForNextLevel(level int32) int64 {
	if level < 0 || int(level+1) >= len(s.thresholds) {
		return 0
	}
	return s.thresholds[level+1] - s.thresholds[level]
}

func StreakMultiplier(streakDays int32) float64 {
	return math.Min(1.0+0.1*float64(streakDays), MaxStreakMultiplier)
}

func PresetForLevel(level int32) string {
	if level < 15 {
		return "beginner"
	}
	if level < 50 {
		return "intermediate"
	}
	return "advanced"
}

func DurationMinutesForLevel(level int32) int {
	if level < 10 {
		return 2
	}
	if level < 30 {
		return 5
	}
	if level < 60 {
		return 10
	}
	if level < 100 {
		return 15
	}
	return 20
}

func (s *Service) AwardSessionXP(
	ctx context.Context,
	q *sqlcgen.Queries,
	userID uuid.UUID,
	sessionID uuid.UUID,
	durationSecs int32,
	endedEarly bool,
	streakDays int32,
	localDay time.Time,
) (XPAward, error) {
	baseMinutes := int(durationSecs / 60)
	if endedEarly {
		baseMinutes = int(math.Floor(float64(baseMinutes) * EndedEarlyPenalty))
	}
	baseXP := int32(baseMinutes * XPPerFullMinute)
	if baseXP <= 0 {
		return XPAward{Source: "session"}, nil
	}

	multiplier := StreakMultiplier(streakDays)
	rawAmount := int32(math.Floor(float64(baseXP) * multiplier))

	dailySoFar, err := q.GetDailyPracticeXP(ctx, sqlcgen.GetDailyPracticeXPParams{
		UserID:   userID,
		LocalDay: localDay,
	})
	if err != nil {
		return XPAward{}, fmt.Errorf("get daily practice xp: %w", err)
	}

	remaining := int32(DailyPracticeXPCap) - dailySoFar
	if remaining <= 0 {
		return XPAward{Source: "session", DailyCapped: true}, nil
	}

	amount := rawAmount
	dailyCapped := false
	if amount > remaining {
		amount = remaining
		dailyCapped = true
	}

	prevLevel := int32(0)
	if prog, err := q.GetUserProgress(ctx, userID); err == nil {
		prevLevel = prog.CurrentLevel
	}

	if _, err := q.InsertXPEvent(ctx, sqlcgen.InsertXPEventParams{
		UserID:       userID,
		Source:       "session",
		Amount:       amount,
		Multiplier:   numericFromFloat(multiplier),
		BaseAmount:   baseXP,
		SessionID:    pgtype.UUID{Bytes: sessionID, Valid: true},
		LocalDay:     localDay,
		CurveVersion: CurveVersion,
	}); err != nil {
		if isUniqueViolation(err) {
			return XPAward{Source: "session"}, nil
		}
		return XPAward{}, fmt.Errorf("insert xp event: %w", err)
	}

	totalXP, err := q.GetTotalXP(ctx, userID)
	if err != nil {
		return XPAward{}, fmt.Errorf("get total xp: %w", err)
	}
	newLevel := s.LevelFromTotalXP(totalXP)

	if _, err := q.UpsertUserProgress(ctx, sqlcgen.UpsertUserProgressParams{
		UserID:       userID,
		TotalXp:      totalXP,
		CurrentLevel: newLevel,
		CurveVersion: CurveVersion,
	}); err != nil {
		return XPAward{}, fmt.Errorf("upsert user progress: %w", err)
	}

	return XPAward{
		Amount:      amount,
		BaseAmount:  baseXP,
		Multiplier:  multiplier,
		Source:      "session",
		DailyCapped: dailyCapped,
		NewTotalXP:  totalXP,
		NewLevel:    newLevel,
		PrevLevel:   prevLevel,
		LeveledUp:   newLevel > prevLevel,
	}, nil
}

func (s *Service) AwardDailyOpenXP(
	ctx context.Context,
	q *sqlcgen.Queries,
	userID uuid.UUID,
	localDay time.Time,
) (XPAward, bool, error) {
	already, err := q.HasDailyOpenXP(ctx, sqlcgen.HasDailyOpenXPParams{
		UserID:   userID,
		LocalDay: localDay,
	})
	if err != nil {
		return XPAward{}, false, fmt.Errorf("check daily open: %w", err)
	}
	if already {
		prog, err := q.GetUserProgress(ctx, userID)
		if err != nil {
			return XPAward{Source: "daily_open"}, false, nil
		}
		return XPAward{
			Source:     "daily_open",
			NewTotalXP: prog.TotalXp,
			NewLevel:   prog.CurrentLevel,
			PrevLevel:  prog.CurrentLevel,
		}, false, nil
	}

	prevLevel := int32(0)
	if prog, err := q.GetUserProgress(ctx, userID); err == nil {
		prevLevel = prog.CurrentLevel
	}

	if _, err := q.InsertXPEvent(ctx, sqlcgen.InsertXPEventParams{
		UserID:       userID,
		Source:       "daily_open",
		Amount:       DailyOpenXP,
		Multiplier:   numericFromFloat(1.0),
		BaseAmount:   DailyOpenXP,
		SessionID:    pgtype.UUID{Valid: false},
		LocalDay:     localDay,
		CurveVersion: CurveVersion,
	}); err != nil {
		if isUniqueViolation(err) {
			prog, progErr := q.GetUserProgress(ctx, userID)
			if progErr != nil {
				if errors.Is(progErr, pgx.ErrNoRows) {
					return XPAward{Source: "daily_open"}, false, nil
				}
				return XPAward{}, false, fmt.Errorf("get progress after race: %w", progErr)
			}
			return XPAward{
				Source:     "daily_open",
				NewTotalXP: prog.TotalXp,
				NewLevel:   prog.CurrentLevel,
				PrevLevel:  prog.CurrentLevel,
			}, false, nil
		}
		return XPAward{}, false, fmt.Errorf("insert daily open xp: %w", err)
	}

	totalXP, err := q.GetTotalXP(ctx, userID)
	if err != nil {
		return XPAward{}, false, fmt.Errorf("get total xp: %w", err)
	}
	newLevel := s.LevelFromTotalXP(totalXP)

	if _, err := q.UpsertUserProgress(ctx, sqlcgen.UpsertUserProgressParams{
		UserID:       userID,
		TotalXp:      totalXP,
		CurrentLevel: newLevel,
		CurveVersion: CurveVersion,
	}); err != nil {
		return XPAward{}, false, fmt.Errorf("upsert user progress: %w", err)
	}

	return XPAward{
		Amount:     DailyOpenXP,
		BaseAmount: DailyOpenXP,
		Multiplier: 1.0,
		Source:     "daily_open",
		NewTotalXP: totalXP,
		NewLevel:   newLevel,
		PrevLevel:  prevLevel,
		LeveledUp:  newLevel > prevLevel,
	}, true, nil
}

func (s *Service) RecomputeTotalXP(
	ctx context.Context,
	q *sqlcgen.Queries,
	userID uuid.UUID,
) (int64, int32, error) {
	totalXP, err := q.GetTotalXP(ctx, userID)
	if err != nil {
		return 0, 0, fmt.Errorf("get total xp: %w", err)
	}

	level := s.LevelFromTotalXP(totalXP)

	if _, err := q.UpsertUserProgress(ctx, sqlcgen.UpsertUserProgressParams{
		UserID:       userID,
		TotalXp:      totalXP,
		CurrentLevel: level,
		CurveVersion: CurveVersion,
	}); err != nil {
		return 0, 0, fmt.Errorf("upsert user progress: %w", err)
	}

	return totalXP, level, nil
}

func isUniqueViolation(err error) bool {
	var pgErr *pgconn.PgError
	return errors.As(err, &pgErr) && pgErr.Code == "23505"
}

func numericFromFloat(f float64) pgtype.Numeric {
	var n pgtype.Numeric
	_ = n.Scan(fmt.Sprintf("%.2f", f))
	return n
}
