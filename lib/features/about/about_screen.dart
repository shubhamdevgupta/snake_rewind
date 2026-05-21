import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/services/analytics_service.dart';
import '../../shared/widgets/retro_screen_shell.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AnalyticsService.logScreen('about');
    final theme = ThemeManager.instance.theme;

    return RetroScreenShell(
      title: 'ABOUT',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SNAKE REWIND',
              style: TextStyle(
                color: theme.uiPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: theme.scoreLabel, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 24),
            Text(
              'Classic Nokia-inspired snake rebuilt with Flame, cloud leaderboards, achievements, and retro AMOLED themes.',
              style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.75), height: 1.5),
            ),


            const Spacer(),
            Text(
              '© Snake Rewind',
              style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.4), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

}
