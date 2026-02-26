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
	"github.com/jackc/pgx/v5/pgconn"

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
	Username                    string
	Name                        string
	AvatarSeed                  string
	LeaderboardOptIn            bool
	CreatedAtUTC                string
	TimezoneOffsetMinutesLatest int32
}

type UpdateInput struct {
	Username         *string
	LeaderboardOptIn *bool
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

		if in.Username != nil {
			n, err := CanonicalizeUsername(*in.Username)
			if err != nil {
				return apierr.New(http.StatusBadRequest, "validation", err.Error())
			}
			if s.filter.HasProfanity(n) {
				return apierr.New(http.StatusBadRequest, "validation", "username contains profanity")
			}
			if !strings.EqualFold(n, u.Username) {
				exists, err := q.CheckUsernameExists(ctx, n)
				if err != nil {
					return fmt.Errorf("check username: %w", err)
				}
				if exists {
					return apierr.New(http.StatusConflict, "username_taken", "username is taken")
				}
				u, err = q.UpdateUsername(ctx, sqlcgen.UpdateUsernameParams{
					ID:       userID,
					Username: n,
				})
				if err != nil {
					if isUniqueViolation(err) {
						return apierr.New(http.StatusConflict, "username_taken", "username is taken")
					}
					return fmt.Errorf("update username: %w", err)
				}
			}
		}

		optIn := u.LeaderboardOptIn
		if in.LeaderboardOptIn != nil {
			optIn = *in.LeaderboardOptIn
		}

		if optIn != u.LeaderboardOptIn {
			u, err = q.UpdateUserLeaderboardPrefs(ctx, sqlcgen.UpdateUserLeaderboardPrefsParams{
				ID:               userID,
				LeaderboardOptIn: optIn,
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

func isUniqueViolation(err error) bool {
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		return pgErr.Code == "23505"
	}
	return false
}

func (s *Service) DeleteAccount(ctx context.Context, userID uuid.UUID) error {
	return s.store.InTx(ctx, func(q *sqlcgen.Queries) error {
		_, err := q.MarkUserDeleted(ctx, sqlcgen.MarkUserDeletedParams{
			ID:         userID,
			Username:   "deleted_" + userID.String()[:8],
			AvatarSeed: "",
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
		if err := q.DeleteXPEventsByUser(ctx, userID); err != nil {
			return fmt.Errorf("delete xp events: %w", err)
		}
		if err := q.DeleteUserProgress(ctx, userID); err != nil {
			return fmt.Errorf("delete user progress: %w", err)
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

func CanonicalizeUsername(s string) (string, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return "", fmt.Errorf("username is required")
	}

	s = strings.ToLower(s)

	var b strings.Builder
	b.Grow(len(s))
	for _, r := range s {
		if (r >= 'a' && r <= 'z') || (r >= '0' && r <= '9') || r == '_' {
			b.WriteRune(r)
			continue
		}
		return "", fmt.Errorf("username has invalid characters")
	}

	out := strings.Trim(b.String(), "_")
	n := len([]rune(out))
	if n < 3 || n > 20 {
		return "", fmt.Errorf("username must be 3-20 characters")
	}

	if strings.HasPrefix(out, "_") || strings.HasSuffix(out, "_") {
		return "", fmt.Errorf("username must not start or end with underscore")
	}

	return out, nil
}

func CanonicalizeName(s string) (string, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return "", fmt.Errorf("name is required")
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
		return "", fmt.Errorf("name has invalid characters")
	}

	out := strings.TrimSpace(b.String())
	n := len([]rune(out))
	if n < 3 || n > 20 {
		return "", fmt.Errorf("name must be 3-20 characters")
	}

	return out, nil
}
