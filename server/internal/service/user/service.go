package user

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"unicode"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/profanity"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
)

type Service struct {
	store  *repository.Store
	filter *profanity.Filter
}

type Profile struct {
	ID                          uuid.UUID
	DisplayName                 string
	AvatarSeed                  string
	LeaderboardOptIn            bool
	LeaderboardInitialsOnly     bool
	CreatedAtUTC                string
	TimezoneOffsetMinutesLatest int32
}

type UpdateInput struct {
	DisplayName             *string
	LeaderboardOptIn        *bool
	LeaderboardInitialsOnly *bool
}

func NewService(store *repository.Store, filter *profanity.Filter) (*Service, error) {
	if store == nil {
		return nil, fmt.Errorf("store is required")
	}
	if filter == nil {
		return nil, fmt.Errorf("filter is required")
	}
	return &Service{store: store, filter: filter}, nil
}

func (s *Service) GetProfile(ctx context.Context, userID uuid.UUID) (sqlcgen.User, error) {
	u, err := s.store.Queries().GetUserByID(ctx, userID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return sqlcgen.User{}, apierr.New(http.StatusUnauthorized, "unauthorized", "unauthorized")
		}
		return sqlcgen.User{}, fmt.Errorf("get user: %w", err)
	}
	return u, nil
}

func (s *Service) UpdateProfile(ctx context.Context, userID uuid.UUID, in UpdateInput) (sqlcgen.User, error) {
	var out sqlcgen.User

	if err := s.store.InTx(ctx, func(q *sqlcgen.Queries) error {
		u, err := q.GetUserByID(ctx, userID)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.New(http.StatusUnauthorized, "unauthorized", "unauthorized")
			}
			return fmt.Errorf("get user: %w", err)
		}

		displayName := u.DisplayName
		if in.DisplayName != nil {
			n, err := canonicalizeDisplayName(*in.DisplayName)
			if err != nil {
				return apierr.New(http.StatusBadRequest, "validation", err.Error())
			}
			if s.filter.HasProfanity(n) {
				return apierr.New(http.StatusBadRequest, "validation", "display_name contains profanity")
			}
			displayName = n
		}

		optIn := u.LeaderboardOptIn
		initialsOnly := u.LeaderboardInitialsOnly
		if in.LeaderboardOptIn != nil {
			optIn = *in.LeaderboardOptIn
		}
		if in.LeaderboardInitialsOnly != nil {
			initialsOnly = *in.LeaderboardInitialsOnly
		}
		if !optIn {
			initialsOnly = false
		}

		if displayName != u.DisplayName {
			u, err = q.UpdateUserDisplayName(ctx, sqlcgen.UpdateUserDisplayNameParams{
				ID:          userID,
				DisplayName: displayName,
			})
			if err != nil {
				return fmt.Errorf("update display name: %w", err)
			}
		}

		if optIn != u.LeaderboardOptIn || initialsOnly != u.LeaderboardInitialsOnly {
			u, err = q.UpdateUserLeaderboardPrefs(ctx, sqlcgen.UpdateUserLeaderboardPrefsParams{
				ID:                      userID,
				LeaderboardOptIn:        optIn,
				LeaderboardInitialsOnly: initialsOnly,
			})
			if err != nil {
				return fmt.Errorf("update leaderboard prefs: %w", err)
			}
		}

		out = u
		return nil
	}); err != nil {
		return sqlcgen.User{}, err
	}

	return out, nil
}

func (s *Service) DeleteAccount(ctx context.Context, userID uuid.UUID) error {
	return s.store.InTx(ctx, func(q *sqlcgen.Queries) error {
		_, err := q.MarkUserDeleted(ctx, sqlcgen.MarkUserDeletedParams{
			ID:          userID,
			DisplayName: "Deleted",
			AvatarSeed:  "",
		})
		if err != nil && !errors.Is(err, pgx.ErrNoRows) {
			return fmt.Errorf("mark user deleted: %w", err)
		}

		if err := q.DeleteAuthIdentitiesByUserID(ctx, userID); err != nil {
			return fmt.Errorf("delete auth identities: %w", err)
		}
		if err := q.DeleteRefreshTokensByUserID(ctx, userID); err != nil {
			return fmt.Errorf("delete refresh tokens: %w", err)
		}
		if err := q.DeleteSafetyAcknowledgementsByUserID(ctx, userID); err != nil {
			return fmt.Errorf("delete safety acknowledgements: %w", err)
		}
		if err := q.DeleteSessionsByUserID(ctx, userID); err != nil {
			return fmt.Errorf("delete sessions: %w", err)
		}
		if err := q.DeleteStatsSnapshotByUserID(ctx, userID); err != nil {
			return fmt.Errorf("delete stats snapshot: %w", err)
		}

		return nil
	})
}

func canonicalizeDisplayName(s string) (string, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return "", fmt.Errorf("display_name is required")
	}

	var b strings.Builder
	b.Grow(len(s))

	space := false
	for _, r := range s {
		if r == ' ' || unicode.IsSpace(r) {
			if b.Len() == 0 {
				continue
			}
			if space {
				continue
			}
			b.WriteRune(' ')
			space = true
			continue
		}

		space = false
		if unicode.IsLetter(r) || unicode.IsNumber(r) {
			b.WriteRune(r)
			continue
		}
		return "", fmt.Errorf("display_name has invalid characters")
	}

	out := strings.TrimSpace(b.String())
	n := len([]rune(out))
	if n < 3 || n > 20 {
		return "", fmt.Errorf("display_name must be 3-20 characters")
	}

	return out, nil
}
