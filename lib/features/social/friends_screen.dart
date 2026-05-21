import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../shared/widgets/retro_screen_shell.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _uidField = TextEditingController();
  String? _message;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('friends');
  }

  @override
  void dispose() {
    _uidField.dispose();
    super.dispose();
  }

  Future<void> _addFriend() async {
    final myUid = AuthController.instance.uid;
    final friendUid = _uidField.text.trim();
    if (myUid == null || friendUid.isEmpty) return;
    if (friendUid == myUid) {
      setState(() => _message = 'Cannot add yourself');
      return;
    }
    await UserRepository().addFriend(myUid, friendUid);
    setState(() => _message = 'Friend added — compare on leaderboard');
    _uidField.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final friends = AuthController.instance.profile?.friendIds ?? [];

    return RetroScreenShell(
      title: 'FRIENDS',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'SOCIAL HUB',
              style: TextStyle(color: theme.uiAccent, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              'Add players by Firebase UID. Friends appear on the Friends leaderboard tab.',
              style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.6), fontSize: 11),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _uidField,
              style: TextStyle(color: theme.uiPrimary, fontFamily: 'monospace', fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Friend UID',
                hintStyle: TextStyle(color: theme.scoreLabel),
                border: OutlineInputBorder(borderSide: BorderSide(color: theme.boardBorder)),
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: theme.uiSecondary,
              child: InkWell(
                onTap: _addFriend,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border.all(color: theme.boardBorder, width: 2)),
                  child: Text('ADD FRIEND', style: TextStyle(color: theme.uiPrimary, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!, style: TextStyle(color: theme.uiAccent, fontSize: 12)),
            ],
            const SizedBox(height: 24),
            Text('YOUR FRIENDS (${friends.length})',
                style: TextStyle(color: theme.scoreLabel, fontSize: 10, letterSpacing: 2)),
            const SizedBox(height: 8),
            Expanded(
              child: friends.isEmpty
                  ? Center(child: Text('No friends yet', style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.5))))
                  : ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (_, i) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.boardBorder),
                          color: theme.scoreBackground.withValues(alpha: 0.2),
                        ),
                        child: Text(
                          friends[i],
                          style: TextStyle(color: theme.uiPrimary, fontFamily: 'monospace', fontSize: 11),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
