package integration

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/config"
	"github.com/clearbreath/server/internal/handler"
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

type httpError struct {
	Error     string `json:"error"`
	Code      string `json:"code"`
	RequestID string `json:"request_id"`
}

type authHTTPResponse struct {
	AccessToken              string `json:"access_token"`
	AccessTokenExpiresAtUTC  string `json:"access_token_expires_at_utc"`
	RefreshToken             string `json:"refresh_token"`
	RefreshTokenExpiresAtUTC string `json:"refresh_token_expires_at_utc"`
	User                     struct {
		ID                          string `json:"id"`
		Username                    string `json:"username"`
		Name                        string `json:"name"`
		AvatarSeed                  string `json:"avatar_seed"`
		LeaderboardOptIn            bool   `json:"leaderboard_opt_in"`
		CreatedAtUTC                string `json:"created_at_utc"`
		TimezoneOffsetMinutesLatest int32  `json:"timezone_offset_minutes_latest"`
	} `json:"user"`
}

type meHTTPResponse struct {
	ID                          string `json:"id"`
	Username                    string `json:"username"`
	Name                        string `json:"name"`
	AvatarSeed                  string `json:"avatar_seed"`
	LeaderboardOptIn            bool   `json:"leaderboard_opt_in"`
	CreatedAtUTC                string `json:"created_at_utc"`
	TimezoneOffsetMinutesLatest int32  `json:"timezone_offset_minutes_latest"`
}

type safetyAcknowledgementsHTTPResponse struct {
	TechniqueIDs []string `json:"technique_ids"`
}

type ingestHTTPResponse struct {
	AcceptedCount  int `json:"accepted_count"`
	DuplicateCount int `json:"duplicate_count"`
	Rejected       []struct {
		ClientSessionID string `json:"client_session_id"`
		Code            string `json:"code"`
		Message         string `json:"message"`
	} `json:"rejected"`
	StatsSnapshot struct {
		CurrentStreakDays  int32            `json:"current_streak_days"`
		LongestStreakDays  int32            `json:"longest_streak_days"`
		MinutesThisWeek    int32            `json:"minutes_this_week"`
		MinutesAllTime     int32            `json:"minutes_all_time"`
		SessionsAllTime    int32            `json:"sessions_all_time"`
		MinutesByTechnique map[string]int32 `json:"minutes_by_technique"`
		WeeklyMinutesByDay []int32          `json:"weekly_minutes_by_day"`
		UpdatedAtUTC       string           `json:"updated_at_utc"`
		TotalXP            int64            `json:"total_xp"`
		CurrentLevel       int32            `json:"current_level"`
	} `json:"stats_snapshot"`
	TotalXP      int64 `json:"total_xp"`
	CurrentLevel int32 `json:"current_level"`
	XPAwards     []struct {
		Amount int32 `json:"amount"`
	} `json:"xp_awards"`
}

type statsHTTPResponse struct {
	CurrentStreakDays  int32            `json:"current_streak_days"`
	LongestStreakDays  int32            `json:"longest_streak_days"`
	MinutesThisWeek    int32            `json:"minutes_this_week"`
	MinutesAllTime     int32            `json:"minutes_all_time"`
	SessionsAllTime    int32            `json:"sessions_all_time"`
	MinutesByTechnique map[string]int32 `json:"minutes_by_technique"`
	WeeklyMinutesByDay []int32          `json:"weekly_minutes_by_day"`
	UpdatedAtUTC       string           `json:"updated_at_utc"`
}

type weeklyBreakdownHTTPResponse struct {
	WeekOffset         int     `json:"week_offset"`
	WeekStartLocal     string  `json:"week_start_local"`
	WeeklyMinutesByDay []int32 `json:"weekly_minutes_by_day"`
	UpdatedAtUTC       string  `json:"updated_at_utc"`
}

type leaderboardHTTPResponse struct {
	Ranking        string `json:"ranking"`
	GeneratedAtUTC string `json:"generated_at_utc"`
	Top            []struct {
		Rank       int     `json:"rank"`
		Username   string  `json:"username"`
		Name       *string `json:"name"`
		AvatarSeed string  `json:"avatar_seed"`
		TotalXP    int64   `json:"total_xp"`
		Level      int32   `json:"level"`
		UserID     string  `json:"user_id"`
	} `json:"top"`
}

