import '../../core/constants/game_constants.dart';
import '../models/position.dart';
import '../models/snake.dart';

abstract final class CollisionEngine {
  static bool hitsWall(Position head) =>
      head.x < 0 ||
      head.y < 0 ||
      head.x >= GameConstants.gridColumns ||
      head.y >= GameConstants.gridRows;

  static bool hitsSelf(Snake snake) {
    final head = snake.head;
    for (var i = 1; i < snake.segments.length; i++) {
      if (snake.segments[i] == head) return true;
    }
    return false;
  }
}
