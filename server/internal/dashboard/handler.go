package dashboard

import (
	"fmt"
	"html/template"
	"log/slog"
	"math"
	"net/http"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/config"
	"github.com/clearbreath/server/internal/logcollector"
)

// Dashboard holds all dependencies for the dashboard handlers.
type Dashboard struct {
	store         *store
	rdb           *redis.Client
	broadcaster   *logcollector.Broadcaster
	templates     *template.Template
	username      string
	passwordHash  string
	sessionSecret string
	env           string
}

// New creates a new Dashboard handler.
func New(pool *pgxpool.Pool, rdb *redis.Client, broadcaster *logcollector.Broadcaster, cfg *config.Config) *Dashboard {
	funcMap := template.FuncMap{
		"formatTime": func(t time.Time) string {
			return t.Format("15:04:05.000")
		},
		"formatDate": func(t time.Time) string {
			return t.Format("2006-01-02 15:04:05")
		},
		"statusBadgeClass": statusBadgeClass,
		"methodBadgeClass": methodBadgeClass,
		"levelBadgeClass":  levelBadgeClass,
		"truncate":         truncate,
		"shortID": func(s string) string {
			if len(s) > 16 {
				return s[:16]
			}
			return s
		},
		"shortUUID": func(u fmt.Stringer) string {
			s := u.String()
			if len(s) > 8 {
				return s[:8]
			}
			return s
		},
		"errorRate": func(total, errors int64) string {
			if total == 0 {
				return "0.0"
			}
			return fmt.Sprintf("%.1f", float64(errors)/float64(total)*100)
		},
		"totalPages": func(total int64, perPage int) int {
			return int(math.Ceil(float64(total) / float64(perPage)))
		},
		"sub": func(a, b int) int { return a - b },
		"add": func(a, b int) int { return a + b },
		"seq": func(start, end int) []int {
			var s []int
			for i := start; i <= end; i++ {
				s = append(s, i)
			}
			return s
		},
	}

	tmpl := template.Must(
		template.New("").Funcs(funcMap).ParseFS(templateFS, "templates/*.html", "templates/partials/*.html"),
	)

	return &Dashboard{
		store:         newStore(pool),
		rdb:           rdb,
		broadcaster:   broadcaster,
		templates:     tmpl,
		username:      cfg.DashboardUsername,
		passwordHash:  cfg.DashboardPasswordHash,
		sessionSecret: cfg.DashboardSessionSecret,
		env:           cfg.Env,
	}
}

// LoginPage renders the login form.
func (d *Dashboard) LoginPage(w http.ResponseWriter, r *http.Request) {
	// If already logged in, redirect
	if _, ok := d.validateSession(r); ok {
		http.Redirect(w, r, "/dashboard/", http.StatusSeeOther)
		return
	}

	d.renderPage(w, "login.html", map[string]interface{}{
		"Error": r.URL.Query().Get("error"),
	})
}

// LoginSubmit handles the login POST.
func (d *Dashboard) LoginSubmit(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Redirect(w, r, "/dashboard/login?error=invalid+request", http.StatusSeeOther)
		return
	}

	if !d.checkLoginRateLimit(r) {
		http.Redirect(w, r, "/dashboard/login?error=too+many+attempts", http.StatusSeeOther)
		return
	}

	username := r.FormValue("username")
	password := r.FormValue("password")

	if username != d.username || !d.verifyPassword(password) {
		http.Redirect(w, r, "/dashboard/login?error=invalid+credentials", http.StatusSeeOther)
		return
	}

	d.clearLoginRateLimit(r)
	d.createSession(w, r, username)
	http.Redirect(w, r, "/dashboard/", http.StatusSeeOther)
}

// Logout clears the session and redirects to login.
func (d *Dashboard) Logout(w http.ResponseWriter, r *http.Request) {
	d.clearSession(w)
	http.Redirect(w, r, "/dashboard/login", http.StatusSeeOther)
}

// Overview renders the main dashboard page.
func (d *Dashboard) Overview(w http.ResponseWriter, r *http.Request) {
	stats, err := d.store.GetOverviewStats(r.Context())
	if err != nil {
		slog.Error("dashboard: failed to get stats", "error", err)
	}

	recentErrors, err := d.store.RecentErrors(r.Context(), 10)
	if err != nil {
		slog.Error("dashboard: failed to get recent errors", "error", err)
	}

	d.renderPage(w, "overview.html", map[string]interface{}{
		"Stats":        stats,
		"RecentErrors": recentErrors,
		"CSRFToken":    d.csrfTokenFromRequest(r),
	})
}

// LogsPage renders the request logs page.
func (d *Dashboard) LogsPage(w http.ResponseWriter, r *http.Request) {
	page, perPage := parsePagination(r)
	filters := RequestLogFilters{
		StatusGroup: r.URL.Query().Get("status"),
		Method:      r.URL.Query().Get("method"),
		Search:      r.URL.Query().Get("search"),
	}

	logs, total, err := d.store.ListRequestLogs(r.Context(), filters, page, perPage)
	if err != nil {
		slog.Error("dashboard: failed to list logs", "error", err)
	}

	d.renderPage(w, "logs.html", map[string]interface{}{
		"Logs":      logs,
		"Total":     total,
		"Page":      page,
		"PerPage":   perPage,
		"Filters":   filters,
		"CSRFToken": d.csrfTokenFromRequest(r),
	})
}

