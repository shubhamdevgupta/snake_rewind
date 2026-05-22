import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';

/// Shown while Firestore profile is fetched — prevents premature route swaps.
class SessionLoadingScreen extends StatelessWidget {
  const SessionLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    return Scaffold(
      backgroundColor: theme.scaffold,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.uiAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SYNCING PROFILE',
              style: TextStyle(
                color: theme.textMuted,
                fontSize: 11,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
