import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../core/theme/theme_extensions.dart';

class SlideToBegin extends StatefulWidget {
  const SlideToBegin({
    super.key,
    required this.label,
    required this.onSubmitted,
  });

  final String label;
  final VoidCallback onSubmitted;

  @override
  State<SlideToBegin> createState() => _SlideToBeginState();
}

class _SlideToBeginState extends State<SlideToBegin>
    with SingleTickerProviderStateMixin {
  static const double _submitThreshold = 0.92;

  late final AnimationController _controller;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateDrag(double delta, double availableWidth) {
    if (_submitted) {
      return;
    }
    if (availableWidth <= 0) {
      return;
    }

    _controller.stop();
    final next = (_controller.value + delta / availableWidth).clamp(0.0, 1.0);
    _controller.value = next;
  }

  Future<void> _finishDrag() async {
    if (_submitted) {
      return;
    }

    if (_controller.value >= _submitThreshold) {
      _submitted = true;
      await _controller.animateTo(
        1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
      );
      Vibration.vibrate(duration: 40);
      if (!mounted) {
        return;
      }
      widget.onSubmitted();
      return;
    }

    await _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = components.buttonHeightLarge;
        final padding = 4.0;
        final thumbSize = height - padding * 2;
        final availableWidth = constraints.maxWidth - padding * 2 - thumbSize;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final thumbLeft = padding + _controller.value * availableWidth;
            final fillWidth = thumbLeft + thumbSize;
            final labelOpacity = (1 - _controller.value * 0.7).clamp(0.3, 1.0);

            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                _updateDrag(details.delta.dx, availableWidth);
              },
              onHorizontalDragEnd: (_) => _finishDrag(),
              child: Semantics(
                button: true,
                label: widget.label,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(components.buttonRadius),
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(
                        components.buttonRadius,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: fillWidth,
                            color: colors.surfaceHigh,
                          ),
                        ),
                        Opacity(
                          opacity: labelOpacity,
                          child: Text(
                            widget.label,
                            style: typography.labelLarge.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        Positioned(
                          left: thumbLeft,
                          top: padding,
                          child: Container(
                            width: thumbSize,
                            height: thumbSize,
                            decoration: BoxDecoration(
                              color: colors.textPrimary,
                              borderRadius: BorderRadius.circular(
                                thumbSize / 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _submitted
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              color: colors.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
