package auth

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"fmt"
	"math/big"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/coreos/go-oidc/v3/oidc"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/clearbreath/server/internal/apierr"
	internalauth "github.com/clearbreath/server/internal/auth"
	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
)

type Service struct {
	store            *repository.Store
	clock            clock.Clock
	accessTokens     *internalauth.AccessTokenManager
	refreshSecret    string
	refreshTTL       time.Duration
	devAuthEnabled   bool
	devAuthSecret    string
	googleClientID   string
	appleAudience    string
	googleVerifier   *oidcVerifier
	appleVerifier    *oidcVerifier
	verifierInitOnce sync.Once
}

type ProviderSignInInput struct {
	Provider      string
	IDToken       string
	DeviceID      string
	DevAuthHeader string
}

type RefreshInput struct {
	RefreshToken string
	DeviceID     string
}

type UserProfile struct {
	ID                      uuid.UUID
	DisplayName             string
	AvatarSeed              string
	LeaderboardOptIn        bool
	LeaderboardInitialsOnly bool
	CreatedAtUTC            time.Time
	TimezoneOffsetMinutes   int32
}

type AuthResult struct {
	AccessToken              string
	AccessTokenExpiresAtUTC  time.Time
	RefreshToken             string
	RefreshTokenExpiresAtUTC time.Time
	User                     UserProfile
}

func NewService(store *repository.Store, clk clock.Clock, accessTokens *internalauth.AccessTokenManager, refreshSecret string, refreshTTLMinutes int, devAuthEnabled bool, devAuthSecret string, googleClientID string, appleAudience string) (*Service, error) {
	if store == nil {
		return nil, fmt.Errorf("store is required")
	}
	if clk == nil {
		return nil, fmt.Errorf("clock is required")
	}
	if accessTokens == nil {
		return nil, fmt.Errorf("access token manager is required")
	}
	if len(refreshSecret) < 32 {
		return nil, fmt.Errorf("refresh token secret must be at least 32 chars")
	}
	if refreshTTLMinutes <= 0 {
		return nil, fmt.Errorf("refresh token ttl must be positive")
	}

	return &Service{
		store:          store,
		clock:          clk,
		accessTokens:   accessTokens,
		refreshSecret:  refreshSecret,
		refreshTTL:     time.Duration(refreshTTLMinutes) * time.Minute,
		devAuthEnabled: devAuthEnabled,
		devAuthSecret:  devAuthSecret,
		googleClientID: googleClientID,
		appleAudience:  appleAudience,
	}, nil
}

func (s *Service) ProviderSignIn(ctx context.Context, in ProviderSignInInput) (*AuthResult, error) {
	if strings.TrimSpace(in.Provider) == "" {
		return nil, apierr.New(http.StatusBadRequest, "validation", "provider is required")
	}
	if strings.TrimSpace(in.DeviceID) == "" {
		return nil, apierr.New(http.StatusBadRequest, "validation", "device_id is required")
	}
	if len(in.DeviceID) > 200 {
		return nil, apierr.New(http.StatusBadRequest, "validation", "device_id is too long")
	}

	subject, err := s.verifyProvider(ctx, in.Provider, in.IDToken, in.DeviceID, in.DevAuthHeader)
	if err != nil {
		return nil, err
	}

	now := s.clock.Now().UTC()
	ageBand := "unknown"
	refreshToken, err := internalauth.NewRefreshToken()
	if err != nil {
		return nil, fmt.Errorf("new refresh token: %w", err)
	}
	refreshExpiresAt := now.Add(s.refreshTTL).UTC()
	refreshHash := internalauth.HashRefreshToken(s.refreshSecret, refreshToken)

	var user sqlcgen.User
	if err := s.store.InTx(ctx, func(q *sqlcgen.Queries) error {
		u, err := s.getOrCreateUserForIdentity(ctx, q, strings.ToLower(strings.TrimSpace(in.Provider)), subject, ageBand)
		if err != nil {
			return err
		}

		if _, err := q.CreateRefreshToken(ctx, sqlcgen.CreateRefreshTokenParams{
			UserID:    u.ID,
			DeviceID:  in.DeviceID,
			TokenHash: refreshHash,
			ExpiresAt: refreshExpiresAt,
		}); err != nil {
			return fmt.Errorf("create refresh token: %w", err)
		}

		user = u
		return nil
	}); err != nil {
		return nil, err
	}

	accessToken, accessExpiresAt, err := s.accessTokens.Issue(user.ID, now)
	if err != nil {
		return nil, err
	}

	return &AuthResult{
		AccessToken:              accessToken,
		AccessTokenExpiresAtUTC:  accessExpiresAt.UTC(),
		RefreshToken:             refreshToken,
		RefreshTokenExpiresAtUTC: refreshExpiresAt.UTC(),
		User:                     toUserProfile(user),
	}, nil
}

