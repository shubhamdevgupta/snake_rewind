/// Grid cell: x → right, y → down, origin top-left.
class Position {
  const Position(this.x, this.y);

  final int x;
  final int y;

  Position operator +(Position other) => Position(x + other.x, y + other.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}
