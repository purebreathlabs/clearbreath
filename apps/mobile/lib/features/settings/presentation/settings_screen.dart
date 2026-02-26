import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../../notifications/domain/notification_service.dart';
import '../domain/settings_controller.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    void showMessage(String message) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: typography.bodyMedium.copyWith(color: colors.inverseText),
          ),
          backgroundColor: colors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(components.buttonRadius),
          ),
        ),
      );
    }

    final auth = ref.watch(authStateProvider);
    final state = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final packageInfo = ref.watch(packageInfoProvider);

    final reminderTimeOfDay = TimeOfDay(
      hour: state.reminderTimeMinutes ~/ 60,
      minute: state.reminderTimeMinutes % 60,
    );

    Future<void> pickReminderTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: reminderTimeOfDay,
      );
      if (picked == null) {
        return;
      }
      final minutes = picked.hour * 60 + picked.minute;
      await controller.setReminderTime(minutes);
    }

    Widget section(String title, List<Widget> children) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.titleMedium.copyWith(color: colors.textPrimary),
          ),
          SizedBox(height: spacing.sm),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(components.cardRadius),
              border: Border.all(color: colors.border),
            ),
            child: Column(children: children),
          ),
        ],
      );
    }

    Divider divider() => Divider(height: 1, color: colors.divider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                section('Practice', [
                  SwitchListTile(
                    title: const Text('Haptics'),
                    subtitle: const Text('Vibration on phase changes.'),
                    value: state.hapticsEnabled,
                    onChanged: (value) => controller.setHapticsEnabled(value),
                  ),
                  divider(),
                  SwitchListTile(
                    title: const Text('Keep screen awake'),
                    subtitle: const Text('Prevents screen from sleeping.'),
                    value: state.keepScreenAwake,
                    onChanged: (value) => controller.setKeepScreenAwake(value),
                  ),
                ]),
                SizedBox(height: spacing.xl),
                section('Reminders', [
                  SwitchListTile(
                    title: const Text('Daily reminder'),
                    subtitle: const Text('A gentle reminder each day.'),
                    value: state.reminderEnabled,
                    onChanged: (value) => controller.setReminderEnabled(value),
                  ),
                  divider(),
                  ListTile(
                    title: const Text('Reminder time'),
                    subtitle: Text(reminderTimeOfDay.format(context)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    enabled: state.reminderEnabled,
                    onTap: state.reminderEnabled ? pickReminderTime : null,
                  ),
                  divider(),
                  SwitchListTile(
                    title: const Text('Streak warning'),
                    subtitle: const Text('A reminder before midnight.'),
                    value: state.streakWarningEnabled,
                    onChanged: (value) =>
                        controller.setStreakWarningEnabled(value),
                  ),
                ]),
                SizedBox(height: spacing.xl),
                section('Account', [
                  if (auth.isGuest)
                    ListTile(
                      title: const Text('Sign in'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/auth/sign-in'),
                    )
                  else ...[
                    if (auth is AuthStateSignedIn) ...[
                      SwitchListTile(
                        title: const Text('Show me on leaderboard'),
                        value: auth.profile.leaderboardOptIn,
                        onChanged: (value) async {
                          try {
                            await ref
                                .read(authStateProvider.notifier)
                                .setLeaderboardOptIn(value);
                          } on ApiError catch (e) {
                            showMessage(e.message);
                          } catch (_) {
                            showMessage(
                              'Could not update leaderboard setting.',
                            );
                          }
                        },
                      ),
                      divider(),
                      SwitchListTile(
                        title: const Text('Initials only'),
                        value: auth.profile.leaderboardInitialsOnly,
                        onChanged: auth.profile.leaderboardOptIn
                            ? (value) async {
                                try {
                                  await ref
                                      .read(authStateProvider.notifier)
                                      .setLeaderboardInitialsOnly(value);
                                } on ApiError catch (e) {
                                  showMessage(e.message);
                                } catch (_) {
                                  showMessage(
                                    'Could not update leaderboard setting.',
                                  );
                                }
                              }
                            : null,
                      ),
                      divider(),
                    ],
                    ListTile(
                      title: Text(
                        'Sign out',
                        style: TextStyle(color: colors.destructive),
                      ),
                      onTap: () async {
                        try {
                          await ref.read(authStateProvider.notifier).signOut();
                          if (context.mounted) {
                            showMessage('Signed out.');
                          }
                        } catch (_) {
                          if (context.mounted) {
                            showMessage(
                              'Could not sign out. Please try again.',
                            );
                          }
                        }
                      },
                    ),
                    divider(),
                    ListTile(
                      title: Text(
                        'Delete account',
                        style: TextStyle(color: colors.destructive),
                      ),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete account'),
                              content: const Text(
                                'This will permanently delete your account and server data.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed != true) {
                          return;
                        }

                        try {
                          await ref
                              .read(authStateProvider.notifier)
                              .deleteAccount();
                          if (context.mounted) {
                            showMessage('Account deleted.');
                          }
                        } on ApiError catch (e) {
                          if (context.mounted) {
                            showMessage(e.message);
                          }
                        } catch (_) {
                          if (context.mounted) {
                            showMessage(
                              'Could not delete account. Please try again.',
                            );
                          }
                        }
                      },
                    ),
                  ],
                ]),
                SizedBox(height: spacing.xl),
                section('About', [
                  ListTile(
                    title: const Text('Version'),
                    subtitle: packageInfo.when(
                      data: (info) =>
                          Text('${info.version}+${info.buildNumber}'),
                      loading: () => const Text('—'),
                      error: (error, stackTrace) => const Text('—'),
                    ),
                  ),
                  divider(),
                  ListTile(
                    title: const Text('Privacy policy'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/profile/legal/privacy'),
                  ),
                  divider(),
                  ListTile(
                    title: const Text('Terms of service'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/profile/legal/terms'),
                  ),
                  divider(),
                  ListTile(
                    title: const Text('Disclaimer'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/profile/legal/disclaimer'),
                  ),
                ]),
                SizedBox(height: spacing.xl),
                section('Developer', [
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Test notification'),
                    subtitle: const Text('Fire an immediate notification.'),
                    onTap: () =>
                        ref.read(notificationServiceProvider).showTest(),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
