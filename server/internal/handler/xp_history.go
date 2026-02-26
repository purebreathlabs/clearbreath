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
	"github.com/clearbreath/server/internal/repository/sqlcgen"
	"github.com/clearbreath/server/internal/service/xp"
)

type XPHistoryHandler struct {
	xp    *xp.Service
	store *repository.Store
}

type xpHistoryResponse struct {
	TotalXP      int64        `json:"total_xp"`
	CurrentLevel int32        `json:"current_level"`
	Days         []xpDayEntry `json:"days"`
}

type xpDayEntry struct {
	LocalDay   string `json:"local_day"`
	TotalXP    int32  `json:"total_xp"`
	PracticeXP int32  `json:"practice_xp"`
	LoginXP    int32  `json:"login_xp"`
}

func NewXPHistoryHandler(xpSvc *xp.Service, store *repository.Store) *XPHistoryHandler {
	return &XPHistoryHandler{xp: xpSvc, store: store}
}

func (h *XPHistoryHandler) History(w http.ResponseWriter, r *http.Request) {
	requestID := middleware.RequestIDFromContext(r.Context())
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized", "unauthorized", requestID)
		return
	}

	days := 7
	if v := r.URL.Query().Get("days"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 && n <= 30 {
			days = n
		}
	}

	tzOffset := int32(0)
	if v := r.URL.Query().Get("timezone_offset_minutes"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n >= -840 && n <= 840 {
			tzOffset = int32(n)
		}
	}

	now := time.Now().UTC()
	localNow := now.Add(time.Duration(tzOffset) * time.Minute)
	localToday := time.Date(localNow.Year(), localNow.Month(), localNow.Day(), 0, 0, 0, 0, time.UTC)
	fromDay := localToday.AddDate(0, 0, -(days - 1))

	history, err := h.store.Queries().GetDailyXPHistory(r.Context(), sqlcgen.GetDailyXPHistoryParams{
		UserID:   userID,
		LocalDay: fromDay,
	})
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}

	dayEntries := make([]xpDayEntry, 0, len(history))
	for _, row := range history {
		dayEntries = append(dayEntries, xpDayEntry{
			LocalDay:   row.LocalDay.Format("2006-01-02"),
			TotalXP:    row.TotalXp,
			PracticeXP: row.PracticeXp,
			LoginXP:    row.LoginXp,
		})
	}

	// Get current progress
	var totalXP int64
	var currentLevel int32
	prog, err := h.store.Queries().GetUserProgress(r.Context(), userID)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		if e, ok := apierr.As(err); ok {
			httpx.WriteError(w, e.Status, e.Code, e.Message, requestID)
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "internal", "internal server error", requestID)
		return
	}
	if err == nil {
		totalXP = prog.TotalXp
		currentLevel = prog.CurrentLevel
	}

	httpx.WriteJSON(w, http.StatusOK, xpHistoryResponse{
		TotalXP:      totalXP,
		CurrentLevel: currentLevel,
		Days:         dayEntries,
	})
}
