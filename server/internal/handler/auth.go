package handler

import (
	"net/http"
	"time"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/httpx"
	"github.com/clearbreath/server/internal/middleware"
	authsvc "github.com/clearbreath/server/internal/service/auth"
)

type AuthHandler struct {
	svc *authsvc.Service
}

type providerSignInRequest struct {
	Provider  string `json:"provider"`
	IDToken   string `json:"id_token"`
	DeviceID  string `json:"device_id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Email     string `json:"email"`
}

type refreshRequest struct {
	RefreshToken string `json:"refresh_token"`
	DeviceID     string `json:"device_id"`
}

type logoutRequest struct {
	DeviceID string `json:"device_id"`
}

type authResponse struct {
	AccessToken              string      `json:"access_token"`
	AccessTokenExpiresAtUTC  string      `json:"access_token_expires_at_utc"`
	RefreshToken             string      `json:"refresh_token"`
	RefreshTokenExpiresAtUTC string      `json:"refresh_token_expires_at_utc"`
	User                     userProfile `json:"user"`
}

type userProfile struct {
	ID                          string `json:"id"`
	Username                    string `json:"username"`
	Name                        string `json:"name"`
	AvatarSeed                  string `json:"avatar_seed"`
	LeaderboardOptIn            bool   `json:"leaderboard_opt_in"`
	CreatedAtUTC                string `json:"created_at_utc"`
	TimezoneOffsetMinutesLatest int32  `json:"timezone_offset_minutes_latest"`
}

func NewAuthHandler(svc *authsvc.Service) *AuthHandler {
	return &AuthHandler{svc: svc}
}

func (h *AuthHandler) ProviderSignIn(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	var req providerSignInRequest
	if err := httpx.DecodeJSON(w, r, 32*1024, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "invalid request body", requestID)
		return
	}

	out, err := h.svc.ProviderSignIn(r.Context(), authsvc.ProviderSignInInput{
		Provider:      req.Provider,
		IDToken:       req.IDToken,
		DeviceID:      req.DeviceID,
		DevAuthHeader: r.Header.Get("X-Dev-Auth"),
		FirstName:     req.FirstName,
		LastName:      req.LastName,
		Email:         req.Email,
	})
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, toAuthResponse(out))
}

func (h *AuthHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	var req refreshRequest
	if err := httpx.DecodeJSON(w, r, 16*1024, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "invalid request body", requestID)
		return
	}

	out, err := h.svc.Refresh(r.Context(), authsvc.RefreshInput{
		RefreshToken: req.RefreshToken,
		DeviceID:     req.DeviceID,
	})
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, toAuthResponse(out))
}

func (h *AuthHandler) Logout(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	var req logoutRequest
	if err := httpx.DecodeJSON(w, r, 8*1024, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "invalid request body", requestID)
		return
	}

	if err := h.svc.Logout(r.Context(), userID, req.DeviceID); err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func toAuthResponse(out *authsvc.AuthResult) authResponse {
	return authResponse{
		AccessToken:              out.AccessToken,
		AccessTokenExpiresAtUTC:  out.AccessTokenExpiresAtUTC.UTC().Format(time.RFC3339),
		RefreshToken:             out.RefreshToken,
		RefreshTokenExpiresAtUTC: out.RefreshTokenExpiresAtUTC.UTC().Format(time.RFC3339),
		User: userProfile{
			ID:                          out.User.ID.String(),
			Username:                    out.User.Username,
			Name:                        out.User.Name,
			AvatarSeed:                  out.User.AvatarSeed,
			LeaderboardOptIn:            out.User.LeaderboardOptIn,
			CreatedAtUTC:                out.User.CreatedAtUTC.UTC().Format(time.RFC3339),
			TimezoneOffsetMinutesLatest: out.User.TimezoneOffsetMinutes,
		},
	}
}
