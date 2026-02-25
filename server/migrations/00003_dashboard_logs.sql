-- +goose Up

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE request_logs (
    id          BIGSERIAL PRIMARY KEY,
    timestamp   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    method      TEXT NOT NULL,
    path        TEXT NOT NULL,
    status_code INT NOT NULL,
    duration_ms DOUBLE PRECISION NOT NULL,
    ip_address  TEXT NOT NULL,
    user_agent  TEXT NOT NULL DEFAULT '',
    request_id  TEXT NOT NULL,
    user_id     UUID,
    error_code  TEXT NOT NULL DEFAULT '',
    error_msg   TEXT NOT NULL DEFAULT ''
);

CREATE INDEX idx_request_logs_ts     ON request_logs (timestamp DESC);
CREATE INDEX idx_request_logs_status ON request_logs (status_code);
CREATE INDEX idx_request_logs_path   ON request_logs USING gin (path gin_trgm_ops);

CREATE TABLE event_logs (
    id          BIGSERIAL PRIMARY KEY,
    timestamp   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    level       TEXT NOT NULL,
    event_type  TEXT NOT NULL,
    message     TEXT NOT NULL,
    request_id  TEXT NOT NULL DEFAULT '',
    user_id     UUID,
    ip_address  TEXT NOT NULL DEFAULT '',
    provider    TEXT NOT NULL DEFAULT '',
    metadata    JSONB
);

CREATE INDEX idx_event_logs_ts    ON event_logs (timestamp DESC);
CREATE INDEX idx_event_logs_type  ON event_logs (event_type);
CREATE INDEX idx_event_logs_level ON event_logs (level);

-- +goose Down
DROP TABLE IF EXISTS event_logs;
DROP TABLE IF EXISTS request_logs;
DROP EXTENSION IF EXISTS pg_trgm;
