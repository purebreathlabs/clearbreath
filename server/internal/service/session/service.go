package session

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"sort"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
	"github.com/clearbreath/server/internal/service/stats"
	"github.com/clearbreath/server/internal/service/xp"
	"github.com/clearbreath/server/internal/technique"
)

type Service struct {
	store         *repository.Store
	stats         *stats.Service
	xp            *xp.Service
	registry      *technique.Registry
	clock         clock.Clock
	maxSubmit     int
	maxSync       int
	onAfterIngest func()
}

type SessionInput struct {
	ClientSessionID           string
	TechniqueID               string
	PresetID                  string
	StartedAtUTC              time.Time
	EndedAtUTC                time.Time
	TimezoneOffsetMinutes     int32
	BreathsCompletedEstimated int32
	EndedEarly                bool
}

type RejectedSession struct {
	ClientSessionID string `json:"client_session_id"`
	Code            string `json:"code"`
	Message         string `json:"message"`
}

type IngestResult struct {
	AcceptedCount  int                   `json:"accepted_count"`
	DuplicateCount int                   `json:"duplicate_count"`
	Rejected       []RejectedSession     `json:"rejected"`
	StatsSnapshot  sqlcgen.StatsSnapshot `json:"stats_snapshot"`
	XPAwards       []xp.XPAward          `json:"xp_awards"`
	TotalXP        int64                 `json:"total_xp"`
	CurrentLevel   int32                 `json:"current_level"`
}

func NewService(store *repository.Store, registry *technique.Registry, statsSvc *stats.Service, xpSvc *xp.Service, clk clock.Clock) (*Service, error) {
	if store == nil {
		return nil, fmt.Errorf("store is required")
	}
	if registry == nil {
		return nil, fmt.Errorf("registry is required")
	}
	if statsSvc == nil {
		return nil, fmt.Errorf("stats service is required")
	}
	if xpSvc == nil {
		return nil, fmt.Errorf("xp service is required")
	}
	if clk == nil {
		return nil, fmt.Errorf("clock is required")
	}

	return &Service{
		store:     store,
		registry:  registry,
		stats:     statsSvc,
		xp:        xpSvc,
		clock:     clk,
		maxSubmit: 200,
		maxSync:   500,
	}, nil
}

func (s *Service) SetOnAfterIngest(fn func()) {
	s.onAfterIngest = fn
}

func (s *Service) Submit(ctx context.Context, userID uuid.UUID, sessions []SessionInput) (IngestResult, error) {
	return s.ingest(ctx, userID, sessions, s.maxSubmit)
}

func (s *Service) Sync(ctx context.Context, userID uuid.UUID, sessions []SessionInput) (IngestResult, error) {
	return s.ingest(ctx, userID, sessions, s.maxSync)
}

