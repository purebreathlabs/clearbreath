package dashboard

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"golang.org/x/crypto/bcrypt"

	"github.com/clearbreath/server/internal/middleware"
)

const (
	sessionCookieName = "dashboard_session"
	sessionTTL        = 24 * time.Hour
	maxLoginAttempts  = 5
	lockoutWindow     = 15 * time.Minute
)

type sessionPayload struct {
	Username  string `json:"u"`
	IssuedAt  int64  `json:"iat"`
	ExpiresAt int64  `json:"exp"`
}

func (d *Dashboard) createSession(w http.ResponseWriter, r *http.Request, username string) {
	now := time.Now().UTC()
	payload := sessionPayload{
		Username:  username,
		IssuedAt:  now.Unix(),
		ExpiresAt: now.Add(sessionTTL).Unix(),
	}

	data, _ := json.Marshal(payload)
	encoded := base64.RawURLEncoding.EncodeToString(data)
	sig := d.sign(encoded)
	cookie := encoded + "." + sig

	secure := d.env != "development"
	http.SetCookie(w, &http.Cookie{
		Name:     sessionCookieName,
		Value:    cookie,
		Path:     "/dashboard",
		HttpOnly: true,
		Secure:   secure,
		SameSite: http.SameSiteStrictMode,
		MaxAge:   int(sessionTTL.Seconds()),
	})
}

func (d *Dashboard) validateSession(r *http.Request) (*sessionPayload, bool) {
	c, err := r.Cookie(sessionCookieName)
	if err != nil || c.Value == "" {
		return nil, false
	}

	// Split into payload.signature
	var encoded, sig string
	for i := len(c.Value) - 1; i >= 0; i-- {
		if c.Value[i] == '.' {
			encoded = c.Value[:i]
			sig = c.Value[i+1:]
			break
		}
	}
	if encoded == "" || sig == "" {
		return nil, false
	}

	// Verify HMAC
	if !hmac.Equal([]byte(d.sign(encoded)), []byte(sig)) {
		return nil, false
	}

	data, err := base64.RawURLEncoding.DecodeString(encoded)
	if err != nil {
		return nil, false
	}

	var payload sessionPayload
	if err := json.Unmarshal(data, &payload); err != nil {
		return nil, false
	}

	if time.Now().UTC().Unix() > payload.ExpiresAt {
		return nil, false
	}

	return &payload, true
}

func (d *Dashboard) clearSession(w http.ResponseWriter) {
	http.SetCookie(w, &http.Cookie{
		Name:     sessionCookieName,
		Value:    "",
		Path:     "/dashboard",
		HttpOnly: true,
		Secure:   true,
		SameSite: http.SameSiteStrictMode,
		MaxAge:   -1,
	})
}

func (d *Dashboard) sign(data string) string {
	mac := hmac.New(sha256.New, []byte(d.sessionSecret))
	mac.Write([]byte(data))
	return base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}

func (d *Dashboard) csrfToken(session string) string {
	mac := hmac.New(sha256.New, []byte(d.sessionSecret))
	mac.Write([]byte("csrf:" + session))
	return base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}

func (d *Dashboard) csrfTokenFromRequest(r *http.Request) string {
	c, err := r.Cookie(sessionCookieName)
	if err != nil {
		return ""
	}
	return d.csrfToken(c.Value)
}

// checkLoginRateLimit returns true if the IP is allowed to attempt login.
func (d *Dashboard) checkLoginRateLimit(r *http.Request) bool {
	ip := middleware.ClientIP(r)
	key := fmt.Sprintf("rl:dashboard:login:%s", ip)

	count, err := d.rdb.Incr(r.Context(), key).Result()
	if err != nil {
		return true // allow on Redis error
	}
	if count == 1 {
		_ = d.rdb.Expire(r.Context(), key, lockoutWindow).Err()
	}
	return count <= maxLoginAttempts
}

func (d *Dashboard) clearLoginRateLimit(r *http.Request) {
	ip := middleware.ClientIP(r)
	key := fmt.Sprintf("rl:dashboard:login:%s", ip)
	_ = d.rdb.Del(r.Context(), key).Err()
}

func (d *Dashboard) verifyPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(d.passwordHash), []byte(password))
	return err == nil
}
