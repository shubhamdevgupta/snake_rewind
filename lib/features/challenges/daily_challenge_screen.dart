import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/services/analytics_service.dart';
import '../../shared/widgets/retro_screen_shell.dart';

/// Daily challenge infrastructure — targets rotate by calendar day.
class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  static int get _dailyTarget {
    final day = DateTime.now().day;
    return 100 + (day * 7) % 400;
  }

  static String get _dailyTheme {
    const themes = ['classic', 'neon', 'amoled', 'pixel', 'dark_retro'];
    return themes[DateTime.now().day % themes.length];
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService.logScreen('daily_challenge');
    final theme = ThemeManager.instance.theme;
    final target = _dailyTarget;

    return RetroScreenShell(
      title: 'DAILY',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.scoreBackground.withValues(alpha: 0.35),
                border: Border.all(color: theme.uiAccent, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: theme.uiAccent.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'TODAY\'S CHALLENGE',
                    style: TextStyle(
                      color: theme.uiAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Score $target',
                    style: TextStyle(
                      color: theme.scoreText,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Theme: ${_dailyTheme.toUpperCase()}',
                    style: TextStyle(color: theme.scoreLabel, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Streak rewards and cloud sync coming in a future update.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.uiPrimary.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              'DAY ${DateTime.now().day} · ${DateTime.now().year}',
              style: TextStyle(
                color: theme.uiPrimary.withValues(alpha: 0.4),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
