package handler

import (
	"net/http"
	"strconv"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/httpx"
	"github.com/clearbreath/server/internal/middleware"
	lbsvc "github.com/clearbreath/server/internal/service/leaderboard"
)

type LeaderboardHandler struct {
	svc *lbsvc.Service
}

func NewLeaderboardHandler(svc *lbsvc.Service) *LeaderboardHandler {
	return &LeaderboardHandler{svc: svc}
}

func (h *LeaderboardHandler) List(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	ranking := lbsvc.Ranking(r.URL.Query().Get("ranking"))
	limit := 50
	if v := r.URL.Query().Get("limit"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			limit = n
		}
	}

	out, err := h.svc.List(r.Context(), ranking, limit)
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, out)
}

func (h *LeaderboardHandler) Self(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	ranking := lbsvc.Ranking(r.URL.Query().Get("ranking"))
	out, err := h.svc.Self(r.Context(), userID, ranking)
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, out)
}
