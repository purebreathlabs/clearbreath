package stats

import (
	"testing"
	"time"

	"github.com/clearbreath/server/internal/repository/sqlcgen"
)

func TestWeeklyWindowUsesMondayStartAndNegativeOffsets(t *testing.T) {
	now := time.Date(2026, 2, 18, 12, 0, 0, 0, time.UTC)

	currentStart, currentEnd := weeklyWindow(now, 0, 0)
	if !currentStart.Equal(time.Date(2026, 2, 16, 0, 0, 0, 0, time.UTC)) {
		t.Fatalf("current start: got %v", currentStart)
	}
	if !currentEnd.Equal(time.Date(2026, 2, 23, 0, 0, 0, 0, time.UTC)) {
		t.Fatalf("current end: got %v", currentEnd)
	}

	previousStart, previousEnd := weeklyWindow(now, 0, -1)
	if !previousStart.Equal(time.Date(2026, 2, 9, 0, 0, 0, 0, time.UTC)) {
		t.Fatalf("previous start: got %v", previousStart)
	}
	if !previousEnd.Equal(time.Date(2026, 2, 16, 0, 0, 0, 0, time.UTC)) {
		t.Fatalf("previous end: got %v", previousEnd)
	}
}

func TestBuildWeeklyMinutesByDayFillsMissingDays(t *testing.T) {
	weekStart := time.Date(2026, 2, 16, 0, 0, 0, 0, time.UTC)
	rows := []sqlcgen.GetSessionDayTotalsInRangeRow{
		{LocalDay: weekStart, TotalSeconds: 120},
		{LocalDay: weekStart.AddDate(0, 0, 2), TotalSeconds: 300},
		{LocalDay: weekStart.AddDate(0, 0, 6), TotalSeconds: 60},
	}

	got := buildWeeklyMinutesByDay(rows, weekStart)
	want := []int32{2, 0, 5, 0, 0, 0, 1}

	if len(got) != len(want) {
		t.Fatalf("length: got %d, want %d", len(got), len(want))
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("day %d: got %d, want %d", i, got[i], want[i])
		}
	}
}
