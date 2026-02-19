package stats

import (
	"testing"
	"time"
)

func TestISOWeekStartMonday(t *testing.T) {
	monday := time.Date(2026, 2, 16, 0, 0, 0, 0, time.UTC)
	tuesday := time.Date(2026, 2, 17, 0, 0, 0, 0, time.UTC)
	sunday := time.Date(2026, 2, 22, 0, 0, 0, 0, time.UTC)

	if got := isoWeekStartMonday(monday); !got.Equal(monday) {
		t.Fatalf("monday: got %v, want %v", got, monday)
	}

	if got := isoWeekStartMonday(tuesday); !got.Equal(monday) {
		t.Fatalf("tuesday: got %v, want %v", got, monday)
	}

	if got := isoWeekStartMonday(sunday); !got.Equal(monday) {
		t.Fatalf("sunday: got %v, want %v", got, monday)
	}
}

func TestWeekStartDependsOnTimezoneOffset(t *testing.T) {
	nowUTC := time.Date(2026, 2, 16, 0, 30, 0, 0, time.UTC)
	offsetMinutes := int32(-60)

	localNow := nowUTC.Add(time.Duration(offsetMinutes) * time.Minute)
	today := dateOnly(localNow)
	weekStart := isoWeekStartMonday(today)

	wantToday := time.Date(2026, 2, 15, 0, 0, 0, 0, time.UTC)
	wantWeekStart := time.Date(2026, 2, 9, 0, 0, 0, 0, time.UTC)

	if !today.Equal(wantToday) {
		t.Fatalf("today: got %v, want %v", today, wantToday)
	}
	if !weekStart.Equal(wantWeekStart) {
		t.Fatalf("week_start: got %v, want %v", weekStart, wantWeekStart)
	}
}
