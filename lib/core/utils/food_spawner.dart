import 'dart:math';

import '../constants/game_constants.dart';
import '../../game/models/food.dart';
import '../../game/models/position.dart';
import '../../game/models/snake.dart';

abstract final class FoodSpawner {
  static final Random _random = Random();

  static Food spawn(Snake snake) {
    final free = <Position>[];
    for (var y = 0; y < GameConstants.gridRows; y++) {
      for (var x = 0; x < GameConstants.gridColumns; x++) {
        final cell = Position(x, y);
        if (!snake.occupies(cell)) free.add(cell);
      }
    }
    if (free.isEmpty) throw StateError('Grid full');
    return Food(free[_random.nextInt(free.length)]);
  }
}
