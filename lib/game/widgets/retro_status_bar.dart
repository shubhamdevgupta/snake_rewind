import 'package:flutter/material.dart';

import '../../core/theme/game_theme_data.dart';

/// Fake Nokia status bar for nostalgia.
class RetroStatusBar extends StatelessWidget {
  const RetroStatusBar({super.key, required this.theme});

  final GameThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: theme.scaffold,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '12:45',
            style: TextStyle(
              color: theme.uiPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar,
                  size: 12, color: theme.uiPrimary),
              const SizedBox(width: 4),
              Icon(Icons.battery_full, size: 12, color: theme.uiPrimary),
            ],
          ),
        ],
      ),
    );
  }
}
