package config

import (
	"os"
	"strings"

	"github.com/joho/godotenv"
)

type Config struct {
	Port          string
	DatabaseURL   string
	RedisAddr     string
	RedisPassword string
	CORSOrigins   []string
	Env           string
}

func Load() (*Config, error) {
	_ = godotenv.Load()

	return &Config{
		Port:          envOrDefault("PORT", "8080"),
		DatabaseURL:   envOrDefault("DATABASE_URL", "postgres://rahul:@localhost:5432/clearbreath?sslmode=disable"),
		RedisAddr:     envOrDefault("REDIS_ADDR", "localhost:6379"),
		RedisPassword: os.Getenv("REDIS_PASSWORD"),
		CORSOrigins:   strings.Split(envOrDefault("CORS_ORIGINS", "http://localhost:3000,http://localhost:4321"), ","),
		Env:           envOrDefault("ENV", "development"),
	}, nil
}

func envOrDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