func (s *Service) Refresh(ctx context.Context, in RefreshInput) (*AuthResult, error) {
	if strings.TrimSpace(in.RefreshToken) == "" {
		return nil, apierr.New(http.StatusBadRequest, "validation", "refresh_token is required")
	}
	if strings.TrimSpace(in.DeviceID) == "" {
		return nil, apierr.New(http.StatusBadRequest, "validation", "device_id is required")
	}
	if len(in.DeviceID) > 200 {
		return nil, apierr.New(http.StatusBadRequest, "validation", "device_id is too long")
	}

	now := s.clock.Now().UTC()
	hash := internalauth.HashRefreshToken(s.refreshSecret, in.RefreshToken)

	var (
		user                 sqlcgen.User
		newRefreshToken      string
		newRefreshExpiresAt  time.Time
		accessToken          string
		accessTokenExpiresAt time.Time
	)

	if err := s.store.InTx(ctx, func(q *sqlcgen.Queries) error {
		rt, err := q.GetRefreshTokenByHashForUpdate(ctx, hash)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.New(http.StatusUnauthorized, "unauthorized", "invalid refresh token")
			}
			return fmt.Errorf("get refresh token: %w", err)
		}

		if rt.DeviceID != in.DeviceID {
			return apierr.New(http.StatusUnauthorized, "unauthorized", "invalid refresh token")
		}

		if rt.ReplacedBy.Valid {
			return apierr.New(http.StatusConflict, "refresh_replay", "refresh token replay detected")
		}
		if rt.RevokedAt.Valid {
			return apierr.New(http.StatusUnauthorized, "unauthorized", "refresh token revoked")
		}

		if rt.ExpiresAt.Before(now) {
			return apierr.New(http.StatusUnauthorized, "unauthorized", "refresh token expired")
		}

		raw, err := internalauth.NewRefreshToken()
		if err != nil {
			return fmt.Errorf("new refresh token: %w", err)
		}
		newHash := internalauth.HashRefreshToken(s.refreshSecret, raw)
		expiresAt := now.Add(s.refreshTTL).UTC()

		newRow, err := q.CreateRefreshToken(ctx, sqlcgen.CreateRefreshTokenParams{
			UserID:    rt.UserID,
			DeviceID:  rt.DeviceID,
			TokenHash: newHash,
			ExpiresAt: expiresAt,
		})
		if err != nil {
			return fmt.Errorf("create refresh token: %w", err)
		}

		if err := q.ReplaceRefreshToken(ctx, sqlcgen.ReplaceRefreshTokenParams{
			ID:         rt.ID,
			ReplacedBy: pgtype.UUID{Bytes: [16]byte(newRow.ID), Valid: true},
		}); err != nil {
			return fmt.Errorf("replace refresh token: %w", err)
		}

		u, err := q.GetUserByIDAllowDeleted(ctx, rt.UserID)
		if err != nil {
			return fmt.Errorf("get user: %w", err)
		}
		if u.DeletedAt.Valid {
			return apierr.New(http.StatusUnauthorized, "unauthorized", "account is deleted")
		}

		at, atExp, err := s.accessTokens.Issue(u.ID, now)
		if err != nil {
			return err
		}

		user = u
		newRefreshToken = raw
		newRefreshExpiresAt = expiresAt
		accessToken = at
		accessTokenExpiresAt = atExp
		return nil
	}); err != nil {
		return nil, err
	}

	return &AuthResult{
		AccessToken:              accessToken,
		AccessTokenExpiresAtUTC:  accessTokenExpiresAt.UTC(),
		RefreshToken:             newRefreshToken,
		RefreshTokenExpiresAtUTC: newRefreshExpiresAt.UTC(),
		User:                     toUserProfile(user),
	}, nil
}

