package config

import (
	"strings"
	"testing"
)

func TestEnvBoolOrDefault(t *testing.T) {
	tests := []struct {
		name     string
		envValue string
		fallback bool
		want     bool
	}{
		{name: "empty uses fallback true", envValue: "", fallback: true, want: true},
		{name: "empty uses fallback false", envValue: "", fallback: false, want: false},
		{name: "true", envValue: "true", fallback: false, want: true},
		{name: "1", envValue: "1", fallback: false, want: true},
		{name: "yes", envValue: "yes", fallback: false, want: true},
		{name: "on", envValue: "on", fallback: false, want: true},
		{name: "false", envValue: "false", fallback: true, want: false},
		{name: "0", envValue: "0", fallback: true, want: false},
		{name: "no", envValue: "no", fallback: true, want: false},
		{name: "off", envValue: "off", fallback: true, want: false},
		{name: "garbage uses fallback", envValue: "maybe", fallback: true, want: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Setenv("TEST_BOOL", tt.envValue)
			if got := envBoolOrDefault("TEST_BOOL", tt.fallback); got != tt.want {
				t.Fatalf("got %v, want %v", got, tt.want)
			}
		})
	}
}

func TestConfigValidate(t *testing.T) {
	valid := Config{
		Port:                     "8080",
		DatabaseURL:              "postgres://example",
		RedisAddr:                "localhost:6380",
		CORSOrigins:              []string{"http://localhost:3000"},
		Env:                      "development",
		TechniqueRegistryPath:    "registry/techniques.json",
		JWTAccessSecret:          strings.Repeat("a", 32),
		JWTRefreshSecret:         strings.Repeat("b", 32),
		JWTAccessTTLMinutes:      15,
		JWTRefreshTTLMinutes:     60,
		GoogleOAuthClientIDs:     nil,
		AppleOAuthAudience:       "",
		RateLimitAuthPerHour:     30,
		RateLimitAuthBurstPerMin: 10,
		RateLimitSessionPerDay:   500,
		RateLimitLeaderboardPerM: 120,
		DevAuthEnabled:           false,
		DevAuthSecret:            "",
		LeaderboardDailyCapMin:   60,
	}

	tests := []struct {
		name   string
		mutate func(*Config)
		want   string
	}{
		{name: "missing PORT", mutate: func(c *Config) { c.Port = "" }, want: "PORT is required"},
		{name: "missing DATABASE_URL", mutate: func(c *Config) { c.DatabaseURL = "" }, want: "DATABASE_URL is required"},
		{name: "missing REDIS_ADDR", mutate: func(c *Config) { c.RedisAddr = "" }, want: "REDIS_ADDR is required"},
		{name: "missing ENV", mutate: func(c *Config) { c.Env = "" }, want: "ENV is required"},
		{name: "missing TECHNIQUE_REGISTRY_PATH", mutate: func(c *Config) { c.TechniqueRegistryPath = "" }, want: "TECHNIQUE_REGISTRY_PATH is required"},
		{name: "missing JWT_ACCESS_SECRET", mutate: func(c *Config) { c.JWTAccessSecret = "" }, want: "JWT_ACCESS_SECRET is required"},
		{name: "missing JWT_REFRESH_SECRET", mutate: func(c *Config) { c.JWTRefreshSecret = "" }, want: "JWT_REFRESH_SECRET is required"},
		{name: "short JWT_ACCESS_SECRET", mutate: func(c *Config) { c.JWTAccessSecret = "short" }, want: "JWT_ACCESS_SECRET must be at least 32 chars"},
		{name: "short JWT_REFRESH_SECRET", mutate: func(c *Config) { c.JWTRefreshSecret = "short" }, want: "JWT_REFRESH_SECRET must be at least 32 chars"},
		{name: "JWT_ACCESS_TTL_MINUTES must be positive", mutate: func(c *Config) { c.JWTAccessTTLMinutes = 0 }, want: "JWT_ACCESS_TTL_MINUTES must be positive"},
		{name: "JWT_REFRESH_TTL_MINUTES must be positive", mutate: func(c *Config) { c.JWTRefreshTTLMinutes = -1 }, want: "JWT_REFRESH_TTL_MINUTES must be positive"},
		{name: "RATE_LIMIT_AUTH_PER_HOUR must be positive", mutate: func(c *Config) { c.RateLimitAuthPerHour = 0 }, want: "RATE_LIMIT_AUTH_PER_HOUR must be positive"},
		{name: "RATE_LIMIT_AUTH_BURST_PER_MIN must be positive", mutate: func(c *Config) { c.RateLimitAuthBurstPerMin = 0 }, want: "RATE_LIMIT_AUTH_BURST_PER_MIN must be positive"},
		{name: "RATE_LIMIT_SESSION_WRITES_PER_DAY must be positive", mutate: func(c *Config) { c.RateLimitSessionPerDay = 0 }, want: "RATE_LIMIT_SESSION_WRITES_PER_DAY must be positive"},
		{name: "RATE_LIMIT_LEADERBOARD_READS_PER_MIN must be positive", mutate: func(c *Config) { c.RateLimitLeaderboardPerM = 0 }, want: "RATE_LIMIT_LEADERBOARD_READS_PER_MIN must be positive"},
		{name: "LEADERBOARD_DAILY_CAP_MINUTES must be positive", mutate: func(c *Config) { c.LeaderboardDailyCapMin = 0 }, want: "LEADERBOARD_DAILY_CAP_MINUTES must be positive"},
		{name: "DEV_AUTH_SECRET required when enabled", mutate: func(c *Config) { c.DevAuthEnabled = true }, want: "DEV_AUTH_SECRET is required when DEV_AUTH_ENABLED is true"},
		{
			name: "google client ids required outside development",
			mutate: func(c *Config) {
				c.Env = "staging"
				c.GoogleOAuthClientIDs = nil
				c.AppleOAuthAudience = strings.Repeat("x", 10)
			},
			want: "GOOGLE_OAUTH_CLIENT_IDS is required when ENV is not development",
		},
		{
			name: "apple audience required outside development",
			mutate: func(c *Config) {
				c.Env = "staging"
				c.GoogleOAuthClientIDs = []string{strings.Repeat("x", 10)}
				c.AppleOAuthAudience = ""
			},
			want: "APPLE_OAUTH_AUDIENCE is required when ENV is not development",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			cfg := valid
			tt.mutate(&cfg)

			err := cfg.Validate()
			if err == nil {
				t.Fatalf("expected error")
			}
			if !strings.Contains(err.Error(), tt.want) {
				t.Fatalf("error: got %q, want contains %q", err.Error(), tt.want)
			}
		})
	}

	okCfg := valid
	okCfg.Env = "staging"
	okCfg.GoogleOAuthClientIDs = []string{"x"}
	okCfg.AppleOAuthAudience = "x"
	if err := okCfg.Validate(); err != nil {
		t.Fatalf("expected ok, got %v", err)
	}
}

