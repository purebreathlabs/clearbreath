package handler

import (
	"net/http"
	"time"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/httpx"
	"github.com/clearbreath/server/internal/middleware"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
	"github.com/clearbreath/server/internal/service/xp"
)

type DailyLoginHandler struct {
	xp    *xp.Service
	store *repository.Store
}

type dailyOpenRequest struct {
	TimezoneOffsetMinutes int32 `json:"timezone_offset_minutes"`
}

type dailyOpenResponse struct {
	Awarded      bool        `json:"awarded"`
	XPAward      *xp.XPAward `json:"xp_award,omitempty"`
	TotalXP      int64       `json:"total_xp"`
	CurrentLevel int32       `json:"current_level"`
}

func NewDailyLoginHandler(xpSvc *xp.Service, store *repository.Store) *DailyLoginHandler {
	return &DailyLoginHandler{xp: xpSvc, store: store}
}

func (h *DailyLoginHandler) DailyOpen(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	var req dailyOpenRequest
	if err := httpx.DecodeJSON(w, r, 16*1024, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "invalid request body", requestID)
		return
	}

	if req.TimezoneOffsetMinutes < -840 || req.TimezoneOffsetMinutes > 840 {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "timezone_offset_minutes is invalid", requestID)
		return
	}

	now := time.Now().UTC()
	localNow := now.Add(time.Duration(req.TimezoneOffsetMinutes) * time.Minute)
	localDay := time.Date(localNow.Year(), localNow.Month(), localNow.Day(), 0, 0, 0, 0, time.UTC)

	var resp dailyOpenResponse

	if err := h.store.InTx(r.Context(), func(q *sqlcgen.Queries) error {
		award, awarded, err := h.xp.AwardDailyOpenXP(r.Context(), q, userID, localDay)
		if err != nil {
			return err
		}
		resp.Awarded = awarded
		resp.TotalXP = award.NewTotalXP
		resp.CurrentLevel = award.NewLevel
		if awarded {
			resp.XPAward = &award
		}
		return nil
	}); err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, resp)
}
