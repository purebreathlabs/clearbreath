package safety

import (
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/technique"
)

func TestNormalizeTechniqueIDs(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "registry.json")
	body := `{"techniques":[{"id":"kapalbhati","presets":{"beginner":{"min_duration_seconds":120,"max_duration_seconds":1800,"min_breaths_per_minute":30,"max_breaths_per_minute":90}}}]}`
	if err := os.WriteFile(path, []byte(body), 0600); err != nil {
		t.Fatalf("write file: %v", err)
	}
	reg, err := technique.Load(path)
	if err != nil {
		t.Fatalf("load registry: %v", err)
	}

	tests := []struct {
		name   string
		in     []string
		want   []string
		status int
		code   string
		msg    string
	}{
		{name: "required", in: nil, status: http.StatusBadRequest, code: "validation", msg: "technique_ids is required"},
		{name: "too large", in: make([]string, 51), status: http.StatusBadRequest, code: "validation", msg: "technique_ids is too large"},
		{name: "empty value", in: []string{""}, status: http.StatusBadRequest, code: "validation", msg: "technique_ids contains empty value"},
		{name: "invalid technique", in: []string{"missing"}, status: http.StatusBadRequest, code: "validation", msg: "technique_id is invalid"},
		{name: "normalizes and dedupes", in: []string{" Kapalbhati ", "kapalbhati"}, want: []string{"kapalbhati"}},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			ids, err := normalizeTechniqueIDs(reg, tt.in)
			if tt.msg != "" {
				if err == nil {
					t.Fatalf("expected error")
				}
				e, ok := apierr.As(err)
				if !ok {
					t.Fatalf("expected apierr, got %T", err)
				}
				if e.Status != tt.status {
					t.Fatalf("status: got %d, want %d", e.Status, tt.status)
				}
				if e.Code != tt.code {
					t.Fatalf("code: got %q, want %q", e.Code, tt.code)
				}
				if e.Message != tt.msg {
					t.Fatalf("message: got %q, want %q", e.Message, tt.msg)
				}
				return
			}

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if strings.Join(ids, ",") != strings.Join(tt.want, ",") {
				t.Fatalf("got %v, want %v", ids, tt.want)
			}
		})
	}
}
