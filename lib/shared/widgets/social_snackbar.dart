import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';

void showRetroSnack(BuildContext context, String message) {
  final theme = ThemeManager.instance.theme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: theme.uiSecondary,
      content: Text(
        message,
        style: TextStyle(
          color: theme.uiAccent,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    ),
  );
}
