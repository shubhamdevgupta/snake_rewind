enum AchievementRarity { common, rare, epic, legendary }

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.rarity,
    this.iconName = 'star',
  });

  final String id;
  final String title;
  final String description;
  final int target;
  final AchievementRarity rarity;
  final String iconName;
}

class AchievementProgress {
  const AchievementProgress({
    required this.definition,
    this.progress = 0,
    this.unlocked = false,
    this.unlockedAt,
  });

  final AchievementDefinition definition;
  final int progress;
  final bool unlocked;
  final DateTime? unlockedAt;

  double get percent =>
      definition.target > 0 ? (progress / definition.target).clamp(0, 1) : 0;

  AchievementProgress copyWith({
    int? progress,
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementProgress(
      definition: definition,
      progress: progress ?? this.progress,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
