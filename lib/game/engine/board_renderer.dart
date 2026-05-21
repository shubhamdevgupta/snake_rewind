import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart' show RadialGradient;

import '../../core/theme/game_theme_data.dart';
import '../models/food.dart';
import '../models/position.dart';

abstract final class BoardRenderer {
  static void paintBoard({
    required Canvas canvas,
    required GameThemeData theme,
    required double boardW,
    required double boardH,
    required double cellSize,
    required bool showGrid,
  }) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, boardW, boardH),
      Paint()..color = theme.board,
    );

    if (!showGrid) return;

    final line = Paint()
      ..color = theme.gridLine
      ..strokeWidth = 0.5;
    final cols = (boardW / cellSize).round();
    final rows = (boardH / cellSize).round();
    for (var c = 0; c <= cols; c++) {
      final x = c * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, boardH), line);
    }
    for (var r = 0; r <= rows; r++) {
      final y = r * cellSize;
      canvas.drawLine(Offset(0, y), Offset(boardW, y), line);
    }
  }

  static void paintFood({
    required Canvas canvas,
    required GameThemeData theme,
    required Food food,
    required Position? prevFood,
    required double foodLerp,
    required double cellSize,
    required double time,
    required bool smooth,
    bool animated = true,
  }) {
    final from = prevFood ?? food.position;
    final t = smooth ? foodLerp.clamp(0.0, 1.0) : 1.0;
    final fx = (from.x + (food.position.x - from.x) * t) * cellSize;
    final fy = (from.y + (food.position.y - from.y) * t) * cellSize;
    final center = Offset(fx + cellSize / 2, fy + cellSize / 2);

    final pulse = animated ? 0.85 + 0.15 * math.sin(time * 5) : 1.0;
    final radius = cellSize * 0.32 * pulse;

    if (animated) {
      canvas.drawCircle(
        center,
        radius + 4,
        Paint()
          ..color = theme.foodGlow.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    canvas.drawCircle(center, radius, Paint()..color = theme.food);
    canvas.drawCircle(
      center,
      radius * 0.35,
      Paint()..color = theme.foodGlow.withValues(alpha: 0.7),
    );
  }

  static void paintCrtOverlay(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x12000000);
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x00000000),
          const Color(0x40000000),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  static void paintEatFlash(
    Canvas canvas,
    Offset center,
    double cellSize,
    double flash,
    Color color,
  ) {
    if (flash <= 0) return;
    canvas.drawCircle(
      center,
      cellSize * 0.5 * flash,
      Paint()..color = color.withValues(alpha: flash * 0.6),
    );
  }
}
