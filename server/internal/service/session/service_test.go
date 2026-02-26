package session

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/clearbreath/server/internal/apierr"
	"github.com/clearbreath/server/internal/clock"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/service/stats"
	"github.com/clearbreath/server/internal/service/xp"
	"github.com/clearbreath/server/internal/technique"
)

var nowForNormalize = time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)

func TestNewServiceValidation(t *testing.T) {
	store := &repository.Store{}
	reg := &technique.Registry{}
	statsSvc := &stats.Service{}
	xpSvc := xp.NewService(nil, nil)
	clk := clock.RealClock{}

	tests := []struct {
		name    string
		store   *repository.Store
		reg     *technique.Registry
		stats   *stats.Service
		xpSvc   *xp.Service
		clock   clock.Clock
		wantErr string
	}{
		{name: "missing store", store: nil, reg: reg, stats: statsSvc, xpSvc: xpSvc, clock: clk, wantErr: "store is required"},
		{name: "missing registry", store: store, reg: nil, stats: statsSvc, xpSvc: xpSvc, clock: clk, wantErr: "registry is required"},
		{name: "missing stats", store: store, reg: reg, stats: nil, xpSvc: xpSvc, clock: clk, wantErr: "stats service is required"},
		{name: "missing xp", store: store, reg: reg, stats: statsSvc, xpSvc: nil, clock: clk, wantErr: "xp service is required"},
		{name: "missing clock", store: store, reg: reg, stats: statsSvc, xpSvc: xpSvc, clock: nil, wantErr: "clock is required"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := NewService(tt.store, tt.reg, tt.stats, tt.xpSvc, tt.clock)
			if err == nil {
				t.Fatalf("expected error")
			}
			if err.Error() != tt.wantErr {
				t.Fatalf("error: got %q, want %q", err.Error(), tt.wantErr)
			}
		})
	}
}

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

	norm, rej := normalizeSession(in, preset, nowForNormalize)
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

	_, rej := normalizeSession(in, preset, nowForNormalize)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Code != "validation" {
		t.Fatalf("code: got %q, want validation", rej.Code)
	}
}

func TestNormalizeSessionRejectsMissingClientSessionID(t *testing.T) {
	preset := technique.Preset{
		ID:                  "beginner",
		MinDurationSeconds:  120,
		MaxDurationSeconds:  1800,
		MinBreathsPerMinute: 4,
		MaxBreathsPerMinute: 7,
	}

	start := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	in := SessionInput{
		ClientSessionID:           " ",
		TechniqueID:               "hrv_resonance",
		PresetID:                  "beginner",
		StartedAtUTC:              start,
		EndedAtUTC:                start.Add(5 * time.Minute),
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 25,
		EndedEarly:                false,
	}

	_, rej := normalizeSession(in, preset, nowForNormalize)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Message != "client_session_id is required" {
		t.Fatalf("message: got %q", rej.Message)
	}
}

func TestNormalizeSessionRejectsInvalidTimezoneOffset(t *testing.T) {
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
		TimezoneOffsetMinutes:     1000,
		BreathsCompletedEstimated: 25,
		EndedEarly:                false,
	}

	_, rej := normalizeSession(in, preset, nowForNormalize)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Message != "timezone_offset_minutes is invalid" {
		t.Fatalf("message: got %q", rej.Message)
	}
}

func TestNormalizeSessionRejectsInvalidTimestamps(t *testing.T) {
	preset := technique.Preset{
		ID:                  "beginner",
		MinDurationSeconds:  120,
		MaxDurationSeconds:  1800,
		MinBreathsPerMinute: 4,
		MaxBreathsPerMinute: 7,
	}

	in := SessionInput{
		ClientSessionID:           "3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
		TechniqueID:               "hrv_resonance",
		PresetID:                  "beginner",
		StartedAtUTC:              time.Time{},
		EndedAtUTC:                time.Time{},
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 0,
		EndedEarly:                false,
	}

	_, rej := normalizeSession(in, preset, nowForNormalize)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Message != "timestamps are invalid" {
		t.Fatalf("message: got %q", rej.Message)
	}
}

func TestNormalizeSessionRejectsZeroDuration(t *testing.T) {
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
		EndedAtUTC:                start,
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 0,
		EndedEarly:                false,
	}

	_, rej := normalizeSession(in, preset, nowForNormalize)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Message != "duration is invalid" {
		t.Fatalf("message: got %q", rej.Message)
	}
}

