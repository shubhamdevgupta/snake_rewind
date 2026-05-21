import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/services/auth_controller.dart';
import '../../data/services/analytics_service.dart';
import '../../shared/widgets/retro_screen_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('profile');
    final p = AuthController.instance.profile;
    _nameController.text = p?.username ?? '';
    AuthController.instance.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AuthController.instance.removeListener(_refresh);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final auth = AuthController.instance;
    final p = auth.profile;

    return RetroScreenShell(
      title: 'PROFILE',
      child: p == null
          ? Center(child: Text('Sign in to sync profile', style: TextStyle(color: theme.uiPrimary)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: theme.uiSecondary,
                    backgroundImage:
                        p.photoUrl != null ? NetworkImage(p.photoUrl!) : null,
                    child: p.photoUrl == null
                        ? Icon(Icons.person, size: 48, color: theme.uiPrimary)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _row(theme, 'RANK', p.rankLabel),
                _row(theme, 'BEST', p.bestScore.toString().padLeft(4, '0')),
                _row(theme, 'GAMES', '${p.totalGames}'),
                _row(theme, 'FOOD', '${p.foodsEaten}'),
                _row(theme, 'THEME', p.favoriteTheme.toUpperCase()),
                _row(theme, 'MODE', p.favoriteDifficulty.toUpperCase()),
                _row(theme, 'PLAY TIME', '${p.totalPlayTimeSeconds ~/ 60} min'),
                _row(theme, 'ACHIEVEMENTS', '${p.achievementsUnlocked}'),
                _row(theme, 'SYNC', p.lastSyncAt != null ? 'Cloud OK' : 'Local'),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: theme.uiPrimary),
                  decoration: InputDecoration(
                    labelText: 'USERNAME',
                    labelStyle: TextStyle(color: theme.scoreLabel),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.boardBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _btn(theme, 'SAVE NAME', () async {
                  await auth.updateUsername(_nameController.text);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Username updated', style: TextStyle(color: theme.scaffold))),
                    );
                  }
                }),
                const SizedBox(height: 8),
                _btn(theme, 'LOGOUT', () async {
                  await auth.signOut();
                  if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
                }),
              ],
            ),
    );
  }

  Widget _row(dynamic theme, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scoreBackground,
        border: Border.all(color: theme.boardBorder, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.scoreLabel, fontSize: 10, letterSpacing: 2)),
          Text(value, style: TextStyle(color: theme.scoreText, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _btn(dynamic theme, String label, VoidCallback onTap) {
    return Material(
      color: theme.uiSecondary,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: theme.boardBorder, width: 2)),
          child: Text(label, style: TextStyle(color: theme.uiPrimary, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
      ),
    );
  }
}
