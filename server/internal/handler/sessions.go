package handler

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/httpx"
	"github.com/clearbreath/server/internal/middleware"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
	sessionsvc "github.com/clearbreath/server/internal/service/session"
)

type SessionsHandler struct {
	svc *sessionsvc.Service
}

type ingestSessionsRequest struct {
	Sessions []sessionPayload `json:"sessions"`
}

type sessionPayload struct {
	ClientSessionID           string    `json:"client_session_id"`
	TechniqueID               string    `json:"technique_id"`
	PresetID                  string    `json:"preset_id"`
	StartedAtUTC              time.Time `json:"started_at_utc"`
	EndedAtUTC                time.Time `json:"ended_at_utc"`
	TimezoneOffsetMinutes     int32     `json:"timezone_offset_minutes"`
	BreathsCompletedEstimated int32     `json:"breaths_completed_estimated"`
	EndedEarly                bool      `json:"ended_early"`
	DurationSecondsActual     *int32    `json:"duration_seconds_actual"`
}

type ingestSessionsResponse struct {
	AcceptedCount  int                          `json:"accepted_count"`
	DuplicateCount int                          `json:"duplicate_count"`
	Rejected       []sessionsvc.RejectedSession `json:"rejected"`
	StatsSnapshot  statsSnapshotResponse        `json:"stats_snapshot"`
}

type statsSnapshotResponse struct {
	CurrentStreakDays  int32            `json:"current_streak_days"`
	LongestStreakDays  int32            `json:"longest_streak_days"`
	MinutesThisWeek    int32            `json:"minutes_this_week"`
	MinutesAllTime     int32            `json:"minutes_all_time"`
	SessionsAllTime    int32            `json:"sessions_all_time"`
	MinutesByTechnique map[string]int32 `json:"minutes_by_technique"`
	UpdatedAtUTC       string           `json:"updated_at_utc"`
}

func NewSessionsHandler(svc *sessionsvc.Service) *SessionsHandler {
	return &SessionsHandler{svc: svc}
}

func (h *SessionsHandler) Submit(w http.ResponseWriter, r *http.Request) {
	h.ingest(w, r, false)
}

func (h *SessionsHandler) Sync(w http.ResponseWriter, r *http.Request) {
	h.ingest(w, r, true)
}

func (h *SessionsHandler) ingest(w http.ResponseWriter, r *http.Request, isSync bool) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	var req ingestSessionsRequest
	if err := httpx.DecodeJSON(w, r, 1024*1024, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "invalid request body", requestID)
		return
	}

	input := make([]sessionsvc.SessionInput, 0, len(req.Sessions))
	for _, s := range req.Sessions {
		input = append(input, sessionsvc.SessionInput{
			ClientSessionID:           s.ClientSessionID,
			TechniqueID:               s.TechniqueID,
			PresetID:                  s.PresetID,
			StartedAtUTC:              s.StartedAtUTC,
			EndedAtUTC:                s.EndedAtUTC,
			TimezoneOffsetMinutes:     s.TimezoneOffsetMinutes,
			BreathsCompletedEstimated: s.BreathsCompletedEstimated,
			EndedEarly:                s.EndedEarly,
		})
	}

	var (
		out sessionsvc.IngestResult
		err error
	)
	if isSync {
		out, err = h.svc.Sync(r.Context(), userID, input)
	} else {
		out, err = h.svc.Submit(r.Context(), userID, input)
	}
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	resp, err := toIngestSessionsResponse(out)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, resp)
}

func toIngestSessionsResponse(out sessionsvc.IngestResult) (ingestSessionsResponse, error) {
	snap, err := toStatsSnapshotResponse(out.StatsSnapshot)
	if err != nil {
		return ingestSessionsResponse{}, err
	}

	return ingestSessionsResponse{
		AcceptedCount:  out.AcceptedCount,
		DuplicateCount: out.DuplicateCount,
		Rejected:       out.Rejected,
		StatsSnapshot:  snap,
	}, nil
}

func toStatsSnapshotResponse(s sqlcgen.StatsSnapshot) (statsSnapshotResponse, error) {
	var m map[string]int32
	if err := json.Unmarshal(s.MinutesByTechnique, &m); err != nil {
		return statsSnapshotResponse{}, err
	}
	if m == nil {
		m = map[string]int32{}
	}

	return statsSnapshotResponse{
		CurrentStreakDays:  s.CurrentStreakDays,
		LongestStreakDays:  s.LongestStreakDays,
		MinutesThisWeek:    s.MinutesThisWeek,
		MinutesAllTime:     s.MinutesAllTime,
		SessionsAllTime:    s.SessionsAllTime,
		MinutesByTechnique: m,
		UpdatedAtUTC:       s.UpdatedAt.UTC().Format(time.RFC3339),
	}, nil
}
