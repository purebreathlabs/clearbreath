package handler

import (
	"context"
	"encoding/json"
	"net/http"
	"time"
)

type Pinger interface {
	Ping(ctx context.Context) error
}

type HealthHandler struct {
	db    Pinger
	cache Pinger
}

type ReadyHandler struct {
	db    Pinger
	cache Pinger
}

type healthResponse struct {
	Status   string `json:"status"`
	Postgres string `json:"postgres"`
	Redis    string `json:"redis"`
}

func NewHealthHandler(db, cache Pinger) *HealthHandler {
	return &HealthHandler{db: db, cache: cache}
}

func NewReadyHandler(db, cache Pinger) *ReadyHandler {
	return &ReadyHandler{db: db, cache: cache}
}

func checkDependencies(ctx context.Context, db, cache Pinger) (pgStatus string, redisStatus string) {
	pgStatus = "connected"
	if err := db.Ping(ctx); err != nil {
		pgStatus = "disconnected"
	}

	redisStatus = "connected"
	if err := cache.Ping(ctx); err != nil {
		redisStatus = "disconnected"
	}

	return pgStatus, redisStatus
}

func (h *HealthHandler) Check(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 3*time.Second)
	defer cancel()

	pgStatus, redisStatus := checkDependencies(ctx, h.db, h.cache)

	status := "ok"
	if pgStatus != "connected" || redisStatus != "connected" {
		status = "degraded"
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(healthResponse{
		Status:   status,
		Postgres: pgStatus,
		Redis:    redisStatus,
	})
}

func (h *ReadyHandler) Check(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 3*time.Second)
	defer cancel()

	pgStatus, redisStatus := checkDependencies(ctx, h.db, h.cache)

	status := "ok"
	httpCode := http.StatusOK
	if pgStatus != "connected" || redisStatus != "connected" {
		status = "degraded"
		httpCode = http.StatusServiceUnavailable
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(httpCode)
	_ = json.NewEncoder(w).Encode(healthResponse{
		Status:   status,
		Postgres: pgStatus,
		Redis:    redisStatus,
	})
}
