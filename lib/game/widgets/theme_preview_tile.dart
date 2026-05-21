import 'package:flutter/material.dart';

import '../../core/theme/game_theme_data.dart';

class ThemePreviewTile extends StatelessWidget {
  const ThemePreviewTile({
    super.key,
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final GameThemeData theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.board,
          border: Border.all(
            color: selected ? theme.uiAccent : theme.boardBorder,
            width: selected ? 3 : 2,
          ),
        ),
        child: Row(
          children: [
            _swatch(theme.snakeHead),
            _swatch(theme.snakeBody),
            _swatch(theme.food),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                theme.name,
                style: TextStyle(
                  color: theme.scoreText,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: theme.uiAccent, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _swatch(Color c) => Container(
        width: 22,
        height: 22,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: c,
          border: Border.all(color: theme.boardBorder),
        ),
      );
}