func TestNormalizeSessionRejectsDurationExceedsMax(t *testing.T) {
	preset := technique.Preset{
		ID:                  "beginner",
		MinDurationSeconds:  120,
		MaxDurationSeconds:  180,
		MinBreathsPerMinute: 4,
		MaxBreathsPerMinute: 7,
	}

	start := time.Date(2026, 2, 16, 12, 0, 0, 0, time.UTC)
	in := SessionInput{
		ClientSessionID:           "3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
		TechniqueID:               "hrv_resonance",
		PresetID:                  "beginner",
		StartedAtUTC:              start,
		EndedAtUTC:                start.Add(4 * time.Minute),
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 0,
		EndedEarly:                false,
	}

	_, rej := normalizeSession(in, preset, nowForNormalize)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Code != "plausibility" {
		t.Fatalf("code: got %q", rej.Code)
	}
	if rej.Message != "duration exceeds preset max" {
		t.Fatalf("message: got %q", rej.Message)
	}
}

func TestNormalizeSessionRejectsDurationBelowPresetMinWhenNotEndedEarly(t *testing.T) {
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
		EndedAtUTC:                start.Add(30 * time.Second),
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 0,
		EndedEarly:                false,
	}

	_, rej := normalizeSession(in, preset, nowForNormalize)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Code != "plausibility" {
		t.Fatalf("code: got %q", rej.Code)
	}
	if rej.Message != "duration below preset min" {
		t.Fatalf("message: got %q", rej.Message)
	}
}

func TestNormalizeSessionRejectsNegativeBreaths(t *testing.T) {
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
		BreathsCompletedEstimated: -1,
		EndedEarly:                false,
	}

	_, rej := normalizeSession(in, preset, nowForNormalize)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Code != "validation" {
		t.Fatalf("code: got %q", rej.Code)
	}
	if rej.Message != "breaths_completed_estimated is invalid" {
		t.Fatalf("message: got %q", rej.Message)
	}
}

