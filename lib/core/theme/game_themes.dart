import 'dart:ui';

import 'game_theme_data.dart';

abstract final class GameThemes {
  static const String classicId = 'classic';
  static const String darkRetroId = 'dark_retro';
  static const String neonId = 'neon';
  static const String amoledId = 'amoled';
  static const String pixelId = 'pixel';

  static const GameThemeData classic = GameThemeData(
    id: classicId,
    name: 'Nokia Green',
    scaffold: Color(0xFF0F380F),
    board: Color(0xFF9BBC0F),
    boardBorder: Color(0xFF306230),
    gridLine: Color(0x668BAC0F),
    snakeHead: Color(0xFF1A5C1A),
    snakeHeadGlow: Color(0xFF3D8B3D),
    snakeBody: Color(0xFF306230),
    snakeBodyAlt: Color(0xFF2A542A),
    snakeTail: Color(0xFF1E421E),
    food: Color(0xFF0F380F),
    foodGlow: Color(0xFF1A4A1A),
    uiPrimary: Color(0xFF9BBC0F),
    uiSecondary: Color(0xFF306230),
    uiAccent: Color(0xFF8BAC0F),
    scoreBackground: Color(0xFF9BBC0F),
    scoreText: Color(0xFF0F380F),
    scoreLabel: Color(0xFF306230),
    eyeColor: Color(0xFF9BBC0F),
  );

  static const GameThemeData darkRetro = GameThemeData(
    id: darkRetroId,
    name: 'Dark Retro',
    scaffold: Color(0xFF1A1A2E),
    board: Color(0xFF2D2D44),
    boardBorder: Color(0xFF4A4A6A),
    gridLine: Color(0x334A4A6A),
    snakeHead: Color(0xFFE94560),
    snakeHeadGlow: Color(0xFFFF6B6B),
    snakeBody: Color(0xFF533483),
    snakeBodyAlt: Color(0xFF4A2D6E),
    snakeTail: Color(0xFF3D2560),
    food: Color(0xFFFFD93D),
    foodGlow: Color(0xFFFFE66D),
    uiPrimary: Color(0xFFE94560),
    uiSecondary: Color(0xFF533483),
    uiAccent: Color(0xFFFFD93D),
    scoreBackground: Color(0xFF2D2D44),
    scoreText: Color(0xFFE94560),
    scoreLabel: Color(0xFF8888AA),
    eyeColor: Color(0xFFFFFFFF),
    headScale: 0.9,
  );

  static const GameThemeData neon = GameThemeData(
    id: neonId,
    name: 'Neon Arcade',
    scaffold: Color(0xFF0D0221),
    board: Color(0xFF1A0A2E),
    boardBorder: Color(0xFF00FFF5),
    gridLine: Color(0x3300FFF5),
    snakeHead: Color(0xFF00FFF5),
    snakeHeadGlow: Color(0xFF7FFFFF),
    snakeBody: Color(0xFFFF00FF),
    snakeBodyAlt: Color(0xFFCC00CC),
    snakeTail: Color(0xFF880088),
    food: Color(0xFFFFFF00),
    foodGlow: Color(0xFFFFEE00),
    uiPrimary: Color(0xFF00FFF5),
    uiSecondary: Color(0xFF2A1440),
    uiAccent: Color(0xFFFFFF00),
    scoreBackground: Color(0xFF1A0A2E),
    scoreText: Color(0xFF00FFF5),
    scoreLabel: Color(0xFF8ECFD4),
    eyeColor: Color(0xFF0D0221),
    onBackground: Color(0xFFE8FAFF),
    onSurface: Color(0xFFFFFFFF),
    onAccent: Color(0xFF0D0221),
    mutedText: Color(0xFF9BB8C4),
    highContrastText: Color(0xFFFFFFFF),
    bodySegmentGap: 0.1,
    headScale: 0.86,
  );

  static const GameThemeData amoled = GameThemeData(
    id: amoledId,
    name: 'AMOLED Black',
    scaffold: Color(0xFF000000),
    board: Color(0xFF0A0A0A),
    boardBorder: Color(0xFF333333),
    gridLine: Color(0x22111111),
    snakeHead: Color(0xFFFFFFFF),
    snakeHeadGlow: Color(0xFFCCCCCC),
    snakeBody: Color(0xFF666666),
    snakeBodyAlt: Color(0xFF444444),
    snakeTail: Color(0xFF2A2A2A),
    food: Color(0xFF00FF88),
    foodGlow: Color(0xFF00FF88),
    uiPrimary: Color(0xFFFFFFFF),
    uiSecondary: Color(0xFF1A1A1A),
    uiAccent: Color(0xFF00FF88),
    scoreBackground: Color(0xFF111111),
    scoreText: Color(0xFF00FF88),
    scoreLabel: Color(0xFF888888),
    eyeColor: Color(0xFF000000),
    onBackground: Color(0xFFF2F2F2),
    onSurface: Color(0xFFE0E0E0),
    onAccent: Color(0xFF000000),
    mutedText: Color(0xFF8A8A8A),
    highContrastText: Color(0xFFFFFFFF),
    tailScale: 0.5,
  );

  static const GameThemeData pixel = GameThemeData(
    id: pixelId,
    name: 'Pixel Retro',
    scaffold: Color(0xFF2D1B00),
    board: Color(0xFFE8D5B5),
    boardBorder: Color(0xFF8B4513),
    gridLine: Color(0x558B4513),
    snakeHead: Color(0xFF228B22),
    snakeHeadGlow: Color(0xFF32CD32),
    snakeBody: Color(0xFF006400),
    snakeBodyAlt: Color(0xFF004D00),
    snakeTail: Color(0xFF003300),
    food: Color(0xFFDC143C),
    foodGlow: Color(0xFFFF6347),
    uiPrimary: Color(0xFF8B4513),
    uiSecondary: Color(0xFF228B22),
    uiAccent: Color(0xFFDC143C),
    scoreBackground: Color(0xFFE8D5B5),
    scoreText: Color(0xFF2D1B00),
    scoreLabel: Color(0xFF8B4513),
    eyeColor: Color(0xFFE8D5B5),
    bodySegmentGap: 0.15,
    headScale: 0.92,
    tailScale: 0.5,
  );

  static const List<GameThemeData> all = [
    classic,
    darkRetro,
    neon,
    amoled,
    pixel,
  ];

  static GameThemeData byId(String id) {
    return all.firstWhere(
      (t) => t.id == id,
      orElse: () => classic,
    );
  }
}
