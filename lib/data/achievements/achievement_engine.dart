import '../achievements/achievement_catalog.dart';
import '../models/achievement_model.dart';
import '../models/user_stats.dart';
import '../repositories/achievement_repository.dart';
import '../services/analytics_service.dart';

class AchievementEngine {
  AchievementEngine({AchievementRepository? repository})
      : _repo = repository ?? AchievementRepository();

  final AchievementRepository _repo;

  Future<List<AchievementProgress>> evaluate({
    required String uid,
    required UserStats stats,
    required int sessionScore,
    required String themeId,
    required int foodsThisGame,
    Map<String, AchievementProgress>? cached,
  }) async {
    final current = cached ??
        await _repo.fetchProgress(uid, AchievementCatalog.all);

    final updated = <AchievementProgress>[];

    for (final def in AchievementCatalog.all) {
      var p = current[def.id] ?? AchievementProgress(definition: def);
      if (p.unlocked) {
        updated.add(p);
        continue;
      }

      var progress = p.progress;
      switch (def.id) {
        case 'first_food':
          progress = stats.totalFoodsEaten > 0 ? 1 : progress;
        case 'retro_player':
        case 'century_club':
          progress = stats.totalGames;
        case 'snake_master':
          progress = stats.highestScore;
        case 'hardcore_survivor':
          progress = stats.hardModeGames;
        case 'amoled_king':
          if (themeId == 'amoled') {
            progress = sessionScore > progress ? sessionScore : progress;
          }
        case 'retro_legend':
          progress = stats.themesUnlocked;
      }

      final wasUnlocked = p.unlocked;
      final unlocked = progress >= def.target;
      p = p.copyWith(
        progress: unlocked ? def.target : progress,
        unlocked: unlocked,
        unlockedAt: unlocked ? DateTime.now() : null,
      );

      if (unlocked && !wasUnlocked) {
        await AnalyticsService.logAchievementUnlocked(def.id);
      }

      updated.add(p);
      await _repo.saveProgress(uid, p);
    }

    return updated;
  }
}
