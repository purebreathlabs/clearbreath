package main

import (
	"context"
	"database/sql"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/pressly/goose/v3"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/config"
	"github.com/clearbreath/server/internal/dashboard"
	"github.com/clearbreath/server/internal/handler"
	"github.com/clearbreath/server/internal/logcollector"
	"github.com/clearbreath/server/internal/middleware"
	"github.com/clearbreath/server/internal/profanity"
	"github.com/clearbreath/server/internal/repository"
	authsvc "github.com/clearbreath/server/internal/service/auth"
	lbsvc "github.com/clearbreath/server/internal/service/leaderboard"
	safetysvc "github.com/clearbreath/server/internal/service/safety"
	sessionsvc "github.com/clearbreath/server/internal/service/session"
	statssvc "github.com/clearbreath/server/internal/service/stats"
	usersvc "github.com/clearbreath/server/internal/service/user"
	xpsvc "github.com/clearbreath/server/internal/service/xp"
	"github.com/clearbreath/server/internal/technique"
)

var version = "dev"

type redisPinger struct{ c *redis.Client }

func (r redisPinger) Ping(ctx context.Context) error { return r.c.Ping(ctx).Err() }

func main() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, nil)))

	cfg, err := config.Load()
	if err != nil {
		slog.Error("failed to load config", "error", err)
		os.Exit(1)
	}

	appCtx, appCancel := context.WithCancel(context.Background())
	defer appCancel()

	if cfg.Env == "development" {
		if err := migrate(cfg.DatabaseURL); err != nil {
			slog.Error("failed to run migrations", "error", err)
			os.Exit(1)
		}
	}

	pool, err := pgxpool.New(appCtx, cfg.DatabaseURL)
	if err != nil {
		slog.Error("failed to create postgres pool", "error", err)
		os.Exit(1)
	}
	defer pool.Close()

	if err := pool.Ping(appCtx); err != nil {
		slog.Error("failed to ping postgres", "error", err)
		os.Exit(1)
	}
	slog.Info("postgres connected")

	rdb := redis.NewClient(&redis.Options{
		Addr:     cfg.RedisAddr,
		Password: cfg.RedisPassword,
	})
	defer func() { _ = rdb.Close() }()

	if err := rdb.Ping(appCtx).Err(); err != nil {
		slog.Error("failed to ping redis", "error", err)
		os.Exit(1)
	}
	slog.Info("redis connected")

	// Initialize log collector (if dashboard enabled)
	var collector *logcollector.Collector
	if cfg.DashboardEnabled {
		collector = logcollector.New(pool)
		go collector.Run(appCtx)
		go collector.CleanupLoop(appCtx, 30)
		slog.Info("log collector started")
	}

	store := repository.NewStore(pool)
	clk := clock.RealClock{}

	accessTokens, err := auth.NewAccessTokenManager(cfg.JWTAccessSecret, cfg.JWTAccessTTLMinutes)
	if err != nil {
		slog.Error("failed to init access token manager", "error", err)
		os.Exit(1)
	}

	authService, err := authsvc.NewService(store, clk, accessTokens, cfg.JWTRefreshSecret, cfg.JWTRefreshTTLMinutes, cfg.DevAuthEnabled, cfg.DevAuthSecret, cfg.GoogleOAuthClientID, cfg.AppleOAuthAudience, profanity.NewDefault())
	if err != nil {
		slog.Error("failed to init auth service", "error", err)
		os.Exit(1)
	}

	userService, err := usersvc.NewService(store, profanity.NewDefault())
	if err != nil {
		slog.Error("failed to init user service", "error", err)
		os.Exit(1)
	}

	registry, err := technique.Load(cfg.TechniqueRegistryPath)
	if err != nil {
		slog.Error("failed to load technique registry", "error", err)
		os.Exit(1)
	}

	safetyService, err := safetysvc.NewService(store, registry)
	if err != nil {
		slog.Error("failed to init safety service", "error", err)
		os.Exit(1)
	}

	statsService, err := statssvc.NewService(store, clk)
	if err != nil {
		slog.Error("failed to init stats service", "error", err)
		os.Exit(1)
	}

	xpService := xpsvc.NewService(store, clk)

	sessionService, err := sessionsvc.NewService(store, registry, statsService, xpService, clk)
	if err != nil {
		slog.Error("failed to init session service", "error", err)
		os.Exit(1)
	}

	leaderboardService, err := lbsvc.NewService(store, rdb, clk, xpService)
	if err != nil {
		slog.Error("failed to init leaderboard service", "error", err)
		os.Exit(1)
	}

	sessionService.SetOnAfterIngest(func() {
		if err := leaderboardService.Refresh(appCtx); err != nil {
			slog.Error("leaderboard refresh after ingest failed", "error", err)
		}
	})

	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.LoggerWithCollector(collector))
	r.Use(middleware.PanicRecoveryWithCollector(collector))
	r.Use(middleware.CORS(cfg.CORSOrigins))

	health := handler.NewHealthHandler(pool, redisPinger{rdb})
	ready := handler.NewReadyHandler(pool, redisPinger{rdb})
	r.Get("/health", health.Check)
	r.Get("/ready", ready.Check)

	authHandler := handler.NewAuthHandler(authService)
	authRateLimitMin := middleware.RateLimitIP(rdb, "rl:auth:min", cfg.RateLimitAuthBurstPerMin, time.Minute)
	authRateLimitHour := middleware.RateLimitIP(rdb, "rl:auth:hour", cfg.RateLimitAuthPerHour, time.Hour)
	r.Route("/v1/auth", func(r chi.Router) {
		r.With(authRateLimitMin, authRateLimitHour).Post("/provider_sign_in", authHandler.ProviderSignIn)
		r.With(authRateLimitMin, authRateLimitHour).Post("/refresh", authHandler.Refresh)
		r.With(middleware.Auth(accessTokens, store)).Post("/logout", authHandler.Logout)
	})

	meHandler := handler.NewMeHandler(userService)
	r.With(middleware.Auth(accessTokens, store)).Get("/v1/me", meHandler.Get)
	r.With(middleware.Auth(accessTokens, store)).Patch("/v1/me", meHandler.Patch)
	r.With(middleware.AuthAllowDeleted(accessTokens, store)).Delete("/v1/me", meHandler.Delete)

	safetyHandler := handler.NewSafetyAcknowledgementsHandler(safetyService)
	r.With(middleware.Auth(accessTokens, store)).Get("/v1/me/safety_acknowledgements", safetyHandler.Get)
	r.With(middleware.Auth(accessTokens, store)).Post("/v1/me/safety_acknowledgements", safetyHandler.Post)

	dailyLoginHandler := handler.NewDailyLoginHandler(xpService, store)
	r.With(middleware.Auth(accessTokens, store)).Post("/v1/me/daily-open", dailyLoginHandler.DailyOpen)

	sessionsHandler := handler.NewSessionsHandler(sessionService)
	sessionRateLimitDay := middleware.RateLimitUser(rdb, "rl:sessions:day", cfg.RateLimitSessionPerDay, 24*time.Hour)
	r.With(middleware.Auth(accessTokens, store), sessionRateLimitDay).Post("/v1/sessions/submit", sessionsHandler.Submit)
	r.With(middleware.Auth(accessTokens, store), sessionRateLimitDay).Post("/v1/sessions/sync", sessionsHandler.Sync)

	statsHandler := handler.NewStatsHandler(statsService, store)
	r.With(middleware.Auth(accessTokens, store)).Get("/v1/stats/snapshot", statsHandler.Snapshot)

	xpHistoryHandler := handler.NewXPHistoryHandler(xpService, store)
	r.With(middleware.Auth(accessTokens, store)).Get("/v1/xp/history", xpHistoryHandler.History)

	leaderboardHandler := handler.NewLeaderboardHandler(leaderboardService)
	leaderboardRateLimitMin := middleware.RateLimitIP(rdb, "rl:leaderboard:min", cfg.RateLimitLeaderboardPerM, time.Minute)
	r.With(leaderboardRateLimitMin).Get("/v1/leaderboard", leaderboardHandler.List)
	r.With(middleware.Auth(accessTokens, store), leaderboardRateLimitMin).Get("/v1/leaderboard/self", leaderboardHandler.Self)

	// Dashboard routes
	if cfg.DashboardEnabled {
		dash := dashboard.New(pool, rdb, collector.Broadcaster(), cfg)
		r.Route("/dashboard", func(r chi.Router) {
			r.Use(dashboard.HostCheck(cfg.DashboardHost, cfg.Env))
			// Public routes
			r.Get("/login", dash.LoginPage)
			r.Post("/login", dash.LoginSubmit)
			// Protected routes
			r.Group(func(r chi.Router) {
				r.Use(dash.RequireSession)
				r.Get("/", dash.Overview)
				r.Get("/logs", dash.LogsPage)
				r.Get("/errors", dash.ErrorsPage)
				r.Get("/auth-events", dash.AuthEventsPage)
				r.Post("/logout", dash.Logout)
				// HTMX API
				r.Get("/api/logs", dash.LogsAPI)
				r.Get("/api/events", dash.EventsAPI)
				r.Get("/api/stats", dash.StatsAPI)
				// SSE
				r.Get("/sse/logs", dash.SSELogs)
			})
		})
		slog.Info("dashboard enabled", "host", cfg.DashboardHost)
	}

	if err := leaderboardService.Refresh(appCtx); err != nil {
		slog.Error("failed to refresh leaderboard", "error", err)
	}
	go func() {
		ticker := time.NewTicker(5 * time.Minute)
		defer ticker.Stop()
		for {
			select {
			case <-ticker.C:
				if err := leaderboardService.Refresh(appCtx); err != nil {
					slog.Error("leaderboard refresh failed", "error", err)
				}
			case <-appCtx.Done():
				return
			}
		}
	}()

	srv := &http.Server{
		Addr:         ":" + cfg.Port,
		Handler:      r,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 0, // disabled for SSE; individual handlers manage deadlines
		IdleTimeout:  120 * time.Second,
	}

	go func() {
		slog.Info("server starting", "port", cfg.Port, "env", cfg.Env, "version", version)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			slog.Error("server failed", "error", err)
			os.Exit(1)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	slog.Info("shutting down server")
	appCancel()
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(shutdownCtx); err != nil {
		slog.Error("server forced to shutdown", "error", err)
		os.Exit(1)
	}

	slog.Info("server stopped")
}

func migrate(databaseURL string) error {
	db, err := sql.Open("pgx", databaseURL)
	if err != nil {
		return err
	}
	defer func() { _ = db.Close() }()

	if err := goose.SetDialect("postgres"); err != nil {
		return err
	}

	if err := goose.Up(db, "migrations"); err != nil {
		return err
	}

	return nil
}