func TestLoadDevelopmentSuccess(t *testing.T) {
	t.Setenv("ENV", "development")
	t.Setenv("DATABASE_URL", "postgres://example")
	t.Setenv("REDIS_ADDR", "localhost:6380")
	t.Setenv("JWT_ACCESS_SECRET", strings.Repeat("a", 32))
	t.Setenv("JWT_REFRESH_SECRET", strings.Repeat("b", 32))
	t.Setenv("DEV_AUTH_ENABLED", "false")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("load: %v", err)
	}
	if cfg.Env != "development" {
		t.Fatalf("env: got %q, want development", cfg.Env)
	}
	if cfg.DatabaseURL != "postgres://example" {
		t.Fatalf("database_url: got %q", cfg.DatabaseURL)
	}
	if cfg.DevAuthEnabled {
		t.Fatalf("expected dev auth disabled")
	}
}

func TestLoadParseErrors(t *testing.T) {
	tests := []struct {
		name string
		key  string
		want string
	}{
		{name: "JWT_ACCESS_TTL_MINUTES", key: "JWT_ACCESS_TTL_MINUTES", want: "parse JWT_ACCESS_TTL_MINUTES"},
		{name: "RATE_LIMIT_AUTH_PER_HOUR", key: "RATE_LIMIT_AUTH_PER_HOUR", want: "parse RATE_LIMIT_AUTH_PER_HOUR"},
		{name: "LEADERBOARD_DAILY_CAP_MINUTES", key: "LEADERBOARD_DAILY_CAP_MINUTES", want: "parse LEADERBOARD_DAILY_CAP_MINUTES"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Setenv(tt.key, "not-an-int")
			_, err := Load()
			if err == nil {
				t.Fatalf("expected error")
			}
			if !strings.Contains(err.Error(), tt.want) {
				t.Fatalf("error: got %q, want contains %q", err.Error(), tt.want)
			}
		})
	}
}

func TestLoadGoogleOAuthClientIDsCSV(t *testing.T) {
	t.Setenv("ENV", "staging")
	t.Setenv("DATABASE_URL", "postgres://example")
	t.Setenv("REDIS_ADDR", "localhost:6380")
	t.Setenv("JWT_ACCESS_SECRET", strings.Repeat("a", 32))
	t.Setenv("JWT_REFRESH_SECRET", strings.Repeat("b", 32))
	t.Setenv("GOOGLE_OAUTH_CLIENT_IDS", " web-id , , ios-id ")
	t.Setenv("APPLE_OAUTH_AUDIENCE", "life.clearbreath.clearbreath")
	t.Setenv("DEV_AUTH_ENABLED", "false")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("load: %v", err)
	}
	if len(cfg.GoogleOAuthClientIDs) != 2 {
		t.Fatalf("google client ids length: got %d, want %d", len(cfg.GoogleOAuthClientIDs), 2)
	}
	if cfg.GoogleOAuthClientIDs[0] != "web-id" {
		t.Fatalf("google client id[0]: got %q, want %q", cfg.GoogleOAuthClientIDs[0], "web-id")
	}
	if cfg.GoogleOAuthClientIDs[1] != "ios-id" {
		t.Fatalf("google client id[1]: got %q, want %q", cfg.GoogleOAuthClientIDs[1], "ios-id")
	}
}
