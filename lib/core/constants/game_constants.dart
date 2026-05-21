import 'package:flutter/material.dart';

/// Grid, timing, scoring, and retro palette.
abstract final class GameConstants {
  static const int gridColumns = 20;
  static const int gridRows = 20;
  static const double boardPadding = 8;
  static const double boardBorderWidth = 4;
  static const int defaultTickMs = 200;
  static const int pointsPerFood = 10;

  static const Color colorDark = Color(0xFF0F380F);
  static const Color colorMid = Color(0xFF306230);
  static const Color colorLight = Color(0xFF9BBC0F);
  static const Color colorGridLine = Color(0xFF8BAC0F);
  static const Color colorFood = Color(0xFF0F380F);
  static const Color colorCellEmpty = colorLight;
  static const Color colorSnake = colorMid;
  static const Color colorSnakeHead = Color(0xFF1A4A1A);
}
