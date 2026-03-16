package scheduler

import (
	"context"
	"log/slog"
	"time"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/redis/go-redis/v9"

	"github.com/clearbreath/server/internal/fcm"
	"github.com/clearbreath/server/internal/repository"
	"github.com/clearbreath/server/internal/repository/sqlcgen"
)

// NotificationScheduler ticks every minute and dispatches due push notifications.
type NotificationScheduler struct {
	store  *repository.Store
	sender fcm.Sender
	rdb    *redis.Client
}

func NewNotificationScheduler(store *repository.Store, sender fcm.Sender, rdb *redis.Client) *NotificationScheduler {
	return &NotificationScheduler{
		store:  store,
		sender: sender,
		rdb:    rdb,
	}
}

func (s *NotificationScheduler) Run(ctx context.Context) {
	ticker := time.NewTicker(1 * time.Minute)
	defer ticker.Stop()
	for {
		select {
		case <-ticker.C:
			s.tick(ctx)
		case <-ctx.Done():
			slog.Info("notification scheduler stopped")
			return
		}
	}
}

func (s *NotificationScheduler) tick(ctx context.Context) {
	now := time.Now().UTC()
	minuteKey := now.Format("2006-01-02T15:04")

	// Redis lock: prevent multiple server instances from double-sending
	lockKey := "notif:dispatch:" + minuteKey
	status, err := s.rdb.SetArgs(ctx, lockKey, "1", redis.SetArgs{
		Mode: "NX",
		TTL:  2 * time.Minute,
	}).Result()
	if err == redis.Nil || status != "OK" {
		return
	}
	if err != nil {
		return
	}

	daily, streak := s.dispatch(ctx, now)
	if daily > 0 || streak > 0 {
		slog.Info("notification dispatch completed",
			"daily_sent", daily,
			"streak_sent", streak,
			"minute", minuteKey,
		)
	}
}

func (s *NotificationScheduler) dispatch(ctx context.Context, nowUTC time.Time) (int, int) {
	daily := s.dispatchDailyReminders(ctx, nowUTC)
	streak := s.dispatchStreakWarnings(ctx, nowUTC)
	return daily, streak
}

func (s *NotificationScheduler) dispatchDailyReminders(ctx context.Context, nowUTC time.Time) int {
	timezones, err := s.store.Queries().ListDistinctActiveTimezones(ctx)
	if err != nil {
		slog.Error("scheduler: list active timezones failed", "error", err)
		return 0
	}

	totalSent := 0
	for _, tzName := range timezones {
		loc, err := time.LoadLocation(tzName)
		if err != nil {
			slog.Warn("scheduler: invalid timezone", "timezone", tzName, "error", err)
			continue
		}

		localNow := nowUTC.In(loc)
		localMinute := int32(localNow.Hour()*60 + localNow.Minute())
		localDate := time.Date(localNow.Year(), localNow.Month(), localNow.Day(), 0, 0, 0, 0, time.UTC)

		installations, err := s.store.Queries().GetDueDailyReminders(ctx, sqlcgen.GetDueDailyRemindersParams{
			ReminderTimeMinutes: localMinute,
			TimezoneIana:        tzName,
			Column3:             localDate,
		})
		if err != nil {
			slog.Error("scheduler: get due daily reminders failed", "timezone", tzName, "error", err)
			continue
		}

		for _, inst := range installations {
			result, sendErr := s.sender.Send(ctx, fcm.Message{
				Token:    inst.FcmToken,
				Platform: inst.Platform,
				Title:    "Daily reminder",
				Body:     "Take 2 minutes to breathe today.",
				Data:     map[string]string{"kind": "daily_reminder"},
			})

			if sendErr != nil {
				slog.Error("scheduler: send daily failed", "device_id", inst.DeviceID, "error", sendErr)
				continue
			}

			if result.Unregistered {
				_ = s.store.Queries().DeleteInstallationByFCMToken(ctx, inst.FcmToken)
				continue
			}

			if result.Error != nil {
				errMsg := result.Error.Error()
				_ = s.store.Queries().MarkSendError(ctx, sqlcgen.MarkSendErrorParams{
					DeviceID:      inst.DeviceID,
					LastSendError: &errMsg,
				})
				continue
			}

			_ = s.store.Queries().MarkDailyReminderSent(ctx, sqlcgen.MarkDailyReminderSentParams{
				DeviceID:              inst.DeviceID,
				LastDailySentLocalDay: pgtype.Date{Time: localDate, Valid: true},
			})
			totalSent++
		}
	}

	return totalSent
}

func (s *NotificationScheduler) dispatchStreakWarnings(ctx context.Context, nowUTC time.Time) int {
	timezones, err := s.store.Queries().ListDistinctStreakTimezones(ctx)
	if err != nil {
		slog.Error("scheduler: list streak timezones failed", "error", err)
		return 0
	}

	totalSent := 0
	for _, tzName := range timezones {
		loc, err := time.LoadLocation(tzName)
		if err != nil {
			slog.Warn("scheduler: invalid streak timezone", "timezone", tzName, "error", err)
			continue
		}

		localNow := nowUTC.In(loc)
		if localNow.Hour() != 22 || localNow.Minute() != 0 {
			continue
		}

		localDate := time.Date(localNow.Year(), localNow.Month(), localNow.Day(), 0, 0, 0, 0, time.UTC)

		installations, err := s.store.Queries().GetDueStreakWarnings(ctx, sqlcgen.GetDueStreakWarningsParams{
			TimezoneIana: tzName,
			Column2:      localDate,
		})
		if err != nil {
			slog.Error("scheduler: get due streak warnings failed", "timezone", tzName, "error", err)
			continue
		}

		for _, inst := range installations {
			result, sendErr := s.sender.Send(ctx, fcm.Message{
				Token:    inst.FcmToken,
				Platform: inst.Platform,
				Title:    "Streak at risk",
				Body:     "Practice 2 minutes before midnight to keep your streak.",
				Data:     map[string]string{"kind": "streak_warning"},
			})

			if sendErr != nil {
				slog.Error("scheduler: send streak warning failed", "device_id", inst.DeviceID, "error", sendErr)
				continue
			}

			if result.Unregistered {
				_ = s.store.Queries().DeleteInstallationByFCMToken(ctx, inst.FcmToken)
				continue
			}

			if result.Error != nil {
				errMsg := result.Error.Error()
				_ = s.store.Queries().MarkSendError(ctx, sqlcgen.MarkSendErrorParams{
					DeviceID:      inst.DeviceID,
					LastSendError: &errMsg,
				})
				continue
			}

			_ = s.store.Queries().MarkStreakWarningSent(ctx, sqlcgen.MarkStreakWarningSentParams{
				DeviceID:               inst.DeviceID,
				LastStreakSentLocalDay: pgtype.Date{Time: localDate, Valid: true},
			})
			totalSent++
		}
	}

	return totalSent
}
