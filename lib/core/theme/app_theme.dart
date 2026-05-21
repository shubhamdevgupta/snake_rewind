import 'package:flutter/material.dart';

import 'game_theme_data.dart';
import 'theme_manager.dart';

abstract final class AppTheme {
  static ThemeData materialFrom(GameThemeData t) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: t.scaffold,
        fontFamily: 'monospace',
        colorScheme: ColorScheme.dark(
          primary: t.uiPrimary,
          secondary: t.uiSecondary,
          surface: t.scaffold,
        ),
      );

  static ThemeData get current =>
      materialFrom(ThemeManager.instance.theme);
}
