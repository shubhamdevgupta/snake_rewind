import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../data/utils/username_validator.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/social/friends_screen.dart';
import '../../shared/widgets/retro_screen_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('profile');
    AuthController.instance.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AuthController.instance.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final auth = AuthController.instance;
    final p = auth.profile;

    return RetroScreenShell(
      title: 'PROFILE',
      child: p == null
          ? Center(
              child: Text(
                'Sign in to sync profile',
                style: TextStyle(color: theme.uiPrimary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: theme.uiSecondary,
                    backgroundImage:
                        p.photoUrl != null ? NetworkImage(p.photoUrl!) : null,
                    child: p.photoUrl == null
                        ? Icon(Icons.person, size: 48, color: theme.uiPrimary)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    p.hasValidUsername
                        ? UsernameValidator.display(p.username)
                        : 'Set username in setup',
                    style: TextStyle(
                      color: theme.uiAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                if (p.displayName != null && p.displayName != p.username)
                  Center(
                    child: Text(
                      p.displayName!,
                      style: TextStyle(
                        color: theme.uiPrimary.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                _row(theme, 'RANK', p.rankLabel),
                _row(theme, 'BEST', p.bestScore.toString().padLeft(4, '0')),
                _row(theme, 'FRIENDS', '${p.friendsCount}'),
                _row(theme, 'GAMES', '${p.totalGames}'),
                _row(theme, 'FOOD', '${p.foodsEaten}'),
                _row(theme, 'THEME', p.favoriteTheme.toUpperCase()),
                _row(theme, 'MODE', p.favoriteDifficulty.toUpperCase()),
                _row(theme, 'PLAY TIME', '${p.totalPlayTimeSeconds ~/ 60} min'),
                _row(theme, 'ACHIEVEMENTS', '${p.achievementsUnlocked}'),
                _row(theme, 'SYNC', p.lastSyncAt != null ? 'Cloud OK' : 'Local'),
                const SizedBox(height: 16),
                _btn(theme, 'ADD FRIENDS', () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FriendsScreen(),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                _btn(theme, 'ACHIEVEMENTS', () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AchievementsScreen(),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                _btn(theme, 'LOGOUT', () async {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                }),
              ],
            ),
    );
  }

  Widget _row(dynamic theme, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scoreBackground,
        border: Border.all(color: theme.boardBorder, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.scoreLabel,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.scoreText,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(dynamic theme, String label, VoidCallback onTap) {
    return Material(
      color: theme.uiSecondary,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: theme.boardBorder, width: 2),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: theme.uiPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
