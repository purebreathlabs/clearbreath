package dashboard

import (
	"net/http"
	"strings"
)

// HostCheck returns middleware that verifies the Host header matches the dashboard host.
// In development or when dashboardHost is empty, all hosts are allowed.
func HostCheck(dashboardHost string, env string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if dashboardHost == "" || env == "development" {
				next.ServeHTTP(w, r)
				return
			}

			host := r.Host
			if idx := strings.LastIndex(host, ":"); idx != -1 {
				host = host[:idx]
			}

			expected := dashboardHost
			if idx := strings.LastIndex(expected, ":"); idx != -1 {
				expected = expected[:idx]
			}

			if !strings.EqualFold(host, expected) {
				http.NotFound(w, r)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

// RequireSession is middleware that checks for a valid dashboard session cookie.
func (d *Dashboard) RequireSession(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if _, ok := d.validateSession(r); !ok {
			http.Redirect(w, r, "/dashboard/login", http.StatusSeeOther)
			return
		}
		next.ServeHTTP(w, r)
	})
}
