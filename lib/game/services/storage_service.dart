import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/game_settings.dart';

abstract final class StorageService {
  static const String keyHighScore = 'high_score';
  static const String keyMuted = 'muted';
  static const String keySettings = 'game_settings_v2';
  static const String keyOnboardingComplete = 'onboarding_complete';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<int> loadHighScore() async {
    await _ensureInit();
    return _prefs!.getInt(keyHighScore) ?? 0;
  }

  static Future<void> saveHighScore(int score) async {
    await _ensureInit();
    final current = _prefs!.getInt(keyHighScore) ?? 0;
    if (score > current) await _prefs!.setInt(keyHighScore, score);
  }

  @Deprecated('Use GameSettings.soundEnabled')
  static Future<bool> loadMuted() async {
    final s = await loadSettings();
    return !s.soundEnabled;
  }

  @Deprecated('Use saveSettings')
  static Future<void> saveMuted(bool muted) async {
    final s = await loadSettings();
    await saveSettings(s.copyWith(soundEnabled: !muted));
  }

  static Future<GameSettings> loadSettings() async {
    await _ensureInit();
    final raw = _prefs!.getString(keySettings);
    if (raw == null) {
      final legacyMuted = _prefs!.getBool(keyMuted) ?? false;
      return GameSettings.defaults().copyWith(soundEnabled: !legacyMuted);
    }
    try {
      return GameSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      return GameSettings.defaults();
    }
  }

  static Future<void> saveSettings(GameSettings settings) async {
    await _ensureInit();
    await _prefs!.setString(keySettings, jsonEncode(settings.toJson()));
    await _prefs!.setBool(keyMuted, !settings.soundEnabled);
  }

  static Future<bool> loadOnboardingComplete() async {
    await _ensureInit();
    return _prefs!.getBool(keyOnboardingComplete) ?? false;
  }

  static Future<void> saveOnboardingComplete(bool value) async {
    await _ensureInit();
    await _prefs!.setBool(keyOnboardingComplete, value);
  }

  static Future<void> _ensureInit() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
