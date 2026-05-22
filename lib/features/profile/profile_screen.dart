import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../data/utils/username_validator.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/social/friends_screen.dart';
import '../../shared/navigation/retro_navigation.dart';
import '../../shared/widgets/retro_avatar.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;

    return RetroScreenShell(
      title: 'PROFILE',
      child: ListenableBuilder(
        listenable: AuthController.instance,
        builder: (context, _) {
          final p = AuthController.instance.profile;
          if (p == null) {
            return Center(
              child: Text(
                'Sign in to sync profile',
                style: TextStyle(color: theme.textOnBackground),
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    RepaintBoundary(
                      child: Center(
                        child: RetroAvatar(
                          photoUrl: p.photoUrl,
                          radius: 44,
                          theme: theme,
                        ),
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
                    if (p.displayName != null && p.displayName != p.username) ...[
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          p.displayName!,
                          style: TextStyle(color: theme.textMuted, fontSize: 11),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _ProfileRow(theme: theme, label: 'RANK', value: p.rankLabel),
                    _ProfileRow(
                      theme: theme,
                      label: 'BEST',
                      value: p.bestScore.toString().padLeft(4, '0'),
                    ),
                    _ProfileRow(theme: theme, label: 'FRIENDS', value: '${p.friendsCount}'),
                    _ProfileRow(theme: theme, label: 'GAMES', value: '${p.totalGames}'),
                    _ProfileRow(theme: theme, label: 'FOOD', value: '${p.foodsEaten}'),
                    _ProfileRow(
                      theme: theme,
                      label: 'THEME',
                      value: p.favoriteTheme.toUpperCase(),
                    ),
                    _ProfileRow(
                      theme: theme,
                      label: 'MODE',
                      value: p.favoriteDifficulty.toUpperCase(),
                    ),
                    _ProfileRow(
                      theme: theme,
                      label: 'PLAY TIME',
                      value: '${p.totalPlayTimeSeconds ~/ 60} min',
                    ),
                    _ProfileRow(
                      theme: theme,
                      label: 'ACHIEVEMENTS',
                      value: '${p.achievementsUnlocked}',
                    ),
                    _ProfileRow(
                      theme: theme,
                      label: 'SYNC',
                      value: p.lastSyncAt != null ? 'Cloud OK' : 'Local',
                    ),
                    const SizedBox(height: 16),
                    _ProfileButton(
                      theme: theme,
                      label: 'ADD FRIENDS',
                      onTap: () => pushRetroScreen(context, const FriendsScreen()),
                    ),
                    const SizedBox(height: 8),
                    _ProfileButton(
                      theme: theme,
                      label: 'ACHIEVEMENTS',
                      onTap: () =>
                          pushRetroScreen(context, const AchievementsScreen()),
                    ),
                    const SizedBox(height: 8),
                    _ProfileButton(
                      theme: theme,
                      label: 'LOGOUT',
                      onTap: () async {
                        await AuthController.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.theme,
    required this.label,
    required this.value,
  });

  final dynamic theme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
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
                color: theme.textMuted,
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
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({
    required this.theme,
    required this.label,
    required this.onTap,
  });

  final dynamic theme;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              color: theme.textOnSurface,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
