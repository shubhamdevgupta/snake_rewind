import '../../core/constants/game_constants.dart';
import 'direction.dart';
import 'position.dart';

class Snake {
  Snake(List<Position> segments)
      : segments = List<Position>.from(segments);

  final List<Position> segments;

  Position get head => segments.first;
  int get length => segments.length;

  bool occupies(Position p) => segments.any((s) => s == p);

  factory Snake.initial() {
    const cx = GameConstants.gridColumns ~/ 2;
    const cy = GameConstants.gridRows ~/ 2;
    return Snake([
      Position(cx, cy),
      Position(cx - 1, cy),
      Position(cx - 2, cy),
    ]);
  }

  Snake moved(Direction direction, {required bool grow}) {
    final (dx, dy) = direction.delta;
    final updated = <Position>[
      Position(head.x + dx, head.y + dy),
      ...segments,
    ];
    if (!grow && updated.length > 1) updated.removeLast();
    return Snake(updated);
  }
}
