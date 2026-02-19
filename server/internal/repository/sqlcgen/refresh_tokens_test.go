package sqlcgen

import (
	"context"
	"errors"
	"testing"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

type fakeDBTX struct {
	execQuery string
	execArgs  []any
	execErr   error
}

func (f *fakeDBTX) Exec(ctx context.Context, query string, args ...interface{}) (pgconn.CommandTag, error) {
	f.execQuery = query
	f.execArgs = make([]any, len(args))
	copy(f.execArgs, args)
	return pgconn.CommandTag{}, f.execErr
}

func (f *fakeDBTX) Query(context.Context, string, ...interface{}) (pgx.Rows, error) {
	panic("not implemented")
}

func (f *fakeDBTX) QueryRow(context.Context, string, ...interface{}) pgx.Row {
	panic("not implemented")
}

func TestRevokeAllUserRefreshTokensExec(t *testing.T) {
	db := &fakeDBTX{}
	q := New(db)
	userID := uuid.MustParse("3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11")

	if err := q.RevokeAllUserRefreshTokens(context.Background(), userID); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if db.execQuery != revokeAllUserRefreshTokens {
		t.Fatalf("query mismatch")
	}
	if len(db.execArgs) != 1 {
		t.Fatalf("args: got %d, want %d", len(db.execArgs), 1)
	}
	if got, ok := db.execArgs[0].(uuid.UUID); !ok || got != userID {
		t.Fatalf("user id arg mismatch")
	}
}

func TestRevokeRefreshTokenExec(t *testing.T) {
	db := &fakeDBTX{execErr: errors.New("exec failed")}
	q := New(db)
	id := uuid.MustParse("f2b1a5b3-2a9b-4a7d-9a76-2d4f6b0b2f4e")

	if err := q.RevokeRefreshToken(context.Background(), id); err == nil {
		t.Fatalf("expected error")
	}
	if db.execQuery != revokeRefreshToken {
		t.Fatalf("query mismatch")
	}
	if len(db.execArgs) != 1 {
		t.Fatalf("args: got %d, want %d", len(db.execArgs), 1)
	}
	if got, ok := db.execArgs[0].(uuid.UUID); !ok || got != id {
		t.Fatalf("id arg mismatch")
	}
}
