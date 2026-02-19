package technique

import (
	"os"
	"path/filepath"
	"testing"
)

func TestLoadErrors(t *testing.T) {
	tests := []struct {
		name string
		path string
		want string
	}{
		{name: "missing file", path: filepath.Join(t.TempDir(), "missing.json"), want: "read registry"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := Load(tt.path)
			if err == nil {
				t.Fatalf("expected error")
			}
		})
	}
}

func TestLoadValidatesRegistryFile(t *testing.T) {
	tests := []struct {
		name string
		body string
		want string
	}{
		{name: "invalid json", body: "{", want: "decode registry"},
		{name: "missing technique id", body: `{"techniques":[{"id":"","presets":{"beginner":{"min_duration_seconds":120,"max_duration_seconds":1800,"min_breaths_per_minute":4,"max_breaths_per_minute":7}}}]}`, want: "technique id is required"},
		{name: "no presets", body: `{"techniques":[{"id":"t","presets":{}}]}`, want: "has no presets"},
		{name: "preset id mismatch", body: `{"techniques":[{"id":"t","presets":{"beginner":{"id":"other","min_duration_seconds":120,"max_duration_seconds":1800,"min_breaths_per_minute":4,"max_breaths_per_minute":7}}}]}`, want: "preset id mismatch"},
		{name: "duration invalid", body: `{"techniques":[{"id":"t","presets":{"beginner":{"min_duration_seconds":0,"max_duration_seconds":1800,"min_breaths_per_minute":4,"max_breaths_per_minute":7}}}]}`, want: "duration bounds invalid"},
		{name: "bpm invalid", body: `{"techniques":[{"id":"t","presets":{"beginner":{"min_duration_seconds":120,"max_duration_seconds":1800,"min_breaths_per_minute":0,"max_breaths_per_minute":7}}}]}`, want: "bpm bounds invalid"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			dir := t.TempDir()
			path := filepath.Join(dir, "registry.json")
			if err := os.WriteFile(path, []byte(tt.body), 0600); err != nil {
				t.Fatalf("write file: %v", err)
			}

			_, err := Load(path)
			if err == nil {
				t.Fatalf("expected error")
			}
		})
	}
}

func TestLoadFillsPresetIDFromMapKey(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "registry.json")
	body := `{"techniques":[{"id":"t","presets":{"beginner":{"min_duration_seconds":120,"max_duration_seconds":1800,"min_breaths_per_minute":4,"max_breaths_per_minute":7}}}]}`
	if err := os.WriteFile(path, []byte(body), 0600); err != nil {
		t.Fatalf("write file: %v", err)
	}

	r, err := Load(path)
	if err != nil {
		t.Fatalf("load: %v", err)
	}

	p, ok := r.Preset("t", "beginner")
	if !ok {
		t.Fatalf("expected preset")
	}
	if p.ID != "beginner" {
		t.Fatalf("id: got %q, want %q", p.ID, "beginner")
	}
}

func TestRegistryHasTechnique(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "registry.json")
	body := `{"techniques":[{"id":"t","presets":{"beginner":{"min_duration_seconds":120,"max_duration_seconds":1800,"min_breaths_per_minute":4,"max_breaths_per_minute":7}}}]}`
	if err := os.WriteFile(path, []byte(body), 0600); err != nil {
		t.Fatalf("write file: %v", err)
	}

	r, err := Load(path)
	if err != nil {
		t.Fatalf("load: %v", err)
	}
	if !r.HasTechnique("t") {
		t.Fatalf("expected technique")
	}
	if r.HasTechnique("missing") {
		t.Fatalf("expected missing technique")
	}
}
