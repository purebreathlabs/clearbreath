import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../data/safety_sync_service.dart';
import '../../domain/safety_acknowledgement_repository.dart';
import '../../domain/technique.dart';

class SafetyWarningSheet extends ConsumerStatefulWidget {
  const SafetyWarningSheet({super.key, required this.technique});

  final Technique technique;

  @override
  ConsumerState<SafetyWarningSheet> createState() => _SafetyWarningSheetState();
}

class _SafetyWarningSheetState extends ConsumerState<SafetyWarningSheet> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Material(
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(components.cardRadius),
            side: BorderSide(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(components.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.technique.safety.title,
                        style: typography.titleLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: colors.textTertiary,
                      tooltip: 'Close',
                    ),
                  ],
                ),
                SizedBox(height: spacing.sm),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Text(
                      widget.technique.safety.body,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing.xl),
                FilledButton(
                  onPressed: _saving ? null : _confirm,
                  child: Text(_saving ? 'Saving...' : 'I understand the risks'),
                ),
                SizedBox(height: spacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    if (_saving) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(safetyAckRepositoryProvider)
          .acknowledge(widget.technique.id);
      ref.invalidate(safetyAcksProvider);
      await ref
          .read(safetySyncServiceProvider)
          .pushAcknowledgements([widget.technique.id]);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      final typography = Theme.of(context).extension<AppTypographyTokens>()!;
      final colors = Theme.of(context).extension<AppColorTokens>()!;
      final components = Theme.of(context).extension<AppComponentTokens>()!;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Could not save acknowledgement. Please try again.',
            style: typography.bodyMedium.copyWith(color: colors.inverseText),
          ),
          backgroundColor: colors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(components.buttonRadius),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
