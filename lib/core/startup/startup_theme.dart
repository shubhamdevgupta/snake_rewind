import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Always-available dark retro theme for the first frame — never white.
abstract final class StartupTheme {
  static const Color scaffold = Color(0xFF0F380F);
  static const Color primary = Color(0xFF9BBC0F);
  static const Color accent = Color(0xFF8BAC0F);
  static const Color secondary = Color(0xFF306230);
  static const Color border = Color(0xFF306230);
  static const Color textMuted = Color(0x998BAC0F);

  static ThemeData get material => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: scaffold,
        fontFamily: 'monospace',
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: scaffold,
        ),
      );

  static SystemUiOverlayStyle get systemUi => const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      );
}
