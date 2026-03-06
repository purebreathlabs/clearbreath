package handler

import (
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/httpx"
	"github.com/clearbreath/server/internal/middleware"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
	notifsvc "github.com/clearbreath/server/internal/service/notification"
)

type NotificationHandler struct {
	svc *notifsvc.Service
}

type upsertInstallationRequest struct {
	DeviceID              string `json:"device_id"`
	Platform              string `json:"platform"`
	FCMToken              string `json:"fcm_token"`
	PermissionStatus      string `json:"permission_status"`
	ReminderEnabled       *bool  `json:"reminder_enabled"`
	ReminderTimeMinutes   *int32 `json:"reminder_time_minutes"`
	StreakWarningEnabled  *bool  `json:"streak_warning_enabled"`
	TimezoneIANA          string `json:"timezone_iana"`
	TimezoneOffsetMinutes int32  `json:"timezone_offset_minutes"`
	AppVersion            string `json:"app_version"`
	BuildNumber           string `json:"build_number"`
	Locale                string `json:"locale"`
}

type installationResponse struct {
	DeviceID              string  `json:"device_id"`
	UserID                *string `json:"user_id"`
	Platform              string  `json:"platform"`
	PermissionStatus      string  `json:"permission_status"`
	ReminderEnabled       bool    `json:"reminder_enabled"`
	ReminderTimeMinutes   int32   `json:"reminder_time_minutes"`
	StreakWarningEnabled  bool    `json:"streak_warning_enabled"`
	TimezoneIANA          string  `json:"timezone_iana"`
	TimezoneOffsetMinutes int32   `json:"timezone_offset_minutes"`
	AppVersion            string  `json:"app_version"`
	BuildNumber           string  `json:"build_number"`
	Locale                string  `json:"locale"`
	LastSeenAt            string  `json:"last_seen_at"`
	CreatedAt             string  `json:"created_at"`
	UpdatedAt             string  `json:"updated_at"`
}

type testSendRequest struct {
	DeviceID string `json:"device_id"`
	Kind     string `json:"kind"`
	Title    string `json:"title"`
	Body     string `json:"body"`
}

type devDispatchRequest struct {
	NowUTC string `json:"now_utc"`
}

type devDispatchResponse struct {
	DailySent  int `json:"daily_sent"`
	StreakSent int `json:"streak_sent"`
}

func NewNotificationHandler(svc *notifsvc.Service) *NotificationHandler {
	return &NotificationHandler{svc: svc}
}

func (h *NotificationHandler) UpsertInstallation(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	var req upsertInstallationRequest
	if err := httpx.DecodeJSON(w, r, 32*1024, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "invalid request body", requestID)
		return
	}

	reminderEnabled := true
	if req.ReminderEnabled != nil {
		reminderEnabled = *req.ReminderEnabled
	}
	reminderTimeMinutes := int32(480)
	if req.ReminderTimeMinutes != nil {
		reminderTimeMinutes = *req.ReminderTimeMinutes
	}
	streakWarningEnabled := true
	if req.StreakWarningEnabled != nil {
		streakWarningEnabled = *req.StreakWarningEnabled
	}

	// Extract user_id from context if present (OptionalAuth)
	var userID *uuid.UUID
	if uid, ok := auth.UserIDFromContext(r.Context()); ok {
		userID = &uid
	}

	inst, err := h.svc.UpsertInstallation(r.Context(), notifsvc.UpsertInput{
		DeviceID:              req.DeviceID,
		UserID:                userID,
		Platform:              req.Platform,
		FCMToken:              req.FCMToken,
		PermissionStatus:      req.PermissionStatus,
		ReminderEnabled:       reminderEnabled,
		ReminderTimeMinutes:   reminderTimeMinutes,
		StreakWarningEnabled:  streakWarningEnabled,
		TimezoneIANA:          req.TimezoneIANA,
		TimezoneOffsetMinutes: req.TimezoneOffsetMinutes,
		AppVersion:            req.AppVersion,
		BuildNumber:           req.BuildNumber,
		Locale:                req.Locale,
	})
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, toInstallationResponse(inst))
}

