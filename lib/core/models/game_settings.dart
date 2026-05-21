import '../constants/difficulty.dart';

/// User preferences — persisted locally.
class GameSettings {
  const GameSettings({
    required this.themeId,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.showGrid,
    required this.crtEffect,
    required this.retroStatusBar,
    required this.smoothMovement,
    required this.highPerformanceMode,
    required this.difficulty,
  });

  final String themeId;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showGrid;
  final bool crtEffect;
  final bool retroStatusBar;
  final bool smoothMovement;
  final bool highPerformanceMode;
  final Difficulty difficulty;

  factory GameSettings.defaults() => const GameSettings(
        themeId: 'classic',
        soundEnabled: true,
        vibrationEnabled: true,
        showGrid: true,
        crtEffect: false,
        retroStatusBar: true,
        smoothMovement: true,
        highPerformanceMode: true,
        difficulty: Difficulty.medium,
      );

  GameSettings copyWith({
    String? themeId,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showGrid,
    bool? crtEffect,
    bool? retroStatusBar,
    bool? smoothMovement,
    bool? highPerformanceMode,
    Difficulty? difficulty,
  }) {
    return GameSettings(
      themeId: themeId ?? this.themeId,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showGrid: showGrid ?? this.showGrid,
      crtEffect: crtEffect ?? this.crtEffect,
      retroStatusBar: retroStatusBar ?? this.retroStatusBar,
      smoothMovement: smoothMovement ?? this.smoothMovement,
      highPerformanceMode: highPerformanceMode ?? this.highPerformanceMode,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, Object> toJson() => {
        'themeId': themeId,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'showGrid': showGrid,
        'crtEffect': crtEffect,
        'retroStatusBar': retroStatusBar,
        'smoothMovement': smoothMovement,
        'highPerformanceMode': highPerformanceMode,
        'difficulty': difficulty.index,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    final diffIndex = json['difficulty'] as int? ?? Difficulty.medium.index;
    return GameSettings(
      themeId: json['themeId'] as String? ?? 'classic',
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      showGrid: json['showGrid'] as bool? ?? true,
      crtEffect: json['crtEffect'] as bool? ?? false,
      retroStatusBar: json['retroStatusBar'] as bool? ?? true,
      smoothMovement: json['smoothMovement'] as bool? ?? true,
      highPerformanceMode: json['highPerformanceMode'] as bool? ?? true,
      difficulty: Difficulty.values[diffIndex.clamp(0, Difficulty.values.length - 1)],
    );
  }

  static bool showGridFromJson(Object? value) {
    if (value is bool) return value;
    return true;
  }
}