type leaderboardSelfHTTPResponse struct {
	Ranking string `json:"ranking"`
	User    struct {
		Rank    *int  `json:"rank"`
		TotalXP int64 `json:"total_xp"`
		Level   int32 `json:"level"`
	} `json:"user"`
}

type redisPinger struct{ c *redis.Client }

func (r redisPinger) Ping(ctx context.Context) error { return r.c.Ping(ctx).Err() }

func doJSON(t *testing.T, c *http.Client, method string, url string, body any, headers map[string]string) (int, http.Header, []byte) {
	t.Helper()

	var buf io.Reader
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			t.Fatalf("marshal: %v", err)
		}
		buf = bytes.NewReader(b)
	}

	req, err := http.NewRequest(method, url, buf)
	if err != nil {
		t.Fatalf("new request: %v", err)
	}
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	for k, v := range headers {
		req.Header.Set(k, v)
	}

	resp, err := c.Do(req)
	if err != nil {
		t.Fatalf("do request: %v", err)
	}
	defer func() { _ = resp.Body.Close() }()

	b, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("read body: %v", err)
	}
	return resp.StatusCode, resp.Header, b
}

func requireRequestID(t *testing.T, h http.Header, body []byte) {
	t.Helper()

	if v := h.Get("X-Request-ID"); v == "" {
		t.Fatalf("missing X-Request-ID")
	}

	var e httpError
	if err := json.Unmarshal(body, &e); err != nil {
		return
	}
	if e.Code != "" && e.RequestID == "" {
		t.Fatalf("missing request_id in error envelope")
	}
}

