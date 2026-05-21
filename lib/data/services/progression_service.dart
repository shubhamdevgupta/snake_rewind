import 'dart:async';

import '../../core/constants/difficulty.dart';
import '../../core/theme/theme_manager.dart';
import '../../game/controllers/game_controller.dart';
import '../achievements/achievement_engine.dart';
import '../models/leaderboard_entry.dart';
import '../repositories/leaderboard_repository.dart';
import '../repositories/user_repository.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';
import 'auth_controller.dart';

/// Post-game cloud sync — runs async, never blocks the game loop.
class ProgressionService {
  ProgressionService._();
  static final ProgressionService instance = ProgressionService._();

  final UserRepository _users = UserRepository();
  final LeaderboardRepository _leaderboard = LeaderboardRepository();
  final AchievementEngine _achievements = AchievementEngine();

  DateTime? _sessionStart;

  void trackGameStart() {
    _sessionStart = DateTime.now();
    final settings = ThemeManager.instance.settings;
    unawaited(
      AnalyticsService.logGameStart(
        difficulty: settings.difficulty.label,
        themeId: settings.themeId,
      ),
    );
  }

  Future<void> onGameEnd(GameOverInfo info, {required int foodsEaten}) async {
    final uid = AuthController.instance.uid;
    if (uid == null) return;

    try {
      final settings = ThemeManager.instance.settings;
      final themeId = settings.themeId;
      final difficulty = settings.difficulty;

      await AnalyticsService.logGameOver(
        score: info.score,
        snakeLength: info.snakeLength,
        difficulty: difficulty.label,
      );
      if (info.score >= 50) {
        await AnalyticsService.logScoreReached(info.score);
      }

      final playSeconds = _sessionStart != null
          ? DateTime.now().difference(_sessionStart!).inSeconds
          : 0;

      var stats = await _users.fetchStats(uid);
      final newGames = stats.totalGames + 1;
      final newFoods = stats.totalFoodsEaten + foodsEaten;
      final newHigh = info.score > stats.highestScore ? info.score : stats.highestScore;
      final newLongest = info.snakeLength > stats.longestSnake
          ? info.snakeLength
          : stats.longestSnake;
      final totalScore = stats.averageScore * stats.totalGames + info.score;
      final newAvg = newGames > 0 ? totalScore ~/ newGames : info.score;

      stats = stats.copyWith(
        totalGames: newGames,
        totalFoodsEaten: newFoods,
        highestScore: newHigh,
        averageScore: newAvg,
        longestSnake: newLongest,
        favoriteTheme: themeId,
        favoriteDifficulty: difficulty.name,
        totalPlayTimeSeconds: stats.totalPlayTimeSeconds + playSeconds,
        totalDeaths: stats.totalDeaths + 1,
        hardModeGames: difficulty == Difficulty.hard
            ? stats.hardModeGames + 1
            : stats.hardModeGames,
        amoledThemeWins: themeId == 'amoled' && info.score >= 100
            ? stats.amoledThemeWins + 1
            : stats.amoledThemeWins,
        themesUnlocked: stats.themesUnlocked < 5 ? 5 : stats.themesUnlocked,
        currentStreak: stats.currentStreak + 1,
        bestStreak: stats.bestStreak < stats.currentStreak + 1
            ? stats.currentStreak + 1
            : stats.bestStreak,
      );

      await _users.saveStats(uid, stats);

      final profile = AuthController.instance.profile;
      if (profile != null) {
        final updated = profile.copyWith(
          bestScore: newHigh > profile.bestScore ? newHigh : profile.bestScore,
          totalGames: newGames,
          foodsEaten: newFoods,
          favoriteTheme: themeId,
          favoriteDifficulty: difficulty.name,
        );
        await _users.createOrUpdateProfile(updated);
        AuthController.instance.updateProfileLocal(updated);
      }

      if (info.score > 0) {
        final entry = LeaderboardEntry(
          uid: uid,
          username: profile?.username ?? 'Player',
          score: info.score,
          photoUrl: profile?.photoUrl,
          favoriteTheme: themeId,
          country: profile?.country,
        );
        if (info.score >= (profile?.bestScore ?? 0)) {
          await _leaderboard.submitScore(
            uid: uid,
            entry: entry,
            themeId: themeId,
          );
        }
      }

      final unlocked = await _achievements.evaluate(
        uid: uid,
        stats: stats,
        sessionScore: info.score,
        themeId: themeId,
        foodsThisGame: foodsEaten,
      );
      final unlockCount = unlocked.where((a) => a.unlocked).length;
      if (profile != null) {
        AuthController.instance.updateProfileLocal(
          profile.copyWith(achievementsUnlocked: unlockCount),
        );
      }
    } on Object catch (e, st) {
      await CrashlyticsService.recordError(e, st, reason: 'progression_sync');
    }
  }
}
