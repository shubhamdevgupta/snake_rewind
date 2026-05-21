import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/achievements/achievement_catalog.dart';
import '../../data/models/achievement_model.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../shared/widgets/retro_screen_shell.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, AchievementProgress>? _progress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('achievements');
    _load();
  }

  Future<void> _load() async {
    final uid = AuthController.instance.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final repo = AchievementRepository();
    final data = await repo.fetchProgress(uid, AchievementCatalog.all);
    if (mounted) {
      setState(() {
        _progress = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final items = _progress?.values.toList() ?? [];
    final unlocked = items.where((a) => a.unlocked).length;
    final total = AchievementCatalog.all.length;
    final pct = total > 0 ? unlocked / total : 0.0;

    return RetroScreenShell(
      title: 'ACHIEVEMENTS',
      child: _loading
          ? Center(child: CircularProgressIndicator(color: theme.uiPrimary))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${(pct * 100).round()}% COMPLETE',
                        style: TextStyle(
                          color: theme.uiAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: pct,
                        backgroundColor: theme.uiSecondary,
                        color: theme.uiAccent,
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: AchievementCatalog.all.length,
                    itemBuilder: (context, i) {
                      final def = AchievementCatalog.all[i];
                      final p = _progress?[def.id] ??
                          AchievementProgress(definition: def);
                      return _AchievementCard(progress: p);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.progress});

  final AchievementProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final def = progress.definition;
    final locked = !progress.unlocked;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: locked ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.scoreBackground.withValues(alpha: locked ? 0.2 : 0.5),
          border: Border.all(
            color: progress.unlocked ? theme.uiAccent : theme.boardBorder,
            width: progress.unlocked ? 2 : 1,
          ),
          boxShadow: progress.unlocked
              ? [
                  BoxShadow(
                    color: theme.uiAccent.withValues(alpha: 0.25),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  progress.unlocked ? Icons.emoji_events : Icons.lock_outline,
                  color: progress.unlocked ? theme.uiAccent : theme.uiPrimary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    def.title,
                    style: TextStyle(
                      color: theme.scoreText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  def.rarity.name.toUpperCase(),
                  style: TextStyle(color: theme.scoreLabel, fontSize: 9),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              def.description,
              style: TextStyle(color: theme.scoreLabel, fontSize: 11),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.percent,
              backgroundColor: theme.uiSecondary,
              color: theme.uiAccent,
              minHeight: 4,
            ),
            const SizedBox(height: 4),
            Text(
              '${progress.progress} / ${def.target}',
              style: TextStyle(
                color: theme.uiPrimary.withValues(alpha: 0.6),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
