package safety

import (
	"context"
	"fmt"
	"net/http"
	"strings"

	"github.com/google/uuid"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
	"github.com/clearbreath/server/internal/technique"
)

type Service struct {
	store    *repository.Store
	registry *technique.Registry
}

func NewService(store *repository.Store, registry *technique.Registry) (*Service, error) {
	if store == nil {
		return nil, fmt.Errorf("store is required")
	}
	if registry == nil {
		return nil, fmt.Errorf("registry is required")
	}
	return &Service{store: store, registry: registry}, nil
}

func (s *Service) List(ctx context.Context, userID uuid.UUID) ([]string, error) {
	ids, err := s.store.Queries().ListSafetyAcknowledgementsByUserID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("list safety acknowledgements: %w", err)
	}
	return ids, nil
}

func (s *Service) Acknowledge(ctx context.Context, userID uuid.UUID, techniqueIDs []string) ([]string, error) {
	ids, err := normalizeTechniqueIDs(s.registry, techniqueIDs)
	if err != nil {
		return nil, err
	}

	if err := s.store.InTx(ctx, func(q *sqlcgen.Queries) error {
		for _, id := range ids {
			if err := q.AddSafetyAcknowledgement(ctx, sqlcgen.AddSafetyAcknowledgementParams{
				UserID:      userID,
				TechniqueID: id,
			}); err != nil {
				return fmt.Errorf("add safety acknowledgement: %w", err)
			}
		}
		return nil
	}); err != nil {
		return nil, err
	}

	return s.List(ctx, userID)
}

func normalizeTechniqueIDs(registry *technique.Registry, techniqueIDs []string) ([]string, error) {
	if len(techniqueIDs) == 0 {
		return nil, apierr.New(http.StatusBadRequest, "validation", "technique_ids is required")
	}
	if len(techniqueIDs) > 50 {
		return nil, apierr.New(http.StatusBadRequest, "validation", "technique_ids is too large")
	}

	seen := make(map[string]struct{}, len(techniqueIDs))
	out := make([]string, 0, len(techniqueIDs))
	for _, raw := range techniqueIDs {
		id := strings.ToLower(strings.TrimSpace(raw))
		if id == "" {
			return nil, apierr.New(http.StatusBadRequest, "validation", "technique_ids contains empty value")
		}
		if !registry.HasTechnique(id) {
			return nil, apierr.New(http.StatusBadRequest, "validation", "technique_id is invalid")
		}
		if _, ok := seen[id]; ok {
			continue
		}
		seen[id] = struct{}{}
		out = append(out, id)
	}

	return out, nil
}
