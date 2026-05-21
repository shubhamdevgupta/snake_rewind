import 'package:flutter_test/flutter_test.dart';
import 'package:snake_game/core/utils/food_spawner.dart';
import 'package:snake_game/game/engine/collision_engine.dart';
import 'package:snake_game/game/models/direction.dart';
import 'package:snake_game/game/models/position.dart';
import 'package:snake_game/game/models/snake.dart';

void main() {
  test('snake moves and tail follows', () {
    final snake = Snake([
      const Position(5, 5),
      const Position(4, 5),
      const Position(3, 5),
    ]);
    final moved = snake.moved(Direction.right, grow: false);
    expect(moved.head, const Position(6, 5));
    expect(moved.length, 3);
  });

  test('snake grows when eating', () {
    final snake = Snake([const Position(5, 5), const Position(4, 5)]);
    final grown = snake.moved(Direction.right, grow: true);
    expect(grown.length, 3);
  });

  test('wall collision', () {
    expect(CollisionEngine.hitsWall(const Position(-1, 0)), isTrue);
    expect(CollisionEngine.hitsWall(const Position(0, 0)), isFalse);
  });

  test('food spawns off snake', () {
    final snake = Snake.initial();
    final food = FoodSpawner.spawn(snake);
    expect(snake.occupies(food.position), isFalse);
  });
}