func (s *Service) ingest(ctx context.Context, userID uuid.UUID, sessions []SessionInput, max int) (IngestResult, error) {
	if len(sessions) == 0 {
		return IngestResult{}, apierr.New(http.StatusBadRequest, "validation", "sessions is required")
	}
	if len(sessions) > max {
		return IngestResult{}, apierr.New(http.StatusRequestEntityTooLarge, "payload_too_large", "too many sessions")
	}

	now := s.clock.Now().UTC()
	out := IngestResult{
		Rejected: make([]RejectedSession, 0),
		XPAwards: make([]xp.XPAward, 0),
	}

	if err := s.store.InTx(ctx, func(q *sqlcgen.Queries) error {
		u, err := q.GetUserByID(ctx, userID)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.New(http.StatusUnauthorized, "unauthorized", "unauthorized")
			}
			return fmt.Errorf("get user: %w", err)
		}

		tzOffset := u.TimezoneOffsetMinutesLatest
		latestEnded := time.Time{}
		latestOffset := tzOffset

		var accepted []acceptedSession

		for _, in := range sessions {
			preset, ok := s.registry.Preset(in.TechniqueID, in.PresetID)
			if !ok {
				out.Rejected = append(out.Rejected, RejectedSession{
					ClientSessionID: in.ClientSessionID,
					Code:            "validation",
					Message:         "unknown technique_id or preset_id",
				})
				continue
			}

			norm, rej := normalizeSession(in, preset, now)
			if rej != nil {
				out.Rejected = append(out.Rejected, *rej)
				continue
			}

			if norm.EndedAtUtc.After(latestEnded) {
				latestEnded = norm.EndedAtUtc
				latestOffset = norm.TimezoneOffsetMinutes
			}

			affected, err := q.InsertSession(ctx, sqlcgen.InsertSessionParams{
				UserID:                    userID,
				ClientSessionID:           norm.ClientSessionID,
				TechniqueID:               norm.TechniqueID,
				PresetID:                  norm.PresetID,
				StartedAtUtc:              norm.StartedAtUtc,
				EndedAtUtc:                norm.EndedAtUtc,
				TimezoneOffsetMinutes:     norm.TimezoneOffsetMinutes,
				LocalDay:                  norm.LocalDay,
				DurationSecondsActual:     norm.DurationSecondsActual,
				BreathsCompletedEstimated: norm.BreathsCompletedEstimated,
				EndedEarly:                norm.EndedEarly,
			})
			if err != nil {
				return fmt.Errorf("insert session: %w", err)
			}
			if affected == 0 {
				out.DuplicateCount++
			} else {
				out.AcceptedCount++
				accepted = append(accepted, acceptedSession{
					clientSessionID: norm.ClientSessionID,
					startedAtUTC:    norm.StartedAtUtc,
				})
			}
		}

		if !latestEnded.IsZero() && latestOffset != tzOffset {
			updated, err := q.UpdateUserTimezoneOffset(ctx, sqlcgen.UpdateUserTimezoneOffsetParams{
				ID:                          userID,
				TimezoneOffsetMinutesLatest: latestOffset,
			})
			if err != nil {
				return fmt.Errorf("update timezone offset: %w", err)
			}
			tzOffset = updated.TimezoneOffsetMinutesLatest
		}

		snap, err := s.stats.ComputeAndUpsertTx(ctx, q, userID, now, tzOffset)
		if err != nil {
			return err
		}
		out.StatsSnapshot = snap

		dayTotals, err := q.GetSessionDayTotals(ctx, userID)
		if err != nil {
			return fmt.Errorf("get day totals for xp: %w", err)
		}
		qualifying := make(map[time.Time]bool, len(dayTotals))
		for _, row := range dayTotals {
			qualifying[dateOnlyUTC(row.LocalDay)] = row.TotalSeconds >= 120
		}

		streakByDay := map[time.Time]int32{}

		sortAccepted(accepted)
		for _, a := range accepted {
			sess, err := q.GetSessionByClientID(ctx, a.clientSessionID)
			if err != nil {
				return fmt.Errorf("get session for xp: %w", err)
			}

			localDay := dateOnlyUTC(sess.LocalDay)
			streakDays, ok := streakByDay[localDay]
			if !ok {
				streakDays = stats.CurrentStreakAtDay(qualifying, localDay)
				streakByDay[localDay] = streakDays
			}

			award, err := s.xp.AwardSessionXP(
				ctx, q, userID, sess.ID,
				sess.DurationSecondsActual, sess.EndedEarly,
				streakDays, sess.LocalDay,
			)
			if err != nil {
				return fmt.Errorf("award session xp: %w", err)
			}
			if award.Amount > 0 || award.DailyCapped {
				out.XPAwards = append(out.XPAwards, award)
			}
		}

		if len(accepted) > 0 {
			_, _, err := s.xp.RecomputeTotalXP(ctx, q, userID)
			if err != nil {
				return fmt.Errorf("recompute total xp: %w", err)
			}
		}

		prog, err := q.GetUserProgress(ctx, userID)
		if err != nil && !errors.Is(err, pgx.ErrNoRows) {
			return fmt.Errorf("get user progress: %w", err)
		}
		if err == nil {
			out.TotalXP = prog.TotalXp
			out.CurrentLevel = prog.CurrentLevel
		}

		return nil
	}); err != nil {
		return IngestResult{}, err
	}

	if s.onAfterIngest != nil && out.AcceptedCount > 0 {
		go s.onAfterIngest()
	}

	return out, nil
}

type normalizedSession struct {
	ClientSessionID           uuid.UUID
	TechniqueID               string
	PresetID                  string
	StartedAtUtc              time.Time
	EndedAtUtc                time.Time
	TimezoneOffsetMinutes     int32
	LocalDay                  time.Time
	DurationSecondsActual     int32
	BreathsCompletedEstimated int32
	EndedEarly                bool
}

const (
	maxFutureWindow = 24 * time.Hour
	maxPastWindow   = 90 * 24 * time.Hour
)

