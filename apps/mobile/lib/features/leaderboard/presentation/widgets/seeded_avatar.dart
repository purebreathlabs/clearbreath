import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';

class SeededAvatar extends StatelessWidget {
  const SeededAvatar({super.key, required this.seed, required this.size});

  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final hash = _fnv1a32(seed);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surfaceHigh,
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _IdenticonPainter(hash: hash, color: colors.textPrimary),
      ),
    );
  }
}

class _IdenticonPainter extends CustomPainter {
  _IdenticonPainter({required int hash, required Color color})
    : _hash = hash,
      _paint = Paint()..color = color;

  final int _hash;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.shortestSide * 0.18;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    final cell = rect.width / 5;
    var bit = 0;

    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 3; col++) {
        final on = ((_hash >> bit) & 1) == 1;
        bit = (bit + 1) % 31;
        if (!on) {
          continue;
        }
        _drawCell(canvas, rect, cell, row, col);
        if (col != 2) {
          _drawCell(canvas, rect, cell, row, 4 - col);
        }
      }
    }
  }

  void _drawCell(Canvas canvas, Rect rect, double cell, int row, int col) {
    final x = rect.left + col * cell;
    final y = rect.top + row * cell;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, cell, cell),
      Radius.circular(math.max(1, cell * 0.2)),
    );
    canvas.drawRRect(r, _paint);
  }

  @override
  bool shouldRepaint(covariant _IdenticonPainter oldDelegate) {
    return oldDelegate._hash != _hash ||
        oldDelegate._paint.color != _paint.color;
  }
}

int _fnv1a32(String input) {
  var hash = 0x811C9DC5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}
