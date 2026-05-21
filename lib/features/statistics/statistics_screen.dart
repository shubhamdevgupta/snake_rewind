import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/models/user_stats.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../shared/widgets/retro_screen_shell.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  UserStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('statistics');
    _load();
  }

  Future<void> _load() async {
    final uid = AuthController.instance.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final stats = await UserRepository().fetchStats(uid);
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final s = _stats ?? const UserStats();

    return RetroScreenShell(
      title: 'STATISTICS',
      child: _loading
          ? Center(child: CircularProgressIndicator(color: theme.uiPrimary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _chart(theme, s),
                const SizedBox(height: 16),
                _stat(theme, 'GAMES PLAYED', '${s.totalGames}'),
                _stat(theme, 'FOODS EATEN', '${s.totalFoodsEaten}'),
                _stat(theme, 'HIGHEST SCORE', s.highestScore.toString().padLeft(4, '0')),
                _stat(theme, 'AVERAGE SCORE', s.averageScore.toString().padLeft(4, '0')),
                _stat(theme, 'LONGEST SNAKE', '${s.longestSnake}'),
                _stat(theme, 'FAVORITE THEME', s.favoriteTheme.toUpperCase()),
                _stat(theme, 'FAVORITE MODE', s.favoriteDifficulty.toUpperCase()),
                _stat(theme, 'PLAY TIME', '${s.totalPlayTimeSeconds ~/ 60} min'),
                _stat(theme, 'DEATHS', '${s.totalDeaths}'),
                _stat(theme, 'HARD MODE RUNS', '${s.hardModeGames}'),
                _stat(theme, 'CURRENT STREAK', '${s.currentStreak}'),
                _stat(theme, 'BEST STREAK', '${s.bestStreak}'),
              ],
            ),
    );
  }

  Widget _chart(dynamic theme, UserStats s) {
    final values = [
      s.totalGames.toDouble(),
      s.totalFoodsEaten.toDouble(),
      s.highestScore.toDouble(),
    ];
    final max = values.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);

    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.boardBorder, width: 2),
        color: theme.uiSecondary.withValues(alpha: 0.3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bar(theme, values[0] / max, 'GAMES'),
          _bar(theme, values[1] / max, 'FOOD'),
          _bar(theme, values[2] / max, 'BEST'),
        ],
      ),
    );
  }

  Widget _bar(dynamic theme, double h, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 36,
          height: 70 * h,
          color: theme.uiAccent.withValues(alpha: 0.85),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: theme.scoreLabel, fontSize: 8)),
      ],
    );
  }

  Widget _stat(dynamic theme, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scoreBackground.withValues(alpha: 0.35),
        border: Border.all(color: theme.boardBorder, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.scoreLabel, fontSize: 10, letterSpacing: 2)),
          Text(value, style: TextStyle(color: theme.uiAccent, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 16)),
        ],
      ),
    );
  }
}
