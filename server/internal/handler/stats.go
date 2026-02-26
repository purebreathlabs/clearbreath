package handler

import (
	"errors"
	"net/http"

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

	snapResp, err := toStatsSnapshotResponse(snap)
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
