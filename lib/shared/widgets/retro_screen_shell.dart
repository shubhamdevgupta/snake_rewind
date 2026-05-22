import 'package:flutter/material.dart';

import '../../core/theme/game_theme_data.dart';
import '../../core/theme/theme_manager.dart';
import '../../game/widgets/retro_status_bar.dart';

class RetroScreenShell extends StatelessWidget {
  const RetroScreenShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final settings = ThemeManager.instance.settings;

    return Scaffold(
      backgroundColor: theme.scaffold,
      appBar: AppBar(
        backgroundColor: theme.scaffold,
        foregroundColor: theme.textOnBackground,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            color: theme.textHighContrast,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: actions,
      ),
      body: Column(
        children: [
          if (!settings.retroStatusBar) RetroStatusBar(theme: theme),
          Expanded(
            child: RepaintBoundary(child: child),
          ),
        ],
      ),
    );
  }
}

class RetroMenuTile extends StatelessWidget {
  const RetroMenuTile({
    super.key,
    required this.theme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final GameThemeData theme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.uiSecondary,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: theme.boardBorder, width: 2),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.uiAccent, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: theme.textOnSurface,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.textMuted.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
