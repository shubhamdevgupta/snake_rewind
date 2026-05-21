import 'package:flutter/foundation.dart';

import '../models/game_settings.dart';
import '../../data/services/analytics_service.dart';
import '../../game/services/storage_service.dart';
import 'game_theme_data.dart';
import 'game_themes.dart';

/// Central theme + settings hub — notifies listeners on change.
class ThemeManager extends ChangeNotifier {
  ThemeManager._();
  static final ThemeManager instance = ThemeManager._();

  GameSettings _settings = GameSettings.defaults();
  GameThemeData _theme = GameThemes.classic;

  GameSettings get settings => _settings;
  GameThemeData get theme => _theme;

  bool get soundEnabled => _settings.soundEnabled;
  bool get vibrationEnabled => _settings.vibrationEnabled;
  bool get showGrid => _settings.showGrid;
  bool get crtEffect => _settings.crtEffect;
  bool get smoothMovement => _settings.smoothMovement;
  bool get highPerformanceMode => _settings.highPerformanceMode;

  Future<void> load() async {
    _settings = await StorageService.loadSettings();
    _theme = GameThemes.byId(_settings.themeId);
    notifyListeners();
  }

  Future<void> setTheme(String themeId) async {
    _settings = _settings.copyWith(themeId: themeId);
    _theme = GameThemes.byId(themeId);
    await StorageService.saveSettings(_settings);
    await AnalyticsService.logThemeSelected(themeId);
    notifyListeners();
  }

  Future<void> updateSettings(GameSettings settings) async {
    _settings = settings;
    _theme = GameThemes.byId(settings.themeId);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> patchSettings(GameSettings Function(GameSettings) patch) async {
    await updateSettings(patch(_settings));
  }
}
