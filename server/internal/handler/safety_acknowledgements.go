package handler

import (
	"net/http"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/httpx"
	"github.com/clearbreath/server/internal/middleware"
	safetysvc "github.com/clearbreath/server/internal/service/safety"
)

type SafetyAcknowledgementsHandler struct {
	svc *safetysvc.Service
}

type safetyAcknowledgementsResponse struct {
	TechniqueIDs []string `json:"technique_ids"`
}

type acknowledgeSafetyRequest struct {
	TechniqueIDs []string `json:"technique_ids"`
}

func NewSafetyAcknowledgementsHandler(svc *safetysvc.Service) *SafetyAcknowledgementsHandler {
	return &SafetyAcknowledgementsHandler{svc: svc}
}

func (h *SafetyAcknowledgementsHandler) Get(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	ids, err := h.svc.List(r.Context(), userID)
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, safetyAcknowledgementsResponse{TechniqueIDs: ids})
}

func (h *SafetyAcknowledgementsHandler) Post(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	var req acknowledgeSafetyRequest
	if err := httpx.DecodeJSON(w, r, 32*1024, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "validation", "invalid request body", requestID)
		return
	}

	ids, err := h.svc.Acknowledge(r.Context(), userID, req.TechniqueIDs)
	if err != nil {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, safetyAcknowledgementsResponse{TechniqueIDs: ids})
}
