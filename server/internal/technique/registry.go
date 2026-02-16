package technique

import (
	"encoding/json"
	"fmt"
	"os"
)

type Registry struct {
	byTechnique map[string]Technique
}

type Technique struct {
	ID      string            `json:"id"`
	Presets map[string]Preset `json:"presets"`
}

type Preset struct {
	ID                  string  `json:"id"`
	MinDurationSeconds  int     `json:"min_duration_seconds"`
	MaxDurationSeconds  int     `json:"max_duration_seconds"`
	MinBreathsPerMinute float64 `json:"min_breaths_per_minute"`
	MaxBreathsPerMinute float64 `json:"max_breaths_per_minute"`
}

type registryFile struct {
	Techniques []Technique `json:"techniques"`
}

func Load(path string) (*Registry, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read registry: %w", err)
	}

	var rf registryFile
	if err := json.Unmarshal(b, &rf); err != nil {
		return nil, fmt.Errorf("decode registry: %w", err)
	}

	byTechnique := make(map[string]Technique, len(rf.Techniques))
	for _, t := range rf.Techniques {
		if t.ID == "" {
			return nil, fmt.Errorf("technique id is required")
		}
		if len(t.Presets) == 0 {
			return nil, fmt.Errorf("technique %s has no presets", t.ID)
		}
		for id, p := range t.Presets {
			if p.ID == "" {
				p.ID = id
			}
			if p.ID != id {
				return nil, fmt.Errorf("technique %s preset id mismatch", t.ID)
			}
			if p.MinDurationSeconds <= 0 || p.MaxDurationSeconds <= 0 || p.MinDurationSeconds > p.MaxDurationSeconds {
				return nil, fmt.Errorf("technique %s preset %s duration bounds invalid", t.ID, p.ID)
			}
			if p.MinBreathsPerMinute <= 0 || p.MaxBreathsPerMinute <= 0 || p.MinBreathsPerMinute > p.MaxBreathsPerMinute {
				return nil, fmt.Errorf("technique %s preset %s bpm bounds invalid", t.ID, p.ID)
			}
			t.Presets[id] = p
		}
		byTechnique[t.ID] = t
	}

	return &Registry{byTechnique: byTechnique}, nil
}

func (r *Registry) Preset(techniqueID string, presetID string) (Preset, bool) {
	t, ok := r.byTechnique[techniqueID]
	if !ok {
		return Preset{}, false
	}
	p, ok := t.Presets[presetID]
	if !ok {
		return Preset{}, false
	}
	return p, true
}
