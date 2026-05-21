import '../models/achievement_model.dart';

abstract final class AchievementCatalog {
  static const List<AchievementDefinition> all = [
    AchievementDefinition(
      id: 'first_food',
      title: 'First Bite',
      description: 'Eat your first food',
      target: 1,
      rarity: AchievementRarity.common,
      iconName: 'restaurant',
    ),
    AchievementDefinition(
      id: 'retro_player',
      title: 'Retro Player',
      description: 'Play 10 games',
      target: 10,
      rarity: AchievementRarity.common,
      iconName: 'sports_esports',
    ),
    AchievementDefinition(
      id: 'snake_master',
      title: 'Snake Master',
      description: 'Reach score 500',
      target: 500,
      rarity: AchievementRarity.rare,
      iconName: 'military_tech',
    ),
    AchievementDefinition(
      id: 'hardcore_survivor',
      title: 'Hardcore Survivor',
      description: 'Play hard mode 25 times',
      target: 25,
      rarity: AchievementRarity.epic,
      iconName: 'whatshot',
    ),
    AchievementDefinition(
      id: 'amoled_king',
      title: 'AMOLED King',
      description: 'Score 200+ on AMOLED theme',
      target: 200,
      rarity: AchievementRarity.rare,
      iconName: 'dark_mode',
    ),
    AchievementDefinition(
      id: 'retro_legend',
      title: 'Retro Legend',
      description: 'Use all 5 themes',
      target: 5,
      rarity: AchievementRarity.legendary,
      iconName: 'auto_awesome',
    ),
    AchievementDefinition(
      id: 'century_club',
      title: 'Century Club',
      description: 'Play 100 games',
      target: 100,
      rarity: AchievementRarity.epic,
      iconName: 'emoji_events',
    ),
  ];

  static AchievementDefinition? byId(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } on Object {
      return null;
    }
  }
}