// ErrorsPage renders the errors page.
func (d *Dashboard) ErrorsPage(w http.ResponseWriter, r *http.Request) {
	page, perPage := parsePagination(r)
	filters := RequestLogFilters{
		StatusGroup: "4xx",
		Method:      r.URL.Query().Get("method"),
		Search:      r.URL.Query().Get("search"),
	}

	// Check if user specifically wants 5xx
	statusQ := r.URL.Query().Get("status")
	if statusQ == "5xx" {
		filters.StatusGroup = "5xx"
	}

	logs, total, err := d.store.ListRequestLogs(r.Context(), filters, page, perPage)
	if err != nil {
		slog.Error("dashboard: failed to list errors", "error", err)
	}

	events, eventTotal, err := d.store.ListEventLogs(r.Context(), EventLogFilters{
		Level:  "error",
		Search: r.URL.Query().Get("search"),
	}, page, perPage)
	if err != nil {
		slog.Error("dashboard: failed to list error events", "error", err)
	}

	d.renderPage(w, "errors.html", map[string]interface{}{
		"Logs":       logs,
		"Events":     events,
		"Total":      total,
		"EventTotal": eventTotal,
		"Page":       page,
		"PerPage":    perPage,
		"Filters":    filters,
		"StatusQ":    statusQ,
		"CSRFToken":  d.csrfTokenFromRequest(r),
	})
}

// AuthEventsPage renders the auth events page.
func (d *Dashboard) AuthEventsPage(w http.ResponseWriter, r *http.Request) {
	page, perPage := parsePagination(r)
	filters := EventLogFilters{
		EventType: r.URL.Query().Get("event_type"),
		Search:    r.URL.Query().Get("search"),
	}

	events, total, err := d.store.ListEventLogs(r.Context(), filters, page, perPage)
	if err != nil {
		slog.Error("dashboard: failed to list auth events", "error", err)
	}

	d.renderPage(w, "auth_events.html", map[string]interface{}{
		"Events":    events,
		"Total":     total,
		"Page":      page,
		"PerPage":   perPage,
		"Filters":   filters,
		"CSRFToken": d.csrfTokenFromRequest(r),
	})
}

// LogsAPI returns HTML table rows for HTMX updates.
func (d *Dashboard) LogsAPI(w http.ResponseWriter, r *http.Request) {
	page, perPage := parsePagination(r)
	filters := RequestLogFilters{
		StatusGroup: r.URL.Query().Get("status"),
		Method:      r.URL.Query().Get("method"),
		Search:      r.URL.Query().Get("search"),
	}

	logs, total, err := d.store.ListRequestLogs(r.Context(), filters, page, perPage)
	if err != nil {
		slog.Error("dashboard: failed to list logs", "error", err)
		http.Error(w, "internal error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := d.templates.ExecuteTemplate(w, "log_rows.html", map[string]interface{}{
		"Logs":    logs,
		"Total":   total,
		"Page":    page,
		"PerPage": perPage,
	}); err != nil {
		slog.Error("dashboard: failed to render log rows", "error", err)
	}
}

// EventsAPI returns HTML table rows for HTMX updates.
func (d *Dashboard) EventsAPI(w http.ResponseWriter, r *http.Request) {
	page, perPage := parsePagination(r)
	filters := EventLogFilters{
		Level:     r.URL.Query().Get("level"),
		EventType: r.URL.Query().Get("event_type"),
		Search:    r.URL.Query().Get("search"),
	}

	events, total, err := d.store.ListEventLogs(r.Context(), filters, page, perPage)
	if err != nil {
		slog.Error("dashboard: failed to list events", "error", err)
		http.Error(w, "internal error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := d.templates.ExecuteTemplate(w, "event_rows.html", map[string]interface{}{
		"Events":  events,
		"Total":   total,
		"Page":    page,
		"PerPage": perPage,
	}); err != nil {
		slog.Error("dashboard: failed to render event rows", "error", err)
	}
}

// StatsAPI returns updated stats cards for HTMX polling.
func (d *Dashboard) StatsAPI(w http.ResponseWriter, r *http.Request) {
	stats, err := d.store.GetOverviewStats(r.Context())
	if err != nil {
		slog.Error("dashboard: failed to get stats", "error", err)
		http.Error(w, "internal error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := d.templates.ExecuteTemplate(w, "stats_cards.html", map[string]interface{}{
		"Stats": stats,
	}); err != nil {
		slog.Error("dashboard: failed to render stats", "error", err)
	}
}

func (d *Dashboard) renderPage(w http.ResponseWriter, name string, data map[string]interface{}) {
	if data == nil {
		data = make(map[string]interface{})
	}
	data["ActivePage"] = name

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := d.templates.ExecuteTemplate(w, name, data); err != nil {
		slog.Error("dashboard: failed to render template", "error", err, "template", name)
		http.Error(w, "internal server error", http.StatusInternalServerError)
	}
}

func parsePagination(r *http.Request) (int, int) {
	page := 1
	perPage := 50

	if p := r.URL.Query().Get("page"); p != "" {
		if n, err := strconv.Atoi(p); err == nil && n > 0 {
			page = n
		}
	}
	if pp := r.URL.Query().Get("per_page"); pp != "" {
		if n, err := strconv.Atoi(pp); err == nil && n > 0 && n <= 200 {
			perPage = n
		}
	}

	return page, perPage
}
