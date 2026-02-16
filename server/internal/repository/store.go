package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/clearbreath/server/internal/repository/sqlcgen"
)

type Store struct {
	pool *pgxpool.Pool
	q    *sqlcgen.Queries
}

func NewStore(pool *pgxpool.Pool) *Store {
	return &Store{
		pool: pool,
		q:    sqlcgen.New(pool),
	}
}

func (s *Store) Queries() *sqlcgen.Queries {
	return s.q
}

func (s *Store) InTx(ctx context.Context, fn func(*sqlcgen.Queries) error) error {
	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}

	qtx := s.q.WithTx(tx)
	if err := fn(qtx); err != nil {
		if rbErr := tx.Rollback(ctx); rbErr != nil {
			return fmt.Errorf("rollback: %w", rbErr)
		}
		return err
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit: %w", err)
	}

	return nil
}
