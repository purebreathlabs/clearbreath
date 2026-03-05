package stats

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
)

type Service struct {
	store *repository.Store
	clock clock.Clock
}

type WeeklyBreakdown struct {
	WeekOffset         int
	WeekStartLocal     time.Time
	WeeklyMinutesByDay []int32
	UpdatedAt          time.Time
}

func NewService(store *repository.Store, clk clock.Clock) (*Service, error) {
	if store == nil {
		return nil, fmt.Errorf("store is required")
	}
	if clk == nil {
		return nil, fmt.Errorf("clock is required")
	}
	return &Service{store: store, clock: clk}, nil
}

func (s *Service) GetSnapshot(ctx context.Context, userID uuid.UUID) (sqlcgen.StatsSnapshot, error) {
	snap, err := s.store.Queries().GetStatsSnapshot(ctx, userID)
	if err == nil {
		return snap, nil
	}

	if !errors.Is(err, pgx.ErrNoRows) {
		return sqlcgen.StatsSnapshot{}, fmt.Errorf("get stats snapshot: %w", err)
	}

	return s.Recompute(ctx, userID)
}

func (s *Service) Recompute(ctx context.Context, userID uuid.UUID) (sqlcgen.StatsSnapshot, error) {
	now := s.clock.Now().UTC()
	var out sqlcgen.StatsSnapshot

	if err := s.store.InTx(ctx, func(q *sqlcgen.Queries) error {
		u, err := q.GetUserByID(ctx, userID)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.New(http.StatusUnauthorized, "unauthorized", "unauthorized")
			}
			return fmt.Errorf("get user: %w", err)
		}

		snap, err := computeAndUpsert(ctx, q, userID, now, u.TimezoneOffsetMinutesLatest)
		if err != nil {
			return err
		}
		out = snap
		return nil
	}); err != nil {
		return sqlcgen.StatsSnapshot{}, err
	}

	return out, nil
}

func (s *Service) GetWeeklyBreakdown(ctx context.Context, userID uuid.UUID, weekOffset int) (WeeklyBreakdown, error) {
	now := s.clock.Now().UTC()
	var out WeeklyBreakdown

	if err := s.store.InTx(ctx, func(q *sqlcgen.Queries) error {
		u, err := q.GetUserByID(ctx, userID)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.New(http.StatusUnauthorized, "unauthorized", "unauthorized")
			}
			return fmt.Errorf("get user: %w", err)
		}

		breakdown, err := s.GetWeeklyBreakdownTx(
			ctx,
			q,
			userID,
			weekOffset,
			now,
			u.TimezoneOffsetMinutesLatest,
		)
		if err != nil {
			return err
		}
		out = breakdown
		return nil
	}); err != nil {
		return WeeklyBreakdown{}, err
	}

	return out, nil
}

func (s *Service) ComputeAndUpsertTx(ctx context.Context, q *sqlcgen.Queries, userID uuid.UUID, now time.Time, timezoneOffsetMinutes int32) (sqlcgen.StatsSnapshot, error) {
	return computeAndUpsert(ctx, q, userID, now, timezoneOffsetMinutes)
}

func (s *Service) GetWeeklyBreakdownTx(ctx context.Context, q *sqlcgen.Queries, userID uuid.UUID, weekOffset int, now time.Time, timezoneOffsetMinutes int32) (WeeklyBreakdown, error) {
	if q == nil {
		return WeeklyBreakdown{}, fmt.Errorf("queries are required")
	}
	if weekOffset < -52 || weekOffset > 0 {
		return WeeklyBreakdown{}, apierr.New(http.StatusBadRequest, "validation", "week_offset is invalid")
	}

	weekStart, weekEnd := weeklyWindow(now, timezoneOffsetMinutes, weekOffset)
	rows, err := q.GetSessionDayTotalsInRange(ctx, sqlcgen.GetSessionDayTotalsInRangeParams{
		UserID:     userID,
		LocalDay:   weekStart,
		LocalDay_2: weekEnd,
	})
	if err != nil {
		return WeeklyBreakdown{}, fmt.Errorf("get session day totals in range: %w", err)
	}

	return WeeklyBreakdown{
		WeekOffset:         weekOffset,
		WeekStartLocal:     weekStart,
		WeeklyMinutesByDay: buildWeeklyMinutesByDay(rows, weekStart),
		UpdatedAt:          now.UTC(),
	}, nil
}

