-- +goose Up
CREATE TABLE safety_acknowledgements (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  technique_id text NOT NULL,
  acknowledged_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, technique_id)
);

-- +goose Down
DROP TABLE IF EXISTS safety_acknowledgements;

