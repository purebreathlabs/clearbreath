import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_extensions.dart';
import '../domain/share_card_renderer.dart';

class ShareButton extends ConsumerStatefulWidget {
  const ShareButton({
    super.key,
    required this.repaintBoundaryKey,
    required this.enabled,
  });

  final GlobalKey repaintBoundaryKey;
  final bool enabled;

  @override
  ConsumerState<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends ConsumerState<ShareButton> {
  var _busy = false;

  Future<void> _share() async {
    if (_busy) {
      return;
    }

    setState(() => _busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await ref.read(shareCardRendererProvider).renderAndShare(
            widget.repaintBoundaryKey,
            filename: 'clearbreath_share.png',
            text: 'ClearBreath',
          );
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
            'Could not share right now.',
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
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: widget.enabled && !_busy ? _share : null,
      child: _busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Share'),
    );
  }
}

