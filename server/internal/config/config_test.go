package config

import "testing"

func TestLoadDevelopmentConfig(t *testing.T) {
	t.Setenv("ENV", "development")
	t.Setenv("JWT_ACCESS_SECRET", "access_secret_012345678901234567890123")
	t.Setenv("JWT_REFRESH_SECRET", "refresh_secret_012345678901234567890123")
	t.Setenv("DEV_AUTH_SECRET", "dev-secret")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("load config: %v", err)
	}

	if cfg.Env != "development" {
		t.Fatalf("ENV: got %q, want development", cfg.Env)
	}
	if !cfg.DevAuthEnabled {
		t.Fatalf("DevAuthEnabled: got false, want true")
	}
	if cfg.JWTAccessTTLMinutes <= 0 {
		t.Fatalf("JWTAccessTTLMinutes: got %d, want >0", cfg.JWTAccessTTLMinutes)
	}
	if cfg.JWTRefreshTTLMinutes <= 0 {
		t.Fatalf("JWTRefreshTTLMinutes: got %d, want >0", cfg.JWTRefreshTTLMinutes)
	}
}

func TestLoadProductionConfigRequiresProviderIDs(t *testing.T) {
	t.Setenv("ENV", "production")
	t.Setenv("JWT_ACCESS_SECRET", "access_secret_012345678901234567890123")
	t.Setenv("JWT_REFRESH_SECRET", "refresh_secret_012345678901234567890123")

	_, err := Load()
	if err == nil {
		t.Fatalf("expected error, got nil")
	}
}

func TestLoadInvalidIntEnv(t *testing.T) {
	t.Setenv("ENV", "development")
	t.Setenv("JWT_ACCESS_SECRET", "access_secret_012345678901234567890123")
	t.Setenv("JWT_REFRESH_SECRET", "refresh_secret_012345678901234567890123")
	t.Setenv("DEV_AUTH_SECRET", "dev-secret")
	t.Setenv("RATE_LIMIT_AUTH_PER_HOUR", "nope")

	_, err := Load()
	if err == nil {
		t.Fatalf("expected error, got nil")
	}
}

func TestCORSOriginsTrimmed(t *testing.T) {
	t.Setenv("ENV", "development")
	t.Setenv("JWT_ACCESS_SECRET", "access_secret_012345678901234567890123")
	t.Setenv("JWT_REFRESH_SECRET", "refresh_secret_012345678901234567890123")
	t.Setenv("DEV_AUTH_SECRET", "dev-secret")
	t.Setenv("CORS_ORIGINS", " http://a.com, ,http://b.com ")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("load config: %v", err)
	}

	if len(cfg.CORSOrigins) != 2 {
		t.Fatalf("CORSOrigins len: got %d, want 2", len(cfg.CORSOrigins))
	}
	if cfg.CORSOrigins[0] != "http://a.com" {
		t.Fatalf("CORSOrigins[0]: got %q, want http://a.com", cfg.CORSOrigins[0])
	}
	if cfg.CORSOrigins[1] != "http://b.com" {
		t.Fatalf("CORSOrigins[1]: got %q, want http://b.com", cfg.CORSOrigins[1])
	}
}
