import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import 'widgets/level_card.dart';
import 'widgets/stats_section.dart';
import 'widgets/xp_history_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
    final prefs = ref.watch(preferencesProvider);
    final guestUsername = prefs.asData?.value?.guestUsername.trim() ?? '';

    final String nameLabel;
    final String secondaryLabel;
    if (auth is AuthStateSignedIn) {
      final profile = auth.profile;
      nameLabel = profile.name.isNotEmpty ? profile.name : profile.username;
      secondaryLabel = '@${profile.username}';
    } else {
      nameLabel = guestUsername.isNotEmpty ? guestUsername : 'Guest';
      secondaryLabel = '';
    }
    final initials = _initials(nameLabel);

    Future<void> editUsername() async {
      if (auth is! AuthStateSignedIn) {
        return;
      }
      final initialValue = auth.profile.username;
      final next = await showDialog<String>(
        context: context,
        builder: (context) => _EditUsernameDialog(initialValue: initialValue),
      );

      if (next == null) {
        return;
      }
      try {
        await ref.read(authStateProvider.notifier).updateUsername(next);
      } on ApiError catch (e) {
        if (!context.mounted) {
          return;
        }
        showMessage(e.message);
      } catch (_) {
        if (!context.mounted) {
          return;
        }
        showMessage('Could not update username. Please try again.');
      }
    }

    Widget sectionCard(List<Widget> children) {
      return Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(components.cardRadius),
          border: Border.all(color: colors.border),
        ),
        child: Column(children: children),
      );
    }

    Divider divider() => Divider(height: 1, color: colors.divider);

    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colors.surfaceHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: typography.titleLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameLabel,
                            style: typography.titleLarge.copyWith(
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: spacing.xs),
                          if (secondaryLabel.isNotEmpty)
                            Text(
                              secondaryLabel,
                              style: typography.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            )
                          else
                            Text(
                              auth.isGuest
                                  ? 'Guest'
                                  : (auth is AuthStateSignedIn &&
                                            !auth.sessionReady
                                        ? 'Restoring\u2026'
                                        : 'Signed in'),
                              style: typography.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!auth.isGuest)
                      IconButton(
                        onPressed: editUsername,
                        icon: const Icon(Icons.edit_rounded),
                        tooltip: 'Edit username',
                      ),
                  ],
                ),
                if (auth.isGuest) ...[
                  SizedBox(height: spacing.lg),
                  Container(
                    padding: EdgeInsets.all(components.cardPadding),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        components.cardRadius,
                      ),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create an account to sync sessions across devices.',
                          style: typography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        SizedBox(height: spacing.md),
                        FilledButton(
                          onPressed: () => context.push('/auth/sign-in'),
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: spacing.xl),
                const LevelCard(),
                SizedBox(height: spacing.lg),
                const XPHistorySection(),
                SizedBox(height: spacing.xl),
                Text(
                  'Stats',
                  style: typography.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: spacing.sm),
                const StatsSection(),
                SizedBox(height: spacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.push('/profile/stats'),
                    child: const Text('View all stats'),
                  ),
                ),
                SizedBox(height: spacing.xl),
                Text(
                  'Settings',
                  style: typography.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: spacing.sm),
                sectionCard([
                  ListTile(
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/profile/settings'),
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
                  if (!auth.isGuest) ...[
                    divider(),
                    ListTile(
                      title: Text(
                        'Sign out',
                        style: TextStyle(color: colors.destructive),
                      ),
                      onTap: () async {
                        try {
                          await ref.read(authStateProvider.notifier).signOut();
                        } catch (_) {
                          if (context.mounted) {
                            showMessage(
                              'Could not sign out. Please try again.',
                            );
                          }
                        }
                      },
                    ),
                  ],
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditUsernameDialog extends StatefulWidget {
  const _EditUsernameDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<_EditUsernameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close([String? value]) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalInset = spacing.sm;
    final dialogWidth = (screenWidth - horizontalInset * 2).clamp(0.0, 420.0);

    return PopScope<String>(
      onPopInvokedWithResult: (didPop, result) {
        FocusScope.of(context).unfocus();
      },
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: horizontalInset,
          vertical: spacing.lg,
        ),
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(components.cardRadius),
          side: BorderSide(color: colors.border),
        ),
        child: SizedBox(
          key: const Key('edit_username_dialog'),
          width: dialogWidth,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.md,
              spacing.lg,
              spacing.md,
              spacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit username',
                  style: typography.titleLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: spacing.md),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  maxLength: 20,
                  decoration: const InputDecoration(hintText: 'Username'),
                  onSubmitted: (_) => _close(_controller.text.trim()),
                ),
                SizedBox(height: spacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _close(),
                      child: const Text('Cancel'),
                    ),
                    SizedBox(width: spacing.sm),
                    FilledButton(
                      onPressed: () => _close(_controller.text.trim()),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _initials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return 'C';
  }
  final parts = trimmed
      .split(RegExp(r'\s+'))
      .where((p) => p.trim().isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'C';
  }
  if (parts.length == 1) {
    return parts.first.characters.first.toUpperCase();
  }
  final first = parts.first.characters.first.toUpperCase();
  final last = parts.last.characters.first.toUpperCase();
  return '$first$last';
}
