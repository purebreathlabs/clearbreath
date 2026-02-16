package session

import (
	"testing"
	"time"

	"github.com/clearbreath/server/internal/technique"
)

func TestNormalizeSessionValid(t *testing.T) {
	preset := technique.Preset{
		ID:                  "beginner",
		MinDurationSeconds:  120,
		MaxDurationSeconds:  1800,
		MinBreathsPerMinute: 4,
		MaxBreathsPerMinute: 7,
	}

	start := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	in := SessionInput{
		ClientSessionID:           "3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
		TechniqueID:               "hrv_resonance",
		PresetID:                  "beginner",
		StartedAtUTC:              start,
		EndedAtUTC:                start.Add(5 * time.Minute),
		TimezoneOffsetMinutes:     60,
		BreathsCompletedEstimated: 25,
		EndedEarly:                false,
	}

	norm, rej := normalizeSession(in, preset)
	if rej != nil {
		t.Fatalf("unexpected reject: %+v", *rej)
	}

	if norm.DurationSecondsActual != 300 {
		t.Fatalf("duration: got %d, want 300", norm.DurationSecondsActual)
	}
	if norm.BreathsCompletedEstimated != 25 {
		t.Fatalf("breaths: got %d, want 25", norm.BreathsCompletedEstimated)
	}
}

func TestNormalizeSessionRejectsInvalidUUID(t *testing.T) {
	preset := technique.Preset{
		ID:                  "beginner",
		MinDurationSeconds:  120,
		MaxDurationSeconds:  1800,
		MinBreathsPerMinute: 4,
		MaxBreathsPerMinute: 7,
	}

	start := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	in := SessionInput{
		ClientSessionID:           "not-a-uuid",
		TechniqueID:               "hrv_resonance",
		PresetID:                  "beginner",
		StartedAtUTC:              start,
		EndedAtUTC:                start.Add(5 * time.Minute),
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 25,
		EndedEarly:                false,
	}

	_, rej := normalizeSession(in, preset)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Code != "validation" {
		t.Fatalf("code: got %q, want validation", rej.Code)
	}
}

func TestNormalizeSessionClampsBreathsEstimate(t *testing.T) {
	preset := technique.Preset{
		ID:                  "beginner",
		MinDurationSeconds:  120,
		MaxDurationSeconds:  1800,
		MinBreathsPerMinute: 4,
		MaxBreathsPerMinute: 7,
	}

	start := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	in := SessionInput{
		ClientSessionID:           "3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
		TechniqueID:               "hrv_resonance",
		PresetID:                  "beginner",
		StartedAtUTC:              start,
		EndedAtUTC:                start.Add(5 * time.Minute),
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 50,
		EndedEarly:                false,
	}

	norm, rej := normalizeSession(in, preset)
	if rej != nil {
		t.Fatalf("unexpected reject: %+v", *rej)
	}

	if norm.BreathsCompletedEstimated != 35 {
		t.Fatalf("breaths: got %d, want 35", norm.BreathsCompletedEstimated)
	}
}

func TestNormalizeSessionRejectsWildBreathsEstimate(t *testing.T) {
	preset := technique.Preset{
		ID:                  "beginner",
		MinDurationSeconds:  120,
		MaxDurationSeconds:  1800,
		MinBreathsPerMinute: 4,
		MaxBreathsPerMinute: 7,
	}

	start := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	in := SessionInput{
		ClientSessionID:           "3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
		TechniqueID:               "hrv_resonance",
		PresetID:                  "beginner",
		StartedAtUTC:              start,
		EndedAtUTC:                start.Add(5 * time.Minute),
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 200,
		EndedEarly:                false,
	}

	_, rej := normalizeSession(in, preset)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Code != "plausibility" {
		t.Fatalf("code: got %q, want plausibility", rej.Code)
	}
}
