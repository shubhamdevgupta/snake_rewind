import 'package:flutter_test/flutter_test.dart';
import 'package:snake_game/game/controllers/input_controller.dart';
import 'package:snake_game/game/models/direction.dart';

void main() {
  test('buffers direction and blocks reverse', () {
    final input = InputController();
    input.enqueue(Direction.up, Direction.right);
    input.enqueue(Direction.down, Direction.right);
    expect(input.consume(Direction.right), Direction.up);
    expect(input.consume(Direction.up), isNull);
  });

  test('ignores duplicate enqueue', () {
    final input = InputController();
    input.enqueue(Direction.up, Direction.right);
    input.enqueue(Direction.up, Direction.right);
    expect(input.consume(Direction.right), Direction.up);
  });
}