func TestSubmitRejectsEmptySessions(t *testing.T) {
	s := &Service{maxSubmit: 200}
	_, err := s.Submit(context.Background(), uuid.New(), nil)
	if err == nil {
		t.Fatalf("expected error")
	}
	e, ok := apierr.As(err)
	if !ok || e.Status != 400 || e.Code != "validation" {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestSubmitRejectsTooManySessions(t *testing.T) {
	s := &Service{maxSubmit: 200}
	sessions := make([]SessionInput, 201)
	_, err := s.Submit(context.Background(), uuid.New(), sessions)
	if err == nil {
		t.Fatalf("expected error")
	}
	e, ok := apierr.As(err)
	if !ok || e.Status != 413 || e.Code != "payload_too_large" {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestClampBreathsEstimateHandlesZeroAndInvalidDuration(t *testing.T) {
	p := technique.Preset{MinBreathsPerMinute: 4, MaxBreathsPerMinute: 7}
	if got := clampBreathsEstimate(0, 300, p); got != 0 {
		t.Fatalf("got %d, want 0", got)
	}
	if got := clampBreathsEstimate(10, 0, p); got != 10 {
		t.Fatalf("got %d, want 10", got)
	}
}

func TestClampBreathsEstimateClampsNegativeBounds(t *testing.T) {
	p := technique.Preset{
		MinBreathsPerMinute: -2,
		MaxBreathsPerMinute: -2,
	}
	if got := clampBreathsEstimate(1, 60, p); got != -1 {
		t.Fatalf("got %d, want -1", got)
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

	norm, rej := normalizeSession(in, preset, nowForNormalize)
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

	_, rej := normalizeSession(in, preset, nowForNormalize)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Code != "plausibility" {
		t.Fatalf("code: got %q, want plausibility", rej.Code)
	}
}

func TestNormalizeSessionLocalDayMidnightBoundaryPositiveOffset(t *testing.T) {
	preset := technique.Preset{
		ID:                  "beginner",
		MinDurationSeconds:  120,
		MaxDurationSeconds:  1800,
		MinBreathsPerMinute: 4,
		MaxBreathsPerMinute: 7,
	}

	start := time.Date(2026, 2, 16, 23, 30, 0, 0, time.UTC)
	in := SessionInput{
		ClientSessionID:           "3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
		TechniqueID:               "hrv_resonance",
		PresetID:                  "beginner",
		StartedAtUTC:              start,
		EndedAtUTC:                start.Add(2 * time.Minute),
		TimezoneOffsetMinutes:     120,
		BreathsCompletedEstimated: 0,
		EndedEarly:                false,
	}

	norm, rej := normalizeSession(in, preset, nowForNormalize)
	if rej != nil {
		t.Fatalf("unexpected reject: %+v", *rej)
	}

	want := time.Date(2026, 2, 17, 0, 0, 0, 0, time.UTC)
	if !norm.LocalDay.Equal(want) {
		t.Fatalf("local_day: got %v, want %v", norm.LocalDay, want)
	}
}

func TestNormalizeSessionLocalDayMidnightBoundaryNegativeOffset(t *testing.T) {
	preset := technique.Preset{
		ID:                  "beginner",
		MinDurationSeconds:  120,
		MaxDurationSeconds:  1800,
		MinBreathsPerMinute: 4,
		MaxBreathsPerMinute: 7,
	}

	start := time.Date(2026, 2, 16, 0, 30, 0, 0, time.UTC)
	in := SessionInput{
		ClientSessionID:           "3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
		TechniqueID:               "hrv_resonance",
		PresetID:                  "beginner",
		StartedAtUTC:              start,
		EndedAtUTC:                start.Add(2 * time.Minute),
		TimezoneOffsetMinutes:     -120,
		BreathsCompletedEstimated: 0,
		EndedEarly:                false,
	}

	norm, rej := normalizeSession(in, preset, nowForNormalize)
	if rej != nil {
		t.Fatalf("unexpected reject: %+v", *rej)
	}

	want := time.Date(2026, 2, 15, 0, 0, 0, 0, time.UTC)
	if !norm.LocalDay.Equal(want) {
		t.Fatalf("local_day: got %v, want %v", norm.LocalDay, want)
	}
}

func TestNormalizeSessionAllowsEndedEarlyBelowPresetMin(t *testing.T) {
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
		EndedAtUTC:                start.Add(30 * time.Second),
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 3,
		EndedEarly:                true,
	}

	norm, rej := normalizeSession(in, preset, nowForNormalize)
	if rej != nil {
		t.Fatalf("unexpected reject: %+v", *rej)
	}

	if norm.DurationSecondsActual != 30 {
		t.Fatalf("duration: got %d, want 30", norm.DurationSecondsActual)
	}
}

func TestNormalizeSessionRejectsEndedEarlyTooShort(t *testing.T) {
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
		EndedAtUTC:                start.Add(9 * time.Second),
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 0,
		EndedEarly:                true,
	}

	_, rej := normalizeSession(in, preset, nowForNormalize)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Code != "plausibility" {
		t.Fatalf("code: got %q, want plausibility", rej.Code)
	}
	if rej.Message != "duration too short" {
		t.Fatalf("message: got %q, want %q", rej.Message, "duration too short")
	}
}

func TestNormalizeSessionRejectsWildBreathsEstimateShortDuration(t *testing.T) {
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
		EndedAtUTC:                start.Add(10 * time.Second),
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 10,
		EndedEarly:                true,
	}

	_, rej := normalizeSession(in, preset, nowForNormalize)
	if rej == nil {
		t.Fatalf("expected reject")
	}
	if rej.Code != "plausibility" {
		t.Fatalf("code: got %q, want plausibility", rej.Code)
	}
	if rej.Message != "breaths estimate not plausible" {
		t.Fatalf("message: got %q, want %q", rej.Message, "breaths estimate not plausible")
	}
}

func TestNormalizeSessionClampsBreathsEstimateShortDuration(t *testing.T) {
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
		EndedAtUTC:                start.Add(10 * time.Second),
		TimezoneOffsetMinutes:     0,
		BreathsCompletedEstimated: 3,
		EndedEarly:                true,
	}

	norm, rej := normalizeSession(in, preset, nowForNormalize)
	if rej != nil {
		t.Fatalf("unexpected reject: %+v", *rej)
	}
	if norm.BreathsCompletedEstimated != 2 {
		t.Fatalf("breaths: got %d, want 2", norm.BreathsCompletedEstimated)
	}
}
