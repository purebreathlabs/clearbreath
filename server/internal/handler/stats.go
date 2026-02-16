package handler

import (
	"net/http"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/httpx"
	"github.com/clearbreath/server/internal/middleware"
	statssvc "github.com/clearbreath/server/internal/service/stats"
)

type StatsHandler struct {
	svc *statssvc.Service
}

func NewStatsHandler(svc *statssvc.Service) *StatsHandler {
	return &StatsHandler{svc: svc}
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

	resp, err := toStatsSnapshotResponse(snap)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, resp)
}
