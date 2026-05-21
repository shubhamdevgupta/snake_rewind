import 'dart:ui';

/// Visual palette for board, snake, food, and chrome UI.
class GameThemeData {
  const GameThemeData({
    required this.id,
    required this.name,
    required this.scaffold,
    required this.board,
    required this.boardBorder,
    required this.gridLine,
    required this.snakeHead,
    required this.snakeHeadGlow,
    required this.snakeBody,
    required this.snakeBodyAlt,
    required this.snakeTail,
    required this.food,
    required this.foodGlow,
    required this.uiPrimary,
    required this.uiSecondary,
    required this.uiAccent,
    required this.scoreBackground,
    required this.scoreText,
    required this.scoreLabel,
    required this.eyeColor,
    this.bodySegmentGap = 0.12,
    this.headScale = 0.88,
    this.tailScale = 0.55,
  });

  final String id;
  final String name;
  final Color scaffold;
  final Color board;
  final Color boardBorder;
  final Color gridLine;
  final Color snakeHead;
  final Color snakeHeadGlow;
  final Color snakeBody;
  final Color snakeBodyAlt;
  final Color snakeTail;
  final Color food;
  final Color foodGlow;
  final Color uiPrimary;
  final Color uiSecondary;
  final Color uiAccent;
  final Color scoreBackground;
  final Color scoreText;
  final Color scoreLabel;
  final Color eyeColor;
  final double bodySegmentGap;
  final double headScale;
  final double tailScale;
}
