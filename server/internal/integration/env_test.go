package integration

import (
	"testing"
)

func setBaseIntegrationEnv(t *testing.T) {
	t.Helper()

	t.Setenv("ENV", "development")
	t.Setenv("DATABASE_URL", "postgres://clearbreath:clearbreath@localhost:5433/clearbreath?sslmode=disable")
	t.Setenv("REDIS_ADDR", "localhost:6380")
	t.Setenv("REDIS_PASSWORD", "")
	t.Setenv("JWT_ACCESS_SECRET", "dev_access_secret_change_me_01234567890123456789012")
	t.Setenv("JWT_REFRESH_SECRET", "dev_refresh_secret_change_me_0123456789012345678901")
	t.Setenv("DEV_AUTH_ENABLED", "true")
	t.Setenv("DEV_AUTH_SECRET", "dev_secret_change_me")
	t.Setenv("DASHBOARD_ENABLED", "false")
}
