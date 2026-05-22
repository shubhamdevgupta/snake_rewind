import 'package:flutter/material.dart';

import '../../core/theme/game_theme_data.dart';

/// Cached, repaint-isolated avatar for lists and cards.
class RetroAvatar extends StatelessWidget {
  const RetroAvatar({
    super.key,
    this.photoUrl,
    required this.radius,
    required this.theme,
  });

  final String? photoUrl;
  final double radius;
  final GameThemeData theme;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CircleAvatar(
        radius: radius,
        backgroundColor: theme.uiSecondary,
        backgroundImage:
            photoUrl != null ? NetworkImage(photoUrl!) : null,
        child: photoUrl == null
            ? Icon(Icons.person, size: radius, color: theme.textOnSurface)
            : null,
      ),
    );
  }
}
