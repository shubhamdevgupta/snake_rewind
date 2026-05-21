import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/models/leaderboard_entry.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../shared/widgets/retro_screen_shell.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    AnalyticsService.logScreen('leaderboard');
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final myUid = AuthController.instance.uid;

    return RetroScreenShell(
      title: 'LEADERBOARD',
      child: Column(
        children: [
          TabBar(
            controller: _tabs,
            indicatorColor: theme.uiAccent,
            labelColor: theme.uiPrimary,
            unselectedLabelColor: theme.uiPrimary.withValues(alpha: 0.4),
            tabs: const [
              Tab(text: 'GLOBAL'),
              Tab(text: 'WEEKLY'),
              Tab(text: 'THEME'),
              Tab(text: 'FRIENDS'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _BoardList(type: LeaderboardType.global, myUid: myUid),
                _BoardList(type: LeaderboardType.weekly, myUid: myUid),
                _BoardList(
                  type: LeaderboardType.theme,
                  myUid: myUid,
                  themeId: ThemeManager.instance.settings.themeId,
                ),
                _BoardList(type: LeaderboardType.friends, myUid: myUid),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardList extends StatelessWidget {
  const _BoardList({
    required this.type,
    required this.myUid,
    this.themeId,
  });

  final LeaderboardType type;
  final String? myUid;
  final String? themeId;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final repo = LeaderboardRepository();
    final friends = AuthController.instance.profile?.friendIds ?? [];

    return StreamBuilder<List<LeaderboardEntry>>(
      stream: type == LeaderboardType.friends && friends.isEmpty
          ? Stream.value(<LeaderboardEntry>[])
          : repo.watchTop(type: type, themeId: themeId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: theme.uiPrimary));
        }
        final entries = snap.data ?? [];
        if (entries.isEmpty) {
          return Center(
            child: Text(
              type == LeaderboardType.friends
                  ? 'Add friends to compete'
                  : 'No scores yet — be first!',
              style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.6)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            final isMe = e.uid == myUid;
            return _EntryTile(entry: e, isMe: isMe);
          },
        );
      },
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.isMe});

  final LeaderboardEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final rank = entry.rank;
    final glow = rank == 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? theme.uiSecondary : theme.scoreBackground.withValues(alpha: 0.3),
        border: Border.all(
          color: isMe ? theme.uiAccent : theme.boardBorder,
          width: isMe ? 2 : 1,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: theme.uiAccent.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          _rankBadge(theme, rank),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.uiSecondary,
            backgroundImage:
                entry.photoUrl != null ? NetworkImage(entry.photoUrl!) : null,
            child: entry.photoUrl == null
                ? Icon(Icons.person, size: 18, color: theme.uiPrimary)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: TextStyle(
                    color: theme.uiPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  entry.favoriteTheme.toUpperCase(),
                  style: TextStyle(color: theme.scoreLabel, fontSize: 9),
                ),
              ],
            ),
          ),
          Text(
            entry.score.toString().padLeft(4, '0'),
            style: TextStyle(
              color: glow ? theme.uiAccent : theme.scoreText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              shadows: glow
                  ? [Shadow(color: theme.uiAccent.withValues(alpha: 0.6), blurRadius: 6)]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankBadge(dynamic theme, int rank) {
    if (rank == 1) {
      return Icon(Icons.workspace_premium, color: theme.uiAccent, size: 28);
    }
    return SizedBox(
      width: 28,
      child: Text(
        '#$rank',
        style: TextStyle(
          color: theme.uiPrimary,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
