package handler

import (
	"errors"
	"net/http"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/httpx"
	"github.com/clearbreath/server/internal/middleware"
	"github.com/clearbreath/server/internal/repository"
	statssvc "github.com/clearbreath/server/internal/service/stats"
)

type StatsHandler struct {
	svc   *statssvc.Service
	store *repository.Store
}

type statsWithXPResponse struct {
	statsSnapshotResponse
	TotalXP      int64 `json:"total_xp"`
	CurrentLevel int32 `json:"current_level"`
}

type weeklyBreakdownResponse struct {
	WeekOffset         int     `json:"week_offset"`
	WeekStartLocal     string  `json:"week_start_local"`
	WeeklyMinutesByDay []int32 `json:"weekly_minutes_by_day"`
	UpdatedAtUTC       string  `json:"updated_at_utc"`
}

func NewStatsHandler(svc *statssvc.Service, store *repository.Store) *StatsHandler {
	return &StatsHandler{svc: svc, store: store}
}

func (h *StatsHandler) Snapshot(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	snap, err := h.svc.GetSnapshot(r.Context(), userID)
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	weekly, err := h.svc.GetWeeklyBreakdown(r.Context(), userID, 0)
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	snapResp, err := toStatsSnapshotResponse(snap, weekly.WeeklyMinutesByDay)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	var totalXP int64
	var currentLevel int32
	prog, err := h.store.Queries().GetUserProgress(r.Context(), userID)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}
	if err == nil {
		totalXP = prog.TotalXp
		currentLevel = prog.CurrentLevel
	}

	httpx.WriteJSON(w, http.StatusOK, statsWithXPResponse{
		statsSnapshotResponse: snapResp,
		TotalXP:               totalXP,
		CurrentLevel:          currentLevel,
	})
}

func (h *StatsHandler) Weekly(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	weekOffset := 0
	if v := r.URL.Query().Get("week_offset"); v != "" {
		n, err := strconv.Atoi(v)
		if err != nil || n < -52 || n > 0 {
			httpx.WriteError(w, http.StatusBadRequest, "validation", "week_offset is invalid", requestID)
			return
		}
		weekOffset = n
	}

	weekly, err := h.svc.GetWeeklyBreakdown(r.Context(), userID, weekOffset)
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, weeklyBreakdownResponse{
		WeekOffset:         weekly.WeekOffset,
		WeekStartLocal:     weekly.WeekStartLocal.Format("2006-01-02"),
		WeeklyMinutesByDay: normalizedWeeklyMinutesByDay(weekly.WeeklyMinutesByDay),
		UpdatedAtUTC:       weekly.UpdatedAt.UTC().Format(time.RFC3339),
	})
}
