import 'package:flutter/material.dart';

import '../../core/theme/game_theme_data.dart';

class RetroButton extends StatelessWidget {
  const RetroButton({
    super.key,
    required this.theme,
    required this.label,
    required this.onPressed,
    this.icon,
    this.flex = 1,
  });

  final GameThemeData theme;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: theme.uiSecondary,
          child: InkWell(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: theme.boardBorder, width: 2),
                boxShadow: onPressed != null
                    ? [
                        BoxShadow(
                          color: theme.scaffold.withValues(alpha: 0.35),
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: icon != null
                  ? Icon(icon, color: theme.uiPrimary, size: 28)
                  : Text(
                      label,
                      style: TextStyle(
                        color: theme.uiPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
