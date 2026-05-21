import 'dart:math' as math;
import 'dart:ui';

import '../../core/theme/game_theme_data.dart';
import '../models/direction.dart';
import '../models/position.dart';
import '../models/snake.dart';

/// Draws head (eyes + direction), alternating body, tapered tail.
abstract final class SnakeRenderer {
  static void paint({
    required Canvas canvas,
    required GameThemeData theme,
    required Snake snake,
    required Direction direction,
    required List<Position> previousSegments,
    required double lerp,
    required double cellSize,
    required bool smooth,
    bool glowEffects = true,
  }) {
    if (snake.segments.isEmpty) return;

    final count = snake.segments.length;
    for (var i = 0; i < count; i++) {
      final from = i < previousSegments.length
          ? previousSegments[i]
          : snake.segments[i];
      final to = snake.segments[i];
      final t = smooth ? _ease(lerp) : 1.0;
      final cx = _lerp(from.x.toDouble(), to.x.toDouble(), t) * cellSize + cellSize / 2;
      final cy = _lerp(from.y.toDouble(), to.y.toDouble(), t) * cellSize + cellSize / 2;

      if (i == 0) {
        _paintHead(canvas, theme, cx, cy, cellSize, direction, glowEffects);
      } else if (i == count - 1) {
        _paintTail(canvas, theme, cx, cy, cellSize);
      } else {
        _paintBody(canvas, theme, cx, cy, cellSize, i);
      }
    }
  }

  static double _ease(double t) =>
      t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2) / 2;

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static void _paintHead(
    Canvas canvas,
    GameThemeData theme,
    double cx,
    double cy,
    double cell,
    Direction dir,
    bool glow,
  ) {
    final r = cell * theme.headScale / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    if (glow) {
      canvas.drawCircle(
        rect.center,
        r + 2,
        Paint()
          ..color = theme.snakeHeadGlow.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(r * 0.35)),
      Paint()..color = theme.snakeHead,
    );

    _paintDirectionWedge(canvas, theme, cx, cy, r, dir);
    _paintEyes(canvas, theme, cx, cy, r, dir);
  }

  static void _paintDirectionWedge(
    Canvas canvas,
    GameThemeData theme,
    double cx,
    double cy,
    double r,
    Direction dir,
  ) {
    final (dx, dy) = dir.delta;
    final tip = Offset(cx + dx * r * 0.55, cy + dy * r * 0.55);
    final perpX = -dy * r * 0.28;
    final perpY = dx * r * 0.28;
    final base = Offset(cx - dx * r * 0.15, cy - dy * r * 0.15);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + perpX, base.dy + perpY)
      ..lineTo(base.dx - perpX, base.dy - perpY)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = theme.snakeHeadGlow.withValues(alpha: 0.85),
    );
  }

  static void _paintEyes(
    Canvas canvas,
    GameThemeData theme,
    double cx,
    double cy,
    double r,
    Direction dir,
  ) {
    final (dx, dy) = dir.delta;
    final perpX = -dy;
    final perpY = dx;
    final eyeR = r * 0.18;
    final offsetAlong = r * 0.12;
    final offsetPerp = r * 0.32;

    for (final side in [-1.0, 1.0]) {
      final ex = cx + dx * offsetAlong + perpX * offsetPerp * side;
      final ey = cy + dy * offsetAlong + perpY * offsetPerp * side;
      canvas.drawCircle(Offset(ex, ey), eyeR, Paint()..color = theme.eyeColor);
      canvas.drawCircle(
        Offset(ex + dx * eyeR * 0.35, ey + dy * eyeR * 0.35),
        eyeR * 0.45,
        Paint()..color = theme.scaffold.withValues(alpha: 0.9),
      );
    }
  }

  static void _paintBody(
    Canvas canvas,
    GameThemeData theme,
    double cx,
    double cy,
    double cell,
    int index,
  ) {
    final gap = theme.bodySegmentGap;
    final r = cell * (0.5 - gap);
    final color = index.isEven ? theme.snakeBody : theme.snakeBodyAlt;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        Radius.circular(r * 0.4),
      ),
      Paint()..color = color,
    );
  }

  static void _paintTail(
    Canvas canvas,
    GameThemeData theme,
    double cx,
    double cy,
    double cell,
  ) {
    final r = cell * theme.tailScale / 2;
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = theme.snakeTail.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.5,
      Paint()..color = theme.snakeTail.withValues(alpha: 0.5),
    );
  }
}