func (h *NotificationHandler) GetInstallation(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	deviceID := r.URL.Query().Get("device_id")

	inst, err := h.svc.GetInstallation(r.Context(), deviceID)
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusNotFound, "not_found", "installation not found", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, toInstallationResponse(inst))
}

func (h *NotificationHandler) BindInstallation(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	var req upsertInstallationRequest
	if err := httpx.DecodeJSON(w, r, 32*1024, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "invalid request body", requestID)
		return
	}

	reminderEnabled := true
	if req.ReminderEnabled != nil {
		reminderEnabled = *req.ReminderEnabled
	}
	reminderTimeMinutes := int32(480)
	if req.ReminderTimeMinutes != nil {
		reminderTimeMinutes = *req.ReminderTimeMinutes
	}
	streakWarningEnabled := true
	if req.StreakWarningEnabled != nil {
		streakWarningEnabled = *req.StreakWarningEnabled
	}

	inst, err := h.svc.UpsertInstallation(r.Context(), notifsvc.UpsertInput{
		DeviceID:              req.DeviceID,
		UserID:                &userID,
		Platform:              req.Platform,
		FCMToken:              req.FCMToken,
		PermissionStatus:      req.PermissionStatus,
		ReminderEnabled:       reminderEnabled,
		ReminderTimeMinutes:   reminderTimeMinutes,
		StreakWarningEnabled:  streakWarningEnabled,
		TimezoneIANA:          req.TimezoneIANA,
		TimezoneOffsetMinutes: req.TimezoneOffsetMinutes,
		AppVersion:            req.AppVersion,
		BuildNumber:           req.BuildNumber,
		Locale:                req.Locale,
	})
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, toInstallationResponse(inst))
}

func (h *NotificationHandler) UnbindInstallation(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	deviceID := chi.URLParam(r, "deviceID")
	if err := h.svc.UnbindFromUser(r.Context(), deviceID, userID); err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *NotificationHandler) TestSend(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	var req testSendRequest
	if err := httpx.DecodeJSON(w, r, 8*1024, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "invalid request body", requestID)
		return
	}

	if err := h.svc.SendTest(r.Context(), req.DeviceID, req.Kind, req.Title, req.Body); err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]string{"status": "sent"})
}

func (h *NotificationHandler) DevDispatch(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	var req devDispatchRequest
	if err := httpx.DecodeJSON(w, r, 8*1024, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "invalid request body", requestID)
		return
	}

	nowUTC, err := time.Parse(time.RFC3339, req.NowUTC)
	if err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "now_utc must be RFC3339 format", requestID)
		return
	}

	// Use the scheduler's dispatch logic
	daily, streak, err := dispatchDue(r.Context(), h.svc.Store(), h.svc.Sender(), nowUTC)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "dispatch failed", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, devDispatchResponse{
		DailySent:  daily,
		StreakSent: streak,
	})
}

func toInstallationResponse(inst sqlcgen.NotificationInstallation) installationResponse {
	resp := installationResponse{
		DeviceID:              inst.DeviceID,
		Platform:              inst.Platform,
		PermissionStatus:      inst.PermissionStatus,
		ReminderEnabled:       inst.ReminderEnabled,
		ReminderTimeMinutes:   inst.ReminderTimeMinutes,
		StreakWarningEnabled:  inst.StreakWarningEnabled,
		TimezoneIANA:          inst.TimezoneIana,
		TimezoneOffsetMinutes: inst.TimezoneOffsetMinutes,
		AppVersion:            inst.AppVersion,
		BuildNumber:           inst.BuildNumber,
		Locale:                inst.Locale,
		LastSeenAt:            inst.LastSeenAt.UTC().Format(time.RFC3339),
		CreatedAt:             inst.CreatedAt.UTC().Format(time.RFC3339),
		UpdatedAt:             inst.UpdatedAt.UTC().Format(time.RFC3339),
	}
	if inst.UserID.Valid {
		uid := uuid.UUID(inst.UserID.Bytes).String()
		resp.UserID = &uid
	}
	return resp
}
