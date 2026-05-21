import '../models/direction.dart';

class InputController {
  static const int maxBuffered = 3;

  final List<Direction> _buffer = [];

  void clear() => _buffer.clear();

  Direction? peekQueued() => _buffer.isEmpty ? null : _buffer.first;

  void enqueue(Direction next, Direction currentFacing) {
    final effective = _buffer.isNotEmpty ? _buffer.last : currentFacing;
    if (next == effective.opposite) return;
    if (_buffer.isNotEmpty && _buffer.last == next) return;
    if (_buffer.length >= maxBuffered) _buffer.removeAt(0);
    _buffer.add(next);
  }

  Direction? consume(Direction currentFacing) {
    if (_buffer.isEmpty) return null;
    final next = _buffer.removeAt(0);
    if (next == currentFacing.opposite) return null;
    return next;
  }
}
