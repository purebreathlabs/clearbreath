package handler

import (
	"net/http"
	"time"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/httpx"
	"github.com/clearbreath/server/internal/middleware"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
	usersvc "github.com/clearbreath/server/internal/service/user"
)

type MeHandler struct {
	svc *usersvc.Service
}

type patchMeRequest struct {
	DisplayName             *string `json:"display_name"`
	LeaderboardOptIn        *bool   `json:"leaderboard_opt_in"`
	LeaderboardInitialsOnly *bool   `json:"leaderboard_initials_only"`
}

type meResponse struct {
	ID                          string `json:"id"`
	DisplayName                 string `json:"display_name"`
	AvatarSeed                  string `json:"avatar_seed"`
	LeaderboardOptIn            bool   `json:"leaderboard_opt_in"`
	LeaderboardInitialsOnly     bool   `json:"leaderboard_initials_only"`
	CreatedAtUTC                string `json:"created_at_utc"`
	TimezoneOffsetMinutesLatest int32  `json:"timezone_offset_minutes_latest"`
}

func NewMeHandler(svc *usersvc.Service) *MeHandler {
	return &MeHandler{svc: svc}
}

func (h *MeHandler) Get(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	u, err := h.svc.GetProfile(r.Context(), userID)
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, toMeResponse(u))
}

func (h *MeHandler) Patch(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	var req patchMeRequest
	if err := httpx.DecodeJSON(w, r, 32*1024, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "invalid request body", requestID)
		return
	}

	u, err := h.svc.UpdateProfile(r.Context(), userID, usersvc.UpdateInput{
		DisplayName:             req.DisplayName,
		LeaderboardOptIn:        req.LeaderboardOptIn,
		LeaderboardInitialsOnly: req.LeaderboardInitialsOnly,
	})
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, toMeResponse(u))
}

func (h *MeHandler) Delete(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	if err := h.svc.DeleteAccount(r.Context(), userID); err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func toMeResponse(u sqlcgen.User) meResponse {
	return meResponse{
		ID:                          u.ID.String(),
		DisplayName:                 u.DisplayName,
		AvatarSeed:                  u.AvatarSeed,
		LeaderboardOptIn:            u.LeaderboardOptIn,
		LeaderboardInitialsOnly:     u.LeaderboardInitialsOnly,
		CreatedAtUTC:                u.CreatedAt.UTC().Format(time.RFC3339),
		TimezoneOffsetMinutesLatest: u.TimezoneOffsetMinutesLatest,
	}
}