func TestHTTPAPIContractSmoke(t *testing.T) {
	if os.Getenv("CLEARBREATH_INTEGRATION") != "1" {
		t.Skip("integration disabled")
	}

	if envPath, _ := resolveExistingFilePath(".env", "../../.env"); envPath != "" {
		_ = godotenv.Load(envPath)
	}
	setBaseIntegrationEnv(t)
	t.Setenv("GOOGLE_OAUTH_CLIENT_IDS", "")
	t.Setenv("APPLE_OAUTH_AUDIENCE", "")
	if p := os.Getenv("TECHNIQUE_REGISTRY_PATH"); p == "" || !fileExists(p) {
		registryPath, err := resolveExistingFilePath("registry/techniques.json", "../../registry/techniques.json")
		if err != nil {
			t.Fatalf("resolve technique registry path: %v", err)
		}
		_ = os.Setenv("TECHNIQUE_REGISTRY_PATH", registryPath)
	}
	_ = os.Setenv("RATE_LIMIT_AUTH_BURST_PER_MIN", "1000")
	_ = os.Setenv("RATE_LIMIT_AUTH_PER_HOUR", "1000")

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("load config: %v", err)
	}
	if err := migrate(cfg.DatabaseURL); err != nil {
		t.Fatalf("migrate: %v", err)
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err != nil {
		t.Fatalf("pgxpool: %v", err)
	}
	defer pool.Close()

	rdb := redis.NewClient(&redis.Options{
		Addr:     cfg.RedisAddr,
		Password: cfg.RedisPassword,
	})
	defer func() { _ = rdb.Close() }()

	if err := resetState(ctx, pool, rdb); err != nil {
		t.Fatalf("reset state: %v", err)
	}

	store := repository.NewStore(pool)
	clk := clock.RealClock{}

	accessTokens, err := auth.NewAccessTokenManager(cfg.JWTAccessSecret, cfg.JWTAccessTTLMinutes)
	if err != nil {
		t.Fatalf("access token manager: %v", err)
	}

	authService, err := authsvc.NewService(store, clk, accessTokens, cfg.JWTRefreshSecret, cfg.JWTRefreshTTLMinutes, cfg.DevAuthEnabled, cfg.DevAuthSecret, cfg.GoogleOAuthClientIDs, cfg.AppleOAuthAudience, profanity.NewDefault())
	if err != nil {
		t.Fatalf("auth service: %v", err)
	}

	userService, err := usersvc.NewService(store, profanity.NewDefault())
	if err != nil {
		t.Fatalf("user service: %v", err)
	}

	reg, err := technique.Load(cfg.TechniqueRegistryPath)
	if err != nil {
		t.Fatalf("load registry: %v", err)
	}

	safetyService, err := safetysvc.NewService(store, reg)
	if err != nil {
		t.Fatalf("safety service: %v", err)
	}

	statsService, err := statssvc.NewService(store, clk)
	if err != nil {
		t.Fatalf("stats service: %v", err)
	}

	xpService := xpsvc.NewService(store, clk)

	sessionService, err := sessionsvc.NewService(store, reg, statsService, xpService, clk)
	if err != nil {
		t.Fatalf("session service: %v", err)
	}

	leaderboardService, err := lbsvc.NewService(store, rdb, clk, xpService)
	if err != nil {
		t.Fatalf("leaderboard service: %v", err)
	}

	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.Logger)
	r.Use(middleware.PanicRecovery)
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

	sessionsHandler := handler.NewSessionsHandler(sessionService)
	sessionRateLimitDay := middleware.RateLimitUser(rdb, "rl:sessions:day", cfg.RateLimitSessionPerDay, 24*time.Hour)
	r.With(middleware.Auth(accessTokens, store), sessionRateLimitDay).Post("/v1/sessions/submit", sessionsHandler.Submit)
	r.With(middleware.Auth(accessTokens, store), sessionRateLimitDay).Post("/v1/sessions/sync", sessionsHandler.Sync)

	statsHandler := handler.NewStatsHandler(statsService, store)
	r.With(middleware.Auth(accessTokens, store)).Get("/v1/stats/snapshot", statsHandler.Snapshot)
	r.With(middleware.Auth(accessTokens, store)).Get("/v1/stats/weekly", statsHandler.Weekly)

	leaderboardHandler := handler.NewLeaderboardHandler(leaderboardService)
	leaderboardRateLimitMin := middleware.RateLimitIP(rdb, "rl:leaderboard:min", cfg.RateLimitLeaderboardPerM, time.Minute)
	r.With(leaderboardRateLimitMin).Get("/v1/leaderboard", leaderboardHandler.List)
	r.With(middleware.Auth(accessTokens, store), leaderboardRateLimitMin).Get("/v1/leaderboard/self", leaderboardHandler.Self)

	srv := httptest.NewServer(r)
	defer srv.Close()

	client := srv.Client()

	status, hdr, body := doJSON(t, client, http.MethodGet, srv.URL+"/v1/me", nil, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusUnauthorized {
		t.Fatalf("me missing auth: status %d body %s", status, string(body))
	}

	invalidUserToken, _, err := accessTokens.Issue(uuid.MustParse("4b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11"), time.Now().UTC())
	if err != nil {
		t.Fatalf("issue invalid user token: %v", err)
	}
	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/me", nil, map[string]string{
		"Authorization": "Bearer " + invalidUserToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusUnauthorized {
		t.Fatalf("me invalid user token: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/provider_sign_in", map[string]any{
		"provider":  "dev",
		"id_token":  "user1",
		"device_id": "device1",
	}, map[string]string{
		"X-Dev-Auth": "wrong",
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusUnauthorized {
		t.Fatalf("provider_sign_in wrong dev secret: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/provider_sign_in", map[string]any{
		"provider":  "nope",
		"id_token":  "user1",
		"device_id": "device1",
	}, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusBadRequest {
		t.Fatalf("provider_sign_in unsupported provider: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/provider_sign_in", map[string]any{
		"provider":  "google",
		"id_token":  "token",
		"device_id": "device1",
	}, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusInternalServerError {
		t.Fatalf("provider_sign_in google not configured: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/provider_sign_in", map[string]any{
		"provider":  "apple",
		"id_token":  "token",
		"device_id": "device1",
	}, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusInternalServerError {
		t.Fatalf("provider_sign_in apple not configured: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/provider_sign_in", map[string]any{
		"provider":  "dev",
		"id_token":  "user1",
		"device_id": "device1",
	}, map[string]string{
		"X-Dev-Auth": cfg.DevAuthSecret,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("provider_sign_in: status %d body %s", status, string(body))
	}

	var auth1 authHTTPResponse
	if err := json.Unmarshal(body, &auth1); err != nil {
		t.Fatalf("decode auth response: %v", err)
	}
	if auth1.AccessToken == "" || auth1.RefreshToken == "" || auth1.User.ID == "" {
		t.Fatalf("missing auth fields")
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/provider_sign_in", map[string]any{
		"provider":  "dev",
		"id_token":  "user1",
		"device_id": "device2",
	}, map[string]string{
		"X-Dev-Auth": cfg.DevAuthSecret,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("provider_sign_in second device: status %d body %s", status, string(body))
	}

	var auth1b authHTTPResponse
	if err := json.Unmarshal(body, &auth1b); err != nil {
		t.Fatalf("decode auth1b response: %v", err)
	}
	if auth1b.User.ID != auth1.User.ID {
		t.Fatalf("expected same user id on repeat sign-in")
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/me", nil, map[string]string{
		"Authorization": "Bearer " + auth1.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("me: status %d body %s", status, string(body))
	}

	var me meHTTPResponse
	if err := json.Unmarshal(body, &me); err != nil {
		t.Fatalf("decode me: %v", err)
	}
	if me.ID != auth1.User.ID {
		t.Fatalf("me id mismatch")
	}

	status, hdr, body = doJSON(t, client, http.MethodPatch, srv.URL+"/v1/me", map[string]any{
		"username": "alice",
	}, map[string]string{
		"Authorization": "Bearer " + auth1.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("me patch: status %d body %s", status, string(body))
	}

	var me2 meHTTPResponse
	if err := json.Unmarshal(body, &me2); err != nil {
		t.Fatalf("decode me patch: %v", err)
	}
	if me2.Username != "alice" {
		t.Fatalf("username: got %q, want %q", me2.Username, "alice")
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/me/safety_acknowledgements", nil, map[string]string{
		"Authorization": "Bearer " + auth1.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("safety acks empty: status %d body %s", status, string(body))
	}

	var acks0 safetyAcknowledgementsHTTPResponse
	if err := json.Unmarshal(body, &acks0); err != nil {
		t.Fatalf("decode safety acks: %v", err)
	}
	if len(acks0.TechniqueIDs) != 0 {
		t.Fatalf("expected empty safety acks")
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/me/safety_acknowledgements", map[string]any{
		"technique_ids": []string{"missing"},
	}, map[string]string{
		"Authorization": "Bearer " + auth1.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusBadRequest {
		t.Fatalf("safety acks invalid technique: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/me/safety_acknowledgements", map[string]any{
		"technique_ids": []string{"kapalbhati", "Kapalbhati"},
	}, map[string]string{
		"Authorization": "Bearer " + auth1.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("safety acks add: status %d body %s", status, string(body))
	}

	var acks1 safetyAcknowledgementsHTTPResponse
	if err := json.Unmarshal(body, &acks1); err != nil {
		t.Fatalf("decode safety acks add: %v", err)
	}
	if len(acks1.TechniqueIDs) != 1 || acks1.TechniqueIDs[0] != "kapalbhati" {
		t.Fatalf("unexpected safety acks: %v", acks1.TechniqueIDs)
	}

	status, hdr, body = doJSON(t, client, http.MethodPatch, srv.URL+"/v1/me", map[string]any{
		"username": "!!",
	}, map[string]string{
		"Authorization": "Bearer " + auth1.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusBadRequest {
		t.Fatalf("me patch invalid username: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPatch, srv.URL+"/v1/me", map[string]any{
		"username": "fuck",
	}, map[string]string{
		"Authorization": "Bearer " + auth1.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusBadRequest {
		t.Fatalf("me patch profanity: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPatch, srv.URL+"/v1/me", map[string]any{
		"leaderboard_opt_in": false,
	}, map[string]string{
		"Authorization": "Bearer " + auth1.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("me patch leaderboard prefs: status %d body %s", status, string(body))
	}

	var me3 meHTTPResponse
	if err := json.Unmarshal(body, &me3); err != nil {
		t.Fatalf("decode me prefs: %v", err)
	}
	if me3.LeaderboardOptIn {
		t.Fatalf("expected leaderboard_opt_in false")
	}

	status, hdr, body = doJSON(t, client, http.MethodPatch, srv.URL+"/v1/me", map[string]any{
		"leaderboard_opt_in": true,
	}, map[string]string{
		"Authorization": "Bearer " + auth1.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("me patch leaderboard opt-in: status %d body %s", status, string(body))
	}

	var me4 meHTTPResponse
	if err := json.Unmarshal(body, &me4); err != nil {
		t.Fatalf("decode me opt-in: %v", err)
	}
	if !me4.LeaderboardOptIn {
		t.Fatalf("expected leaderboard_opt_in true")
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/stats/snapshot", nil, map[string]string{
		"Authorization": "Bearer " + auth1.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("stats snapshot recompute: status %d body %s", status, string(body))
	}

	var snap0 statsHTTPResponse
	if err := json.Unmarshal(body, &snap0); err != nil {
		t.Fatalf("decode stats recompute: %v", err)
	}
	if snap0.SessionsAllTime != 0 {
		t.Fatalf("sessions_all_time: got %d, want 0", snap0.SessionsAllTime)
	}
	if len(snap0.WeeklyMinutesByDay) != 7 {
		t.Fatalf("weekly_minutes_by_day length: got %d, want 7", len(snap0.WeeklyMinutesByDay))
	}
	var snap0WeekTotal int32
	for _, minutes := range snap0.WeeklyMinutesByDay {
		snap0WeekTotal += minutes
	}
	if snap0WeekTotal != snap0.MinutesThisWeek {
		t.Fatalf("weekly_minutes_by_day total: got %d, want %d", snap0WeekTotal, snap0.MinutesThisWeek)
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/refresh", map[string]any{
		"refresh_token": auth1.RefreshToken,
		"device_id":     "device1",
	}, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("refresh: status %d body %s", status, string(body))
	}

	var auth2 authHTTPResponse
	if err := json.Unmarshal(body, &auth2); err != nil {
		t.Fatalf("decode refresh response: %v", err)
	}
	if auth2.RefreshToken == auth1.RefreshToken {
		t.Fatalf("expected refresh token rotation")
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/leaderboard/self?ranking=all_time", nil, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("leaderboard self before refresh: status %d body %s", status, string(body))
	}

	var selfBefore leaderboardSelfHTTPResponse
	if err := json.Unmarshal(body, &selfBefore); err != nil {
		t.Fatalf("decode leaderboard self before: %v", err)
	}
	if selfBefore.User.Rank != nil {
		t.Fatalf("expected nil rank before refresh")
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/refresh", map[string]any{
		"refresh_token": "definitely-not-a-real-token",
		"device_id":     "device1",
	}, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusUnauthorized {
		t.Fatalf("refresh invalid token: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/refresh", map[string]any{
		"refresh_token": auth1.RefreshToken,
		"device_id":     "device2",
	}, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusUnauthorized {
		t.Fatalf("refresh device mismatch: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/refresh", map[string]any{
		"refresh_token": auth1.RefreshToken,
		"device_id":     "device1",
	}, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusConflict {
		t.Fatalf("refresh replay: status %d body %s", status, string(body))
	}

	hash := auth.HashRefreshToken(cfg.JWTRefreshSecret, auth2.RefreshToken)
	if _, err := pool.Exec(ctx, "UPDATE refresh_tokens SET expires_at = $1 WHERE token_hash = $2", time.Now().UTC().Add(-1*time.Minute), hash); err != nil {
		t.Fatalf("expire refresh token: %v", err)
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/refresh", map[string]any{
		"refresh_token": auth2.RefreshToken,
		"device_id":     "device1",
	}, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusUnauthorized {
		t.Fatalf("refresh expired: status %d body %s", status, string(body))
	}

	start := time.Now().UTC().Add(-10 * time.Minute).Truncate(time.Second)
	end := start.Add(5 * time.Minute)

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/sessions/submit", map[string]any{
		"sessions": []map[string]any{},
	}, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusBadRequest {
		t.Fatalf("sessions submit empty: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/sessions/submit", map[string]any{
		"sessions": []map[string]any{
			{
				"client_session_id":           "5b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
				"technique_id":                "unknown",
				"preset_id":                   "beginner",
				"started_at_utc":              start.Format(time.RFC3339),
				"ended_at_utc":                end.Format(time.RFC3339),
				"timezone_offset_minutes":     0,
				"breaths_completed_estimated": 30,
				"ended_early":                 false,
			},
			{
				"client_session_id":           "6b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
				"technique_id":                "hrv_resonance",
				"preset_id":                   "beginner",
				"started_at_utc":              start.Format(time.RFC3339),
				"ended_at_utc":                end.Format(time.RFC3339),
				"timezone_offset_minutes":     1000,
				"breaths_completed_estimated": 30,
				"ended_early":                 false,
			},
		},
	}, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("sessions submit rejected rows: status %d body %s", status, string(body))
	}

	var ingestRejected ingestHTTPResponse
	if err := json.Unmarshal(body, &ingestRejected); err != nil {
		t.Fatalf("decode rejected ingest: %v", err)
	}
	if ingestRejected.AcceptedCount != 0 || len(ingestRejected.Rejected) != 2 {
		t.Fatalf("unexpected rejected ingest counts")
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/sessions/submit", map[string]any{
		"sessions": []map[string]any{
			{
				"client_session_id":           "3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
				"technique_id":                "hrv_resonance",
				"preset_id":                   "beginner",
				"started_at_utc":              start.Format(time.RFC3339),
				"ended_at_utc":                end.Format(time.RFC3339),
				"timezone_offset_minutes":     60,
				"breaths_completed_estimated": 30,
				"ended_early":                 false,
			},
		},
	}, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("sessions submit: status %d body %s", status, string(body))
	}

	var ingest ingestHTTPResponse
	if err := json.Unmarshal(body, &ingest); err != nil {
		t.Fatalf("decode ingest: %v", err)
	}
	if ingest.AcceptedCount != 1 || ingest.StatsSnapshot.SessionsAllTime != 1 {
		t.Fatalf("unexpected ingest counts")
	}
	if ingest.TotalXP <= 0 {
		t.Fatalf("expected positive total_xp, got %d", ingest.TotalXP)
	}
	if ingest.CurrentLevel > 10 {
		t.Fatalf("expected current_level <= 10, got %d", ingest.CurrentLevel)
	}
	if ingest.StatsSnapshot.TotalXP != ingest.TotalXP {
		t.Fatalf("nested stats_snapshot.total_xp (%d) != top-level total_xp (%d)", ingest.StatsSnapshot.TotalXP, ingest.TotalXP)
	}
	if ingest.StatsSnapshot.CurrentLevel != ingest.CurrentLevel {
		t.Fatalf("nested stats_snapshot.current_level (%d) != top-level current_level (%d)", ingest.StatsSnapshot.CurrentLevel, ingest.CurrentLevel)
	}
	if len(ingest.XPAwards) < 1 {
		t.Fatalf("expected at least one xp award, got %d", len(ingest.XPAwards))
	}
	if len(ingest.StatsSnapshot.WeeklyMinutesByDay) != 7 {
		t.Fatalf("ingest weekly_minutes_by_day length: got %d, want 7", len(ingest.StatsSnapshot.WeeklyMinutesByDay))
	}
	var ingestWeekTotal int32
	for _, minutes := range ingest.StatsSnapshot.WeeklyMinutesByDay {
		ingestWeekTotal += minutes
	}
	if ingestWeekTotal != ingest.StatsSnapshot.MinutesThisWeek {
		t.Fatalf("ingest weekly_minutes_by_day total: got %d, want %d", ingestWeekTotal, ingest.StatsSnapshot.MinutesThisWeek)
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/me", nil, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("me after timezone update: status %d body %s", status, string(body))
	}

	var meAfterTZ meHTTPResponse
	if err := json.Unmarshal(body, &meAfterTZ); err != nil {
		t.Fatalf("decode me tz: %v", err)
	}
	if meAfterTZ.TimezoneOffsetMinutesLatest != 60 {
		t.Fatalf("timezone_offset_minutes_latest: got %d, want 60", meAfterTZ.TimezoneOffsetMinutesLatest)
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/sessions/sync", map[string]any{
		"sessions": []map[string]any{
			{
				"client_session_id":           "4b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
				"technique_id":                "hrv_resonance",
				"preset_id":                   "beginner",
				"started_at_utc":              start.Format(time.RFC3339),
				"ended_at_utc":                end.Format(time.RFC3339),
				"timezone_offset_minutes":     0,
				"breaths_completed_estimated": 30,
				"ended_early":                 false,
			},
		},
	}, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("sessions sync: status %d body %s", status, string(body))
	}

	var ingest2 ingestHTTPResponse
	if err := json.Unmarshal(body, &ingest2); err != nil {
		t.Fatalf("decode ingest2: %v", err)
	}
	if ingest2.AcceptedCount != 1 || ingest2.StatsSnapshot.SessionsAllTime != 2 {
		t.Fatalf("unexpected sync counts")
	}
	if len(ingest2.StatsSnapshot.WeeklyMinutesByDay) != 7 {
		t.Fatalf("sync weekly_minutes_by_day length: got %d, want 7", len(ingest2.StatsSnapshot.WeeklyMinutesByDay))
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/stats/snapshot", nil, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("stats snapshot: status %d body %s", status, string(body))
	}

	var snap statsHTTPResponse
	if err := json.Unmarshal(body, &snap); err != nil {
		t.Fatalf("decode stats: %v", err)
	}
	if snap.SessionsAllTime != 2 {
		t.Fatalf("sessions_all_time: got %d, want 2", snap.SessionsAllTime)
	}
	if len(snap.WeeklyMinutesByDay) != 7 {
		t.Fatalf("snapshot weekly_minutes_by_day length: got %d, want 7", len(snap.WeeklyMinutesByDay))
	}
	var snapWeekTotal int32
	for _, minutes := range snap.WeeklyMinutesByDay {
		snapWeekTotal += minutes
	}
	if snapWeekTotal != snap.MinutesThisWeek {
		t.Fatalf("snapshot weekly_minutes_by_day total: got %d, want %d", snapWeekTotal, snap.MinutesThisWeek)
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/stats/weekly?week_offset=0", nil, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("stats weekly: status %d body %s", status, string(body))
	}

	var weekly weeklyBreakdownHTTPResponse
	if err := json.Unmarshal(body, &weekly); err != nil {
		t.Fatalf("decode weekly: %v", err)
	}
	if weekly.WeekOffset != 0 {
		t.Fatalf("week_offset: got %d, want 0", weekly.WeekOffset)
	}
	if len(weekly.WeeklyMinutesByDay) != 7 {
		t.Fatalf("weekly endpoint weekly_minutes_by_day length: got %d, want 7", len(weekly.WeeklyMinutesByDay))
	}
	var weeklyTotal int32
	for _, minutes := range weekly.WeeklyMinutesByDay {
		weeklyTotal += minutes
	}
	if weeklyTotal != snap.MinutesThisWeek {
		t.Fatalf("weekly endpoint total: got %d, want %d", weeklyTotal, snap.MinutesThisWeek)
	}

	if err := leaderboardService.Refresh(ctx); err != nil {
		t.Fatalf("refresh leaderboard: %v", err)
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/leaderboard?ranking=all_time&limit=50", nil, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("leaderboard list: status %d body %s", status, string(body))
	}

	var lb leaderboardHTTPResponse
	if err := json.Unmarshal(body, &lb); err != nil {
		t.Fatalf("decode leaderboard: %v", err)
	}
	if lb.Ranking != string(lbsvc.RankingXP) {
		t.Fatalf("ranking: got %q, want %q", lb.Ranking, lbsvc.RankingXP)
	}
	if len(lb.Top) == 0 {
		t.Fatalf("expected non-empty leaderboard")
	}
	if lb.Top[0].TotalXP <= 0 {
		t.Fatalf("expected positive total_xp")
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/leaderboard?ranking=all_time&limit=0", nil, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("leaderboard list limit clamp: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/leaderboard?ranking=all_time&limit=abc", nil, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("leaderboard list bad limit: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/leaderboard/self?ranking=all_time", nil, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("leaderboard self: status %d body %s", status, string(body))
	}

	var self leaderboardSelfHTTPResponse
	if err := json.Unmarshal(body, &self); err != nil {
		t.Fatalf("decode leaderboard self: %v", err)
	}
	if self.Ranking != string(lbsvc.RankingXP) {
		t.Fatalf("ranking: got %q, want %q", self.Ranking, lbsvc.RankingXP)
	}
	if self.User.Rank == nil || *self.User.Rank != 1 {
		t.Fatalf("expected rank 1")
	}
	if self.User.TotalXP <= 0 {
		t.Fatalf("expected positive total_xp")
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/leaderboard", nil, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("leaderboard missing ranking: status %d body %s", status, string(body))
	}

	var lbDefault leaderboardHTTPResponse
	if err := json.Unmarshal(body, &lbDefault); err != nil {
		t.Fatalf("decode leaderboard default: %v", err)
	}
	if lbDefault.Ranking != string(lbsvc.RankingXP) {
		t.Fatalf("ranking: got %q, want %q", lbDefault.Ranking, lbsvc.RankingXP)
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/logout", map[string]any{
		"device_id": "device1",
	}, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusNoContent {
		t.Fatalf("logout: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/logout", map[string]any{
		"device_id": "",
	}, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusBadRequest {
		t.Fatalf("logout missing device id: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/refresh", map[string]any{
		"refresh_token": auth2.RefreshToken,
		"device_id":     "device1",
	}, nil)
	requireRequestID(t, hdr, body)
	if status != http.StatusUnauthorized {
		t.Fatalf("refresh after logout: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodDelete, srv.URL+"/v1/me", nil, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusNoContent {
		t.Fatalf("delete me: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodDelete, srv.URL+"/v1/me", nil, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusNoContent {
		t.Fatalf("delete me idempotent: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/me/safety_acknowledgements", nil, map[string]string{
		"Authorization": "Bearer " + auth2.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusUnauthorized {
		t.Fatalf("safety acks after delete: status %d body %s", status, string(body))
	}

	status, hdr, body = doJSON(t, client, http.MethodPost, srv.URL+"/v1/auth/provider_sign_in", map[string]any{
		"provider":  "dev",
		"id_token":  "user1",
		"device_id": "device3",
	}, map[string]string{
		"X-Dev-Auth": cfg.DevAuthSecret,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("provider_sign_in after delete: status %d body %s", status, string(body))
	}

	var auth3 authHTTPResponse
	if err := json.Unmarshal(body, &auth3); err != nil {
		t.Fatalf("decode auth3 response: %v", err)
	}
	if auth3.User.ID == auth1.User.ID {
		t.Fatalf("expected new user id after delete")
	}

	status, hdr, body = doJSON(t, client, http.MethodGet, srv.URL+"/v1/me/safety_acknowledgements", nil, map[string]string{
		"Authorization": "Bearer " + auth3.AccessToken,
	})
	requireRequestID(t, hdr, body)
	if status != http.StatusOK {
		t.Fatalf("safety acks after re-sign in: status %d body %s", status, string(body))
	}

	var acks2 safetyAcknowledgementsHTTPResponse
	if err := json.Unmarshal(body, &acks2); err != nil {
		t.Fatalf("decode safety acks after re-sign in: %v", err)
	}
	if len(acks2.TechniqueIDs) != 0 {
		t.Fatalf("expected empty safety acks after delete, got %v", acks2.TechniqueIDs)
	}
}
