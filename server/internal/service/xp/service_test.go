package xp

import (
	"math"
	"testing"
)

func TestBuildLevelThresholds(t *testing.T) {
	th := buildLevelThresholds()

	if th[0] != 0 {
		t.Errorf("threshold[0] = %d, want 0", th[0])
	}

	// L0->L1 requires floor(2 + 0 + 0) = 2 XP
	if th[1] != 2 {
		t.Errorf("threshold[1] = %d, want 2", th[1])
	}

	// Verify monotonically increasing
	for i := 1; i < len(th); i++ {
		if th[i] <= th[i-1] {
			t.Errorf("threshold[%d] = %d <= threshold[%d] = %d", i, th[i], i-1, th[i-1])
		}
	}

	// L999 cumulative should be roughly ~60K (sanity check)
	if th[1000] < 50000 || th[1000] > 80000 {
		t.Errorf("threshold[1000] = %d, expected roughly 60K", th[1000])
	}
}

func TestLevelFromTotalXP(t *testing.T) {
	s := NewService(nil, nil)

	tests := []struct {
		xp   int64
		want int32
	}{
		{0, 0},
		{1, 0},
		{2, 1},
		{3, 1},
		{4, 2}, // L1->L2 requires floor(2 + 0.05 + 0.0001) = 2, cumulative = 4
	}

	for _, tt := range tests {
		got := s.LevelFromTotalXP(tt.xp)
		if got != tt.want {
			t.Errorf("LevelFromTotalXP(%d) = %d, want %d", tt.xp, got, tt.want)
		}
	}

	// Verify level 0 at 0 XP
	if l := s.LevelFromTotalXP(0); l != 0 {
		t.Errorf("LevelFromTotalXP(0) = %d, want 0", l)
	}

	// At exactly the cumulative XP for level 999, should be level 999
	xp999 := s.CumulativeXPForLevel(999)
	if l := s.LevelFromTotalXP(xp999); l != 999 {
		t.Errorf("LevelFromTotalXP(%d) = %d, want 999", xp999, l)
	}

	// Even with way more XP, should cap at 999
	if l := s.LevelFromTotalXP(999999); l != 999 {
		t.Errorf("LevelFromTotalXP(999999) = %d, want 999", l)
	}
}

func TestCumulativeXPForLevel(t *testing.T) {
	s := NewService(nil, nil)

	if v := s.CumulativeXPForLevel(0); v != 0 {
		t.Errorf("CumulativeXPForLevel(0) = %d, want 0", v)
	}
	if v := s.CumulativeXPForLevel(1); v != 2 {
		t.Errorf("CumulativeXPForLevel(1) = %d, want 2", v)
	}
	// Negative level
	if v := s.CumulativeXPForLevel(-1); v != 0 {
		t.Errorf("CumulativeXPForLevel(-1) = %d, want 0", v)
	}
}

func TestXPForNextLevel(t *testing.T) {
	s := NewService(nil, nil)

	// L0->L1 = 2
	if v := s.XPForNextLevel(0); v != 2 {
		t.Errorf("XPForNextLevel(0) = %d, want 2", v)
	}

	// Each level's XP should be positive
	for i := int32(0); i <= MaxLevel; i++ {
		v := s.XPForNextLevel(i)
		if v <= 0 {
			t.Errorf("XPForNextLevel(%d) = %d, want > 0", i, v)
		}
	}
}

func TestStreakMultiplier(t *testing.T) {
	tests := []struct {
		streak int32
		want   float64
	}{
		{0, 1.0},
		{1, 1.1},
		{5, 1.5},
		{10, 2.0},
		{20, 3.0},
		{25, 3.0}, // capped
		{100, 3.0},
	}

	for _, tt := range tests {
		got := StreakMultiplier(tt.streak)
		if math.Abs(got-tt.want) > 0.001 {
			t.Errorf("StreakMultiplier(%d) = %f, want %f", tt.streak, got, tt.want)
		}
	}
}

func TestPresetForLevel(t *testing.T) {
	tests := []struct {
		level int32
		want  string
	}{
		{0, "beginner"},
		{14, "beginner"},
		{15, "intermediate"},
		{49, "intermediate"},
		{50, "advanced"},
		{100, "advanced"},
		{999, "advanced"},
	}

	for _, tt := range tests {
		got := PresetForLevel(tt.level)
		if got != tt.want {
			t.Errorf("PresetForLevel(%d) = %q, want %q", tt.level, got, tt.want)
		}
	}
}

func TestDurationMinutesForLevel(t *testing.T) {
	tests := []struct {
		level int32
		want  int
	}{
		{0, 2},
		{9, 2},
		{10, 5},
		{29, 5},
		{30, 10},
		{59, 10},
		{60, 15},
		{99, 15},
		{100, 20},
		{999, 20},
	}

	for _, tt := range tests {
		got := DurationMinutesForLevel(tt.level)
		if got != tt.want {
			t.Errorf("DurationMinutesForLevel(%d) = %d, want %d", tt.level, got, tt.want)
		}
	}
}

func TestSessionXPCalculation(t *testing.T) {
	// 5 min session, no early end, no streak = 5 * 10 = 50 XP
	baseMinutes := 300 / 60
	baseXP := baseMinutes * XPPerFullMinute
	if baseXP != 50 {
		t.Errorf("5min session base XP = %d, want 50", baseXP)
	}

	// 5 min early end: floor(5 * 0.5) = 2 min = 20 XP
	earlyMinutes := int(math.Floor(float64(baseMinutes) * EndedEarlyPenalty))
	earlyXP := earlyMinutes * XPPerFullMinute
	if earlyXP != 20 {
		t.Errorf("5min early-end XP = %d, want 20", earlyXP)
	}

	// 5 min, streak 10 days (2.0x): 50 * 2 = 100 XP
	mult := StreakMultiplier(10)
	withStreak := int(math.Floor(float64(50) * mult))
	if withStreak != 100 {
		t.Errorf("5min streak-10 XP = %d, want 100", withStreak)
	}

	// 5 min, streak 25 days (3.0x capped): 50 * 3 = 150 XP
	mult = StreakMultiplier(25)
	withStreak = int(math.Floor(float64(50) * mult))
	if withStreak != 150 {
		t.Errorf("5min streak-25 XP = %d, want 150", withStreak)
	}

	durationSec := 30
	subMin := (durationSec / 60) * XPPerFullMinute
	if subMin != 0 {
		t.Errorf("30s session XP = %d, want 0", subMin)
	}
}
