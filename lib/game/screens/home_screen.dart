import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/services/analytics_service.dart';
import '../../features/about/about_screen.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/challenges/daily_challenge_screen.dart';
import '../../features/leaderboard/leaderboard_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/social/friends_screen.dart';
import '../../features/statistics/statistics_screen.dart';
import '../../shared/widgets/retro_screen_shell.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_status_bar.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _highScore = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    ThemeManager.instance.addListener(_onThemeChanged);
    AnalyticsService.logScreen('home');
  }

  @override
  void dispose() {
    ThemeManager.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    _highScore = await StorageService.loadHighScore();
    if (mounted) setState(() => _loading = false);
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  Future<void> _play() async {
    if (ThemeManager.instance.soundEnabled) await AudioService.playClick();
    if (!mounted) return;
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => GameScreen(initialHighScore: _highScore),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
    _highScore = await StorageService.loadHighScore();
    if (mounted) setState(() {});
    await AudioService.stopMusic();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final settings = ThemeManager.instance.settings;

    return Scaffold(
      backgroundColor: theme.scaffold,
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: theme.uiPrimary))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.person_outline, color: theme.uiPrimary),
                          onPressed: () => _open(const ProfileScreen()),
                        ),
                        IconButton(
                          icon: Icon(Icons.leaderboard_outlined, color: theme.uiPrimary),
                          onPressed: () => _open(const LeaderboardScreen()),
                        ),
                        IconButton(
                          icon: Icon(Icons.settings, color: theme.uiPrimary),
                          onPressed: () => _open(const SettingsScreen()),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SNAKE',
                            style: TextStyle(
                              color: theme.uiPrimary,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'REWIND',
                            style: TextStyle(
                              color: theme.uiAccent,
                              fontSize: 14,
                              letterSpacing: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'BEST ${_highScore.toString().padLeft(4, '0')}',
                            style: TextStyle(
                              color: theme.uiAccent,
                              fontSize: 18,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${settings.difficulty.label} · ${theme.name}',
                            style: TextStyle(
                              color: theme.uiPrimary.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          RetroButton(
                            theme: theme,
                            label: 'PLAY',
                            flex: 2,
                            onPressed: _play,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Column(
                        children: [
                          RetroMenuTile(
                            theme: theme,
                            icon: Icons.emoji_events_outlined,
                            label: 'ACHIEVEMENTS',
                            onTap: () => _open(const AchievementsScreen()),
                          ),
                          RetroMenuTile(
                            theme: theme,
                            icon: Icons.bar_chart,
                            label: 'STATISTICS',
                            onTap: () => _open(const StatisticsScreen()),
                          ),
                          RetroMenuTile(
                            theme: theme,
                            icon: Icons.today,
                            label: 'DAILY CHALLENGE',
                            onTap: () => _open(const DailyChallengeScreen()),
                          ),
                          RetroMenuTile(
                            theme: theme,
                            icon: Icons.people_outline,
                            label: 'FRIENDS',
                            onTap: () => _open(const FriendsScreen()),
                          ),
                          RetroMenuTile(
                            theme: theme,
                            icon: Icons.info_outline,
                            label: 'ABOUT',
                            onTap: () => _open(const AboutScreen()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
