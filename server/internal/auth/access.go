package auth

import (
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

type AccessTokenManager struct {
	secret []byte
	ttl    time.Duration
}

type accessClaims struct {
	jwt.RegisteredClaims
}

func NewAccessTokenManager(secret string, ttlMinutes int) (*AccessTokenManager, error) {
	if len(secret) < 32 {
		return nil, fmt.Errorf("access token secret must be at least 32 chars")
	}
	if ttlMinutes <= 0 {
		return nil, fmt.Errorf("access token ttl must be positive")
	}

	return &AccessTokenManager{
		secret: []byte(secret),
		ttl:    time.Duration(ttlMinutes) * time.Minute,
	}, nil
}

func (m *AccessTokenManager) Issue(userID uuid.UUID, now time.Time) (string, time.Time, error) {
	expiresAt := now.Add(m.ttl).UTC()

	claims := accessClaims{
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   userID.String(),
			IssuedAt:  jwt.NewNumericDate(now.UTC()),
			ExpiresAt: jwt.NewNumericDate(expiresAt),
		},
	}

	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	s, err := tok.SignedString(m.secret)
	if err != nil {
		return "", time.Time{}, fmt.Errorf("sign access token: %w", err)
	}

	return s, expiresAt, nil
}

func (m *AccessTokenManager) Parse(tokenString string, now time.Time) (uuid.UUID, error) {
	parser := jwt.NewParser(
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}),
		jwt.WithLeeway(30*time.Second),
		jwt.WithTimeFunc(func() time.Time { return now.UTC() }),
	)

	var claims accessClaims
	tok, err := parser.ParseWithClaims(tokenString, &claims, func(token *jwt.Token) (any, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %s", token.Header["alg"])
		}
		return m.secret, nil
	})
	if err != nil {
		return uuid.UUID{}, err
	}
	if !tok.Valid {
		return uuid.UUID{}, errors.New("invalid token")
	}

	id, err := uuid.Parse(claims.Subject)
	if err != nil {
		return uuid.UUID{}, fmt.Errorf("parse subject: %w", err)
	}

	return id, nil
}