func computeAndUpsert(ctx context.Context, q *sqlcgen.Queries, userID uuid.UUID, now time.Time, timezoneOffsetMinutes int32) (sqlcgen.StatsSnapshot, error) {
	localNow := now.UTC().Add(time.Duration(timezoneOffsetMinutes) * time.Minute)
	today := dateOnly(localNow)
	weekStart := isoWeekStartMonday(today)
	weekEnd := weekStart.AddDate(0, 0, 7)

	totalSeconds, err := q.GetTotalSessionSeconds(ctx, userID)
	if err != nil {
		return sqlcgen.StatsSnapshot{}, fmt.Errorf("get total seconds: %w", err)
	}
	sessionCount, err := q.GetSessionCount(ctx, userID)
	if err != nil {
		return sqlcgen.StatsSnapshot{}, fmt.Errorf("get session count: %w", err)
	}
	weekSeconds, err := q.GetSessionSecondsInRange(ctx, sqlcgen.GetSessionSecondsInRangeParams{
		UserID:     userID,
		LocalDay:   weekStart,
		LocalDay_2: weekEnd,
	})
	if err != nil {
		return sqlcgen.StatsSnapshot{}, fmt.Errorf("get week seconds: %w", err)
	}

	minutesByTechnique, err := q.GetTechniqueTotals(ctx, userID)
	if err != nil {
		return sqlcgen.StatsSnapshot{}, fmt.Errorf("get technique totals: %w", err)
	}
	minutesMap := make(map[string]int32, len(minutesByTechnique))
	for _, row := range minutesByTechnique {
		minutesMap[row.TechniqueID] = int32(row.TotalSeconds / 60)
	}
	minutesJSON, err := json.Marshal(minutesMap)
	if err != nil {
		return sqlcgen.StatsSnapshot{}, fmt.Errorf("encode minutes map: %w", err)
	}

	dayTotals, err := q.GetSessionDayTotals(ctx, userID)
	if err != nil {
		return sqlcgen.StatsSnapshot{}, fmt.Errorf("get day totals: %w", err)
	}

	qualifying := make(map[time.Time]bool, len(dayTotals))
	var practiceDaysAllTime int32
	for _, row := range dayTotals {
		d := dateOnly(row.LocalDay)
		ok := row.TotalSeconds >= 120
		qualifying[d] = ok
		if ok {
			practiceDaysAllTime++
		}
	}

	currentStreak := computeCurrentStreak(qualifying, today)
	longestStreak := computeLongestStreak(qualifying)

	snap, err := q.UpsertStatsSnapshot(ctx, sqlcgen.UpsertStatsSnapshotParams{
		UserID:              userID,
		CurrentStreakDays:   int32(currentStreak),
		LongestStreakDays:   int32(longestStreak),
		PracticeDaysAllTime: practiceDaysAllTime,
		MinutesThisWeek:     int32(weekSeconds / 60),
		MinutesAllTime:      int32(totalSeconds / 60),
		SessionsAllTime:     int32(sessionCount),
		MinutesByTechnique:  minutesJSON,
	})
	if err != nil {
		return sqlcgen.StatsSnapshot{}, fmt.Errorf("upsert stats snapshot: %w", err)
	}

	return snap, nil
}

func computeCurrentStreak(qualifying map[time.Time]bool, today time.Time) int {
	end := today
	if !qualifying[end] {
		yesterday := end.AddDate(0, 0, -1)
		if qualifying[yesterday] {
			end = yesterday
		} else {
			return 0
		}
	}

	streak := 0
	for d := end; qualifying[d]; d = d.AddDate(0, 0, -1) {
		streak++
	}
	return streak
}

func CurrentStreakAtDay(qualifying map[time.Time]bool, day time.Time) int32 {
	day = dateOnly(day)

	end := day
	if !qualifying[end] {
		yesterday := end.AddDate(0, 0, -1)
		if qualifying[yesterday] {
			end = yesterday
		} else {
			return 0
		}
	}

	var streak int32
	for d := end; qualifying[d]; d = d.AddDate(0, 0, -1) {
		streak++
	}
	return streak
}

func computeLongestStreak(qualifying map[time.Time]bool) int {
	dates := make([]time.Time, 0, len(qualifying))
	for d, ok := range qualifying {
		if ok {
			dates = append(dates, d)
		}
	}
	if len(dates) == 0 {
		return 0
	}

	sortTimes(dates)

	best := 1
	cur := 1
	for i := 1; i < len(dates); i++ {
		if dates[i].Equal(dates[i-1].AddDate(0, 0, 1)) {
			cur++
			if cur > best {
				best = cur
			}
			continue
		}
		cur = 1
	}
	return best
}

func dateOnly(t time.Time) time.Time {
	t = t.UTC()
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
}

func isoWeekStartMonday(date time.Time) time.Time {
	d := dateOnly(date)
	weekday := int(d.Weekday())
	if weekday == 0 {
		weekday = 7
	}
	return d.AddDate(0, 0, -(weekday - 1))
}

func weeklyWindow(now time.Time, timezoneOffsetMinutes int32, weekOffset int) (time.Time, time.Time) {
	localNow := now.UTC().Add(time.Duration(timezoneOffsetMinutes) * time.Minute)
	today := dateOnly(localNow)
	weekStart := isoWeekStartMonday(today).AddDate(0, 0, weekOffset*7)
	return weekStart, weekStart.AddDate(0, 0, 7)
}

func buildWeeklyMinutesByDay(rows []sqlcgen.GetSessionDayTotalsInRangeRow, weekStart time.Time) []int32 {
	weekly := make([]int32, 7)
	for _, row := range rows {
		day := dateOnly(row.LocalDay)
		dayOffset := int(day.Sub(weekStart).Hours() / 24)
		if dayOffset < 0 || dayOffset >= len(weekly) {
			continue
		}
		minutes := row.TotalSeconds / 60
		if minutes < 0 {
			minutes = 0
		}
		weekly[dayOffset] = int32(minutes)
	}
	return weekly
}

func sortTimes(ts []time.Time) {
	for i := 1; i < len(ts); i++ {
		j := i
		for j > 0 && ts[j].Before(ts[j-1]) {
			ts[j], ts[j-1] = ts[j-1], ts[j]
			j--
		}
	}
}