func normalizeSession(in SessionInput, preset technique.Preset, now time.Time) (normalizedSession, *RejectedSession) {
	rawID := strings.TrimSpace(in.ClientSessionID)
	if rawID == "" {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: "",
			Code:            "validation",
			Message:         "client_session_id is required",
		}
	}
	clientSessionID, err := uuid.Parse(rawID)
	if err != nil {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: rawID,
			Code:            "validation",
			Message:         "client_session_id is invalid",
		}
	}
	if in.TimezoneOffsetMinutes < -840 || in.TimezoneOffsetMinutes > 840 {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: rawID,
			Code:            "validation",
			Message:         "timezone_offset_minutes is invalid",
		}
	}

	started := in.StartedAtUTC.UTC()
	ended := in.EndedAtUTC.UTC()
	if started.IsZero() || ended.IsZero() || ended.Before(started) {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: rawID,
			Code:            "validation",
			Message:         "timestamps are invalid",
		}
	}

	now = now.UTC()
	if started.After(now.Add(maxFutureWindow)) {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: rawID,
			Code:            "plausibility",
			Message:         "started_at_utc is too far in the future",
		}
	}
	if started.Before(now.Add(-maxPastWindow)) {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: rawID,
			Code:            "plausibility",
			Message:         "started_at_utc is too far in the past",
		}
	}

	durSeconds := int(ended.Sub(started).Seconds())
	if durSeconds <= 0 {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: rawID,
			Code:            "validation",
			Message:         "duration is invalid",
		}
	}

	if durSeconds > preset.MaxDurationSeconds {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: rawID,
			Code:            "plausibility",
			Message:         "duration exceeds preset max",
		}
	}

	if !in.EndedEarly && durSeconds < preset.MinDurationSeconds {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: rawID,
			Code:            "plausibility",
			Message:         "duration below preset min",
		}
	}

	if in.EndedEarly && durSeconds < 10 {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: rawID,
			Code:            "plausibility",
			Message:         "duration too short",
		}
	}

	if in.BreathsCompletedEstimated < 0 {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: rawID,
			Code:            "validation",
			Message:         "breaths_completed_estimated is invalid",
		}
	}

	breaths := clampBreathsEstimate(int(in.BreathsCompletedEstimated), durSeconds, preset)
	if breaths < 0 {
		return normalizedSession{}, &RejectedSession{
			ClientSessionID: rawID,
			Code:            "plausibility",
			Message:         "breaths estimate not plausible",
		}
	}

	localStart := started.Add(time.Duration(in.TimezoneOffsetMinutes) * time.Minute)
	localDay := time.Date(localStart.Year(), localStart.Month(), localStart.Day(), 0, 0, 0, 0, time.UTC)

	return normalizedSession{
		ClientSessionID:           clientSessionID,
		TechniqueID:               in.TechniqueID,
		PresetID:                  in.PresetID,
		StartedAtUtc:              started,
		EndedAtUtc:                ended,
		TimezoneOffsetMinutes:     in.TimezoneOffsetMinutes,
		LocalDay:                  localDay,
		DurationSecondsActual:     int32(durSeconds),
		BreathsCompletedEstimated: int32(breaths),
		EndedEarly:                in.EndedEarly,
	}, nil
}

type acceptedSession struct {
	clientSessionID uuid.UUID
	startedAtUTC    time.Time
}

func sortAccepted(a []acceptedSession) {
	sort.Slice(a, func(i, j int) bool {
		return a[i].startedAtUTC.Before(a[j].startedAtUTC)
	})
}

func clampBreathsEstimate(breaths int, durationSeconds int, preset technique.Preset) int {
	if breaths == 0 || durationSeconds <= 0 {
		return breaths
	}

	minBreaths := int(preset.MinBreathsPerMinute * float64(durationSeconds) / 60.0)
	maxBreaths := int(preset.MaxBreathsPerMinute*float64(durationSeconds)/60.0 + 0.9999)
	if minBreaths < 0 {
		minBreaths = 0
	}
	if maxBreaths < minBreaths {
		maxBreaths = minBreaths
	}

	if breaths < int(float64(minBreaths)*0.5) || breaths > int(float64(maxBreaths)*1.5) {
		return -1
	}

	if breaths < minBreaths {
		return minBreaths
	}
	if breaths > maxBreaths {
		return maxBreaths
	}
	return breaths
}

func dateOnlyUTC(t time.Time) time.Time {
	t = t.UTC()
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
}
