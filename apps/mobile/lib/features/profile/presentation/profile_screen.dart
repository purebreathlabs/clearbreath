import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../../settings/data/settings_repository.dart';
import 'widgets/stats_section.dart';

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
    final localDisplayName = prefs.asData?.value?.displayName.trim() ?? '';
    final signedInName = auth is AuthStateSignedIn
        ? auth.profile.displayName.trim()
        : '';
    final nameLabel = signedInName.isNotEmpty
        ? signedInName
        : (localDisplayName.isEmpty ? 'Guest' : localDisplayName);
    final initials = _initials(nameLabel);

    Future<void> editName() async {
      final controller = TextEditingController(
        text: auth is AuthStateSignedIn ? signedInName : localDisplayName,
      );
      final next = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit name'),
            content: TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(hintText: 'Display name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (next == null) {
        return;
      }
      try {
        if (auth is AuthStateSignedIn) {
          await ref.read(authStateProvider.notifier).updateDisplayName(next);
        } else {
          await ref.read(settingsRepositoryProvider).setDisplayName(next);
        }
      } on ApiError catch (e) {
        if (!context.mounted) {
          return;
        }
        showMessage(e.message);
      } catch (_) {
        if (!context.mounted) {
          return;
        }
        showMessage('Could not update name. Please try again.');
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
      appBar: AppBar(title: const Text('Profile')),
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
                          Text(
                            auth.isGuest ? 'Guest' : 'Signed in',
                            style: typography.bodyMedium.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: editName,
                      icon: const Icon(Icons.edit_rounded),
                      tooltip: 'Edit name',
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
                ]),
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
      .split(RegExp(r'\\s+'))
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