func (s *Service) Logout(ctx context.Context, userID uuid.UUID, deviceID string) error {
	if strings.TrimSpace(deviceID) == "" {
		return apierr.New(http.StatusBadRequest, "validation", "device_id is required")
	}
	if len(deviceID) > 200 {
		return apierr.New(http.StatusBadRequest, "validation", "device_id is too long")
	}

	if err := s.store.Queries().RevokeUserDeviceRefreshTokens(ctx, sqlcgen.RevokeUserDeviceRefreshTokensParams{
		UserID:   userID,
		DeviceID: deviceID,
	}); err != nil {
		return fmt.Errorf("revoke user device refresh tokens: %w", err)
	}

	return nil
}

func (s *Service) getOrCreateUserForIdentity(ctx context.Context, q *sqlcgen.Queries, provider string, subject string, ageBand string) (sqlcgen.User, error) {
	userID, err := q.GetAuthIdentityUserID(ctx, sqlcgen.GetAuthIdentityUserIDParams{
		Provider:        provider,
		ProviderSubject: subject,
	})
	if err == nil {
		u, err := q.GetUserByIDAllowDeleted(ctx, userID)
		if err != nil {
			return sqlcgen.User{}, fmt.Errorf("get user by id: %w", err)
		}
		if u.DeletedAt.Valid {
			return sqlcgen.User{}, apierr.New(http.StatusForbidden, "account_deleted", "account is deleted")
		}
		return u, nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return sqlcgen.User{}, fmt.Errorf("get auth identity: %w", err)
	}

	displayName, err := generateDisplayName()
	if err != nil {
		return sqlcgen.User{}, err
	}
	avatarSeed, err := generateAvatarSeed()
	if err != nil {
		return sqlcgen.User{}, err
	}

	u, err := q.CreateUser(ctx, sqlcgen.CreateUserParams{
		DisplayName:                 displayName,
		AvatarSeed:                  avatarSeed,
		AgeBand:                     ageBand,
		TimezoneOffsetMinutesLatest: 0,
	})
	if err != nil {
		return sqlcgen.User{}, fmt.Errorf("create user: %w", err)
	}

	if _, err := q.CreateAuthIdentity(ctx, sqlcgen.CreateAuthIdentityParams{
		UserID:          u.ID,
		Provider:        provider,
		ProviderSubject: subject,
	}); err != nil {
		if isUniqueViolation(err) {
			userID, err := q.GetAuthIdentityUserID(ctx, sqlcgen.GetAuthIdentityUserIDParams{
				Provider:        provider,
				ProviderSubject: subject,
			})
			if err != nil {
				return sqlcgen.User{}, fmt.Errorf("get auth identity after conflict: %w", err)
			}
			existing, err := q.GetUserByIDAllowDeleted(ctx, userID)
			if err != nil {
				return sqlcgen.User{}, fmt.Errorf("get user after conflict: %w", err)
			}
			if existing.DeletedAt.Valid {
				return sqlcgen.User{}, apierr.New(http.StatusForbidden, "account_deleted", "account is deleted")
			}
			return existing, nil
		}

		return sqlcgen.User{}, fmt.Errorf("create auth identity: %w", err)
	}

	return u, nil
}

