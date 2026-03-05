package config

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/joho/godotenv"
)

type Config struct {
	Port                     string
	DatabaseURL              string
	RedisAddr                string
	RedisPassword            string
	CORSOrigins              []string
	Env                      string
	TechniqueRegistryPath    string
	JWTAccessSecret          string
	JWTRefreshSecret         string
	JWTAccessTTLMinutes      int
	JWTRefreshTTLMinutes     int
	GoogleOAuthClientIDs     []string
	AppleOAuthAudience       string
	RateLimitAuthPerHour     int
	RateLimitAuthBurstPerMin int
	RateLimitSessionPerDay   int
	RateLimitLeaderboardPerM int
	DevAuthEnabled           bool
	DevAuthSecret            string
	LeaderboardDailyCapMin   int
	DashboardEnabled         bool
	DashboardHost            string
	DashboardUsername        string
	DashboardPasswordHash    string
	DashboardSessionSecret   string
}

func Load() (*Config, error) {
	_ = godotenv.Load()

	env := envOrDefault("ENV", "development")

	jwtAccessTTLMinutes, err := envIntOrDefault("JWT_ACCESS_TTL_MINUTES", 15)
	if err != nil {
		return nil, fmt.Errorf("parse JWT_ACCESS_TTL_MINUTES: %w", err)
	}
	jwtRefreshTTLMinutes, err := envIntOrDefault("JWT_REFRESH_TTL_MINUTES", 43200)
	if err != nil {
		return nil, fmt.Errorf("parse JWT_REFRESH_TTL_MINUTES: %w", err)
	}
	rateLimitAuthPerHour, err := envIntOrDefault("RATE_LIMIT_AUTH_PER_HOUR", 30)
	if err != nil {
		return nil, fmt.Errorf("parse RATE_LIMIT_AUTH_PER_HOUR: %w", err)
	}
	rateLimitAuthBurstPerMin, err := envIntOrDefault("RATE_LIMIT_AUTH_BURST_PER_MIN", 10)
	if err != nil {
		return nil, fmt.Errorf("parse RATE_LIMIT_AUTH_BURST_PER_MIN: %w", err)
	}
	rateLimitSessionPerDay, err := envIntOrDefault("RATE_LIMIT_SESSION_WRITES_PER_DAY", 500)
	if err != nil {
		return nil, fmt.Errorf("parse RATE_LIMIT_SESSION_WRITES_PER_DAY: %w", err)
	}
	rateLimitLeaderboardPerMin, err := envIntOrDefault("RATE_LIMIT_LEADERBOARD_READS_PER_MIN", 120)
	if err != nil {
		return nil, fmt.Errorf("parse RATE_LIMIT_LEADERBOARD_READS_PER_MIN: %w", err)
	}
	devAuthEnabled := envBoolOrDefault("DEV_AUTH_ENABLED", env == "development")
	leaderboardDailyCapMin, err := envIntOrDefault("LEADERBOARD_DAILY_CAP_MINUTES", 60)
	if err != nil {
		return nil, fmt.Errorf("parse LEADERBOARD_DAILY_CAP_MINUTES: %w", err)
	}
	dashboardEnabled := envBoolOrDefault("DASHBOARD_ENABLED", false)
	googleOAuthClientIDs := os.Getenv("GOOGLE_OAUTH_CLIENT_IDS")
	if strings.TrimSpace(googleOAuthClientIDs) == "" {
		googleOAuthClientIDs = os.Getenv("GOOGLE_OAUTH_CLIENT_ID")
	}

	cfg := &Config{
		Port:                     envOrDefault("PORT", "8080"),
		DatabaseURL:              envOrDefault("DATABASE_URL", "postgres://clearbreath:clearbreath@localhost:5433/clearbreath?sslmode=disable"),
		RedisAddr:                envOrDefault("REDIS_ADDR", "localhost:6380"),
		RedisPassword:            os.Getenv("REDIS_PASSWORD"),
		CORSOrigins:              splitAndTrimCSV(envOrDefault("CORS_ORIGINS", "http://localhost:3000,http://localhost:4321")),
		Env:                      env,
		TechniqueRegistryPath:    envOrDefault("TECHNIQUE_REGISTRY_PATH", "registry/techniques.json"),
		JWTAccessSecret:          os.Getenv("JWT_ACCESS_SECRET"),
		JWTRefreshSecret:         os.Getenv("JWT_REFRESH_SECRET"),
		JWTAccessTTLMinutes:      jwtAccessTTLMinutes,
		JWTRefreshTTLMinutes:     jwtRefreshTTLMinutes,
		GoogleOAuthClientIDs:     splitAndTrimCSV(googleOAuthClientIDs),
		AppleOAuthAudience:       os.Getenv("APPLE_OAUTH_AUDIENCE"),
		RateLimitAuthPerHour:     rateLimitAuthPerHour,
		RateLimitAuthBurstPerMin: rateLimitAuthBurstPerMin,
		RateLimitSessionPerDay:   rateLimitSessionPerDay,
		RateLimitLeaderboardPerM: rateLimitLeaderboardPerMin,
		DevAuthEnabled:           devAuthEnabled,
		DevAuthSecret:            os.Getenv("DEV_AUTH_SECRET"),
		LeaderboardDailyCapMin:   leaderboardDailyCapMin,
		DashboardEnabled:         dashboardEnabled,
		DashboardHost:            os.Getenv("DASHBOARD_HOST"),
		DashboardUsername:        os.Getenv("DASHBOARD_USERNAME"),
		DashboardPasswordHash:    os.Getenv("DASHBOARD_PASSWORD_HASH"),
		DashboardSessionSecret:   os.Getenv("DASHBOARD_SESSION_SECRET"),
	}

	if err := cfg.Validate(); err != nil {
		return nil, err
	}

	return cfg, nil
}

func envOrDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func envIntOrDefault(key string, fallback int) (int, error) {
	v := os.Getenv(key)
	if v == "" {
		return fallback, nil
	}

	n, err := strconv.Atoi(v)
	if err != nil {
		return 0, err
	}

	return n, nil
}

func envBoolOrDefault(key string, fallback bool) bool {
	v := strings.TrimSpace(strings.ToLower(os.Getenv(key)))
	if v == "" {
		return fallback
	}

	switch v {
	case "1", "true", "yes", "y", "on":
		return true
	case "0", "false", "no", "n", "off":
		return false
	default:
		return fallback
	}
}

func splitAndTrimCSV(v string) []string {
	raw := strings.Split(v, ",")
	out := make([]string, 0, len(raw))
	for _, s := range raw {
		s = strings.TrimSpace(s)
		if s == "" {
			continue
		}
		out = append(out, s)
	}
	return out
}

func (c *Config) Validate() error {
	if strings.TrimSpace(c.Port) == "" {
		return fmt.Errorf("PORT is required")
	}
	if strings.TrimSpace(c.DatabaseURL) == "" {
		return fmt.Errorf("DATABASE_URL is required")
	}
	if strings.TrimSpace(c.RedisAddr) == "" {
		return fmt.Errorf("REDIS_ADDR is required")
	}
	if strings.TrimSpace(c.Env) == "" {
		return fmt.Errorf("ENV is required")
	}
	if strings.TrimSpace(c.TechniqueRegistryPath) == "" {
		return fmt.Errorf("TECHNIQUE_REGISTRY_PATH is required")
	}
	if strings.TrimSpace(c.JWTAccessSecret) == "" {
		return fmt.Errorf("JWT_ACCESS_SECRET is required")
	}
	if strings.TrimSpace(c.JWTRefreshSecret) == "" {
		return fmt.Errorf("JWT_REFRESH_SECRET is required")
	}
	if len(c.JWTAccessSecret) < 32 {
		return fmt.Errorf("JWT_ACCESS_SECRET must be at least 32 chars")
	}
	if len(c.JWTRefreshSecret) < 32 {
		return fmt.Errorf("JWT_REFRESH_SECRET must be at least 32 chars")
	}
	if c.JWTAccessTTLMinutes <= 0 {
		return fmt.Errorf("JWT_ACCESS_TTL_MINUTES must be positive")
	}
	if c.JWTRefreshTTLMinutes <= 0 {
		return fmt.Errorf("JWT_REFRESH_TTL_MINUTES must be positive")
	}
	if c.RateLimitAuthPerHour <= 0 {
		return fmt.Errorf("RATE_LIMIT_AUTH_PER_HOUR must be positive")
	}
	if c.RateLimitAuthBurstPerMin <= 0 {
		return fmt.Errorf("RATE_LIMIT_AUTH_BURST_PER_MIN must be positive")
	}
	if c.RateLimitSessionPerDay <= 0 {
		return fmt.Errorf("RATE_LIMIT_SESSION_WRITES_PER_DAY must be positive")
	}
	if c.RateLimitLeaderboardPerM <= 0 {
		return fmt.Errorf("RATE_LIMIT_LEADERBOARD_READS_PER_MIN must be positive")
	}
	if c.LeaderboardDailyCapMin <= 0 {
		return fmt.Errorf("LEADERBOARD_DAILY_CAP_MINUTES must be positive")
	}
	if c.DevAuthEnabled && strings.TrimSpace(c.DevAuthSecret) == "" {
		return fmt.Errorf("DEV_AUTH_SECRET is required when DEV_AUTH_ENABLED is true")
	}
	if c.DashboardEnabled {
		if strings.TrimSpace(c.DashboardUsername) == "" {
			return fmt.Errorf("DASHBOARD_USERNAME is required when DASHBOARD_ENABLED is true")
		}
		if strings.TrimSpace(c.DashboardPasswordHash) == "" {
			return fmt.Errorf("DASHBOARD_PASSWORD_HASH is required when DASHBOARD_ENABLED is true")
		}
		if strings.TrimSpace(c.DashboardSessionSecret) == "" {
			return fmt.Errorf("DASHBOARD_SESSION_SECRET is required when DASHBOARD_ENABLED is true")
		}
		if len(c.DashboardSessionSecret) < 32 {
			return fmt.Errorf("DASHBOARD_SESSION_SECRET must be at least 32 chars")
		}
	}
	if c.Env != "development" {
		if len(c.GoogleOAuthClientIDs) == 0 {
			return fmt.Errorf("GOOGLE_OAUTH_CLIENT_IDS is required when ENV is not development")
		}
		if strings.TrimSpace(c.AppleOAuthAudience) == "" {
			return fmt.Errorf("APPLE_OAUTH_AUDIENCE is required when ENV is not development")
		}
	}
	return nil
}
