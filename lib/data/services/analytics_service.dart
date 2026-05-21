import 'package:firebase_analytics/firebase_analytics.dart';

abstract final class AnalyticsService {
  static FirebaseAnalytics? _analytics;

  static Future<void> init() async {
    _analytics = FirebaseAnalytics.instance;
  }

  static Future<void> logAppOpen() async {
    await _analytics?.logAppOpen();
  }

  static Future<void> logScreen(String name) async {
    await _analytics?.logScreenView(screenName: name);
    await _analytics?.logEvent(name: 'screen_viewed', parameters: {'screen': name});
  }

  static Future<void> logGameStart({
    required String difficulty,
    required String themeId,
  }) async {
    await _analytics?.logEvent(
      name: 'game_start',
      parameters: {'difficulty': difficulty, 'theme': themeId},
    );
  }

  static Future<void> logGameOver({
    required int score,
    required int snakeLength,
    required String difficulty,
  }) async {
    await _analytics?.logEvent(
      name: 'game_over',
      parameters: {
        'score': score,
        'snake_length': snakeLength,
        'difficulty': difficulty,
      },
    );
  }

  static Future<void> logScoreReached(int score) async {
    await _analytics?.logEvent(
      name: 'score_reached',
      parameters: {'score': score},
    );
  }

  static Future<void> logThemeSelected(String themeId) async {
    await _analytics?.logEvent(
      name: 'theme_selected',
      parameters: {'theme': themeId},
    );
  }

  static Future<void> logDifficultySelected(String difficulty) async {
    await _analytics?.logEvent(
      name: 'difficulty_selected',
      parameters: {'difficulty': difficulty},
    );
  }

  static Future<void> logAchievementUnlocked(String id) async {
    await _analytics?.logEvent(
      name: 'achievement_unlocked',
      parameters: {'achievement_id': id},
    );
  }
}