func (s *Service) verifyProvider(ctx context.Context, provider string, idToken string, deviceID string, devAuthHeader string) (string, error) {
	p := strings.ToLower(strings.TrimSpace(provider))

	switch p {
	case "dev":
		if !s.devAuthEnabled {
			return "", apierr.New(http.StatusUnauthorized, "unauthorized", "dev auth is disabled")
		}
		if strings.TrimSpace(devAuthHeader) != s.devAuthSecret {
			return "", apierr.New(http.StatusUnauthorized, "unauthorized", "invalid dev auth secret")
		}

		sub := strings.TrimSpace(idToken)
		if sub == "" {
			sub = strings.TrimSpace(deviceID)
		}
		if sub == "" {
			return "", apierr.New(http.StatusBadRequest, "validation", "id_token is required for dev auth")
		}
		return sub, nil

	case "google":
		if strings.TrimSpace(idToken) == "" {
			return "", apierr.New(http.StatusBadRequest, "validation", "id_token is required")
		}
		if strings.TrimSpace(s.googleClientID) == "" {
			return "", apierr.New(http.StatusInternalServerError, "provider_not_configured", "google auth is not configured")
		}
		v := s.getGoogleVerifier()
		sub, err := v.Verify(ctx, idToken)
		if err != nil {
			return "", err
		}
		return sub, nil

	case "apple":
		if strings.TrimSpace(idToken) == "" {
			return "", apierr.New(http.StatusBadRequest, "validation", "id_token is required")
		}
		if strings.TrimSpace(s.appleAudience) == "" {
			return "", apierr.New(http.StatusInternalServerError, "provider_not_configured", "apple auth is not configured")
		}
		v := s.getAppleVerifier()
		sub, err := v.Verify(ctx, idToken)
		if err != nil {
			return "", err
		}
		return sub, nil

	default:
		return "", apierr.New(http.StatusBadRequest, "validation", "unsupported provider")
	}
}

func (s *Service) getGoogleVerifier() *oidcVerifier {
	s.verifierInitOnce.Do(func() {
		s.googleVerifier = newOIDCVerifier("https://accounts.google.com", s.googleClientID)
		s.appleVerifier = newOIDCVerifier("https://appleid.apple.com", s.appleAudience)
	})
	return s.googleVerifier
}

func (s *Service) getAppleVerifier() *oidcVerifier {
	s.verifierInitOnce.Do(func() {
		s.googleVerifier = newOIDCVerifier("https://accounts.google.com", s.googleClientID)
		s.appleVerifier = newOIDCVerifier("https://appleid.apple.com", s.appleAudience)
	})
	return s.appleVerifier
}

type oidcVerifier struct {
	issuer   string
	clientID string

	mu       sync.Mutex
	verifier *oidc.IDTokenVerifier
}

func newOIDCVerifier(issuer string, clientID string) *oidcVerifier {
	return &oidcVerifier{
		issuer:   issuer,
		clientID: clientID,
	}
}

func (v *oidcVerifier) Verify(ctx context.Context, rawIDToken string) (string, error) {
	verifier, err := v.getVerifier(ctx)
	if err != nil {
		return "", fmt.Errorf("init oidc verifier: %w", err)
	}

	vtCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	tok, err := verifier.Verify(vtCtx, rawIDToken)
	if err != nil {
		return "", apierr.New(http.StatusUnauthorized, "invalid_provider_token", "invalid provider token")
	}
	if strings.TrimSpace(tok.Subject) == "" {
		return "", apierr.New(http.StatusUnauthorized, "invalid_provider_token", "invalid provider token")
	}

	return tok.Subject, nil
}

func (v *oidcVerifier) getVerifier(ctx context.Context) (*oidc.IDTokenVerifier, error) {
	v.mu.Lock()
	defer v.mu.Unlock()

	if v.verifier != nil {
		return v.verifier, nil
	}

	initCtx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	provider, err := oidc.NewProvider(initCtx, v.issuer)
	if err != nil {
		return nil, err
	}

	v.verifier = provider.Verifier(&oidc.Config{
		ClientID: v.clientID,
	})
	return v.verifier, nil
}

func isUniqueViolation(err error) bool {
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		return pgErr.Code == "23505"
	}
	return false
}

func generateDisplayName() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(900000))
	if err != nil {
		return "", fmt.Errorf("random digits: %w", err)
	}
	v := 100000 + n.Int64()
	return fmt.Sprintf("Breather%d", v), nil
}

func generateAvatarSeed() (string, error) {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", fmt.Errorf("random seed: %w", err)
	}
	return base64.RawURLEncoding.EncodeToString(b), nil
}

func toUserProfile(u sqlcgen.User) UserProfile {
	return UserProfile{
		ID:                      u.ID,
		DisplayName:             u.DisplayName,
		AvatarSeed:              u.AvatarSeed,
		LeaderboardOptIn:        u.LeaderboardOptIn,
		LeaderboardInitialsOnly: u.LeaderboardInitialsOnly,
		CreatedAtUTC:            u.CreatedAt.UTC(),
		TimezoneOffsetMinutes:   u.TimezoneOffsetMinutesLatest,
	}
}
