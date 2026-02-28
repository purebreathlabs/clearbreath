package stats

import (
	"testing"
	"time"
)

func TestStreakComputation(t *testing.T) {
	today := time.Date(2026, 2, 16, 0, 0, 0, 0, time.UTC)
	yesterday := today.AddDate(0, 0, -1)
	twoDaysAgo := today.AddDate(0, 0, -2)
	fourDaysAgo := today.AddDate(0, 0, -4)

	tests := []struct {
		name        string
		qualifying  map[time.Time]bool
		wantCurrent int
		wantLongest int
	}{
		{name: "none", qualifying: map[time.Time]bool{}, wantCurrent: 0, wantLongest: 0},
		{
			name:        "yesterday only",
			qualifying:  map[time.Time]bool{yesterday: true},
			wantCurrent: 1,
			wantLongest: 1,
		},
		{
			name:        "three in a row",
			qualifying:  map[time.Time]bool{today: true, yesterday: true, twoDaysAgo: true},
			wantCurrent: 3,
			wantLongest: 3,
		},
		{
			name:        "gap resets",
			qualifying:  map[time.Time]bool{today: true, twoDaysAgo: true, fourDaysAgo: true},
			wantCurrent: 1,
			wantLongest: 1,
		},
		{
			name:        "longest not current",
			qualifying:  map[time.Time]bool{fourDaysAgo: true, fourDaysAgo.AddDate(0, 0, 1): true},
			wantCurrent: 0,
			wantLongest: 2,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := computeCurrentStreak(tt.qualifying, today); got != tt.wantCurrent {
				t.Fatalf("current: got %d, want %d", got, tt.wantCurrent)
			}
			if got := CurrentStreakAtDay(tt.qualifying, today); int(got) != tt.wantCurrent {
				t.Fatalf("current exported: got %d, want %d", got, tt.wantCurrent)
			}
			if got := computeLongestStreak(tt.qualifying); got != tt.wantLongest {
				t.Fatalf("longest: got %d, want %d", got, tt.wantLongest)
			}
		})
	}
}

func TestSnapshotStale(t *testing.T) {
	tests := []struct {
		name      string
		updatedAt time.Time
		now       time.Time
		tz        int32
		want      bool
	}{
		{
			name:      "same local day",
			updatedAt: time.Date(2026, 2, 28, 10, 0, 0, 0, time.UTC),
			now:       time.Date(2026, 2, 28, 18, 0, 0, 0, time.UTC),
			tz:        0,
			want:      false,
		},
		{
			name:      "different local day",
			updatedAt: time.Date(2026, 2, 27, 10, 0, 0, 0, time.UTC),
			now:       time.Date(2026, 2, 28, 10, 0, 0, 0, time.UTC),
			tz:        0,
			want:      true,
		},
		{
			name:      "positive tz same day",
			updatedAt: time.Date(2026, 2, 28, 10, 0, 0, 0, time.UTC),
			now:       time.Date(2026, 2, 28, 15, 0, 0, 0, time.UTC),
			tz:        330,
			want:      false,
		},
		{
			name:      "positive tz crosses local midnight",
			updatedAt: time.Date(2026, 2, 27, 17, 0, 0, 0, time.UTC),
			now:       time.Date(2026, 2, 27, 19, 0, 0, 0, time.UTC),
			tz:        330,
			want:      true,
		},
		{
			name:      "negative tz same day",
			updatedAt: time.Date(2026, 2, 28, 10, 0, 0, 0, time.UTC),
			now:       time.Date(2026, 2, 28, 20, 0, 0, 0, time.UTC),
			tz:        -300,
			want:      false,
		},
		{
			name:      "negative tz crosses local midnight",
			updatedAt: time.Date(2026, 2, 28, 3, 0, 0, 0, time.UTC),
			now:       time.Date(2026, 2, 28, 6, 0, 0, 0, time.UTC),
			tz:        -300,
			want:      true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := snapshotStale(tt.updatedAt, tt.now, tt.tz)
			if got != tt.want {
				t.Fatalf("got %v, want %v", got, tt.want)
			}
		})
	}
}
