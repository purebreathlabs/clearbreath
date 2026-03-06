package handler

import (
	"context"
	"log/slog"
	"time"

	"github.com/jackc/pgx/v5/pgtype"

	"github.com/clearbreath/server/internal/fcm"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
)

// dispatchDue runs the notification dispatch logic for a given UTC time.
// Used by both the scheduler and the dev dispatch endpoint.
func dispatchDue(ctx context.Context, store *repository.Store, sender fcm.Sender, nowUTC time.Time) (dailySent int, streakSent int, err error) {
	daily, err := dispatchDailyReminders(ctx, store, sender, nowUTC)
	if err != nil {
		slog.Error("dispatch daily reminders failed", "error", err)
	}

	streak, err2 := dispatchStreakWarnings(ctx, store, sender, nowUTC)
	if err2 != nil {
		slog.Error("dispatch streak warnings failed", "error", err2)
		if err == nil {
			err = err2
		}
	}

	return daily, streak, err
}

func dispatchDailyReminders(ctx context.Context, store *repository.Store, sender fcm.Sender, nowUTC time.Time) (int, error) {
	timezones, err := store.Queries().ListDistinctActiveTimezones(ctx)
	if err != nil {
		return 0, err
	}

	totalSent := 0
	for _, tzName := range timezones {
		loc, err := time.LoadLocation(tzName)
		if err != nil {
			slog.Warn("dispatch: invalid timezone in DB", "timezone", tzName, "error", err)
			continue
		}

		localNow := nowUTC.In(loc)
		localMinute := int32(localNow.Hour()*60 + localNow.Minute())
		localDate := time.Date(localNow.Year(), localNow.Month(), localNow.Day(), 0, 0, 0, 0, time.UTC)

		installations, err := store.Queries().GetDueDailyReminders(ctx, sqlcgen.GetDueDailyRemindersParams{
			ReminderTimeMinutes: localMinute,
			TimezoneIana:        tzName,
			Column3:             localDate,
		})
		if err != nil {
			slog.Error("dispatch: get due daily reminders failed", "timezone", tzName, "error", err)
			continue
		}

		for _, inst := range installations {
			result, sendErr := sender.Send(ctx, fcm.Message{
				Token:    inst.FcmToken,
				Platform: inst.Platform,
				Title:    "Daily reminder",
				Body:     "Take 2 minutes to breathe today.",
				Data:     map[string]string{"kind": "daily_reminder"},
			})

			if sendErr != nil {
				slog.Error("dispatch: send daily failed", "device_id", inst.DeviceID, "error", sendErr)
				continue
			}

			if result.Unregistered {
				_ = store.Queries().DeleteInstallationByFCMToken(ctx, inst.FcmToken)
				continue
			}

			if result.Error != nil {
				errMsg := result.Error.Error()
				_ = store.Queries().MarkSendError(ctx, sqlcgen.MarkSendErrorParams{
					DeviceID:      inst.DeviceID,
					LastSendError: &errMsg,
				})
				continue
			}

			_ = store.Queries().MarkDailyReminderSent(ctx, sqlcgen.MarkDailyReminderSentParams{
				DeviceID:             inst.DeviceID,
				LastDailySentLocalDay: pgtype.Date{Time: localDate, Valid: true},
			})
			totalSent++
		}
	}

	return totalSent, nil
}

func dispatchStreakWarnings(ctx context.Context, store *repository.Store, sender fcm.Sender, nowUTC time.Time) (int, error) {
	timezones, err := store.Queries().ListDistinctStreakTimezones(ctx)
	if err != nil {
		return 0, err
	}

	totalSent := 0
	for _, tzName := range timezones {
		loc, err := time.LoadLocation(tzName)
		if err != nil {
			slog.Warn("dispatch: invalid streak timezone in DB", "timezone", tzName, "error", err)
			continue
		}

		localNow := nowUTC.In(loc)
		// Streak warnings fire at 22:00 local time
		if localNow.Hour() != 22 || localNow.Minute() != 0 {
			continue
		}

		localDate := time.Date(localNow.Year(), localNow.Month(), localNow.Day(), 0, 0, 0, 0, time.UTC)

		installations, err := store.Queries().GetDueStreakWarnings(ctx, sqlcgen.GetDueStreakWarningsParams{
			TimezoneIana: tzName,
			Column2:      localDate,
		})
		if err != nil {
			slog.Error("dispatch: get due streak warnings failed", "timezone", tzName, "error", err)
			continue
		}

		for _, inst := range installations {
			result, sendErr := sender.Send(ctx, fcm.Message{
				Token:    inst.FcmToken,
				Platform: inst.Platform,
				Title:    "Streak at risk",
				Body:     "Practice 2 minutes before midnight to keep your streak.",
				Data:     map[string]string{"kind": "streak_warning"},
			})

			if sendErr != nil {
				slog.Error("dispatch: send streak warning failed", "device_id", inst.DeviceID, "error", sendErr)
				continue
			}

			if result.Unregistered {
				_ = store.Queries().DeleteInstallationByFCMToken(ctx, inst.FcmToken)
				continue
			}

			if result.Error != nil {
				errMsg := result.Error.Error()
				_ = store.Queries().MarkSendError(ctx, sqlcgen.MarkSendErrorParams{
					DeviceID:      inst.DeviceID,
					LastSendError: &errMsg,
				})
				continue
			}

			_ = store.Queries().MarkStreakWarningSent(ctx, sqlcgen.MarkStreakWarningSentParams{
				DeviceID:              inst.DeviceID,
				LastStreakSentLocalDay: pgtype.Date{Time: localDate, Valid: true},
			})
			totalSent++
		}
	}

	return totalSent, nil
}
