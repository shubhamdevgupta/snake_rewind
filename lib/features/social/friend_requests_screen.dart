import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/controllers/social_controller.dart';
import '../../data/models/friend_request.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../data/utils/username_validator.dart';
import '../../shared/widgets/retro_screen_shell.dart';
import '../../shared/widgets/social_snackbar.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  String? _busyId;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('friend_requests');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final uid = AuthController.instance.uid;
    final social = SocialController.instance;

    return RetroScreenShell(
      title: 'REQUESTS',
      child: uid == null
          ? Center(
              child: Text(
                'Sign in to manage requests',
                style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.6)),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle(theme, 'INCOMING'),
                StreamBuilder<List<FriendRequest>>(
                  stream: social.watchIncoming(uid),
                  builder: (context, snap) {
                    final list = snap.data ?? [];
                    if (list.isEmpty) {
                      return _empty(theme, 'No pending requests.');
                    }
                    return Column(
                      children: list.map((r) => _incomingCard(theme, r)).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _sectionTitle(theme, 'SENT'),
                StreamBuilder<List<FriendRequest>>(
                  stream: social.watchSent(uid),
                  builder: (context, snap) {
                    final list = snap.data ?? [];
                    if (list.isEmpty) {
                      return _empty(theme, 'No sent requests.');
                    }
                    return Column(
                      children: list.map((r) => _sentCard(theme, r)).toList(),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _sectionTitle(dynamic theme, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          color: theme.uiAccent,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _empty(dynamic theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.45), fontSize: 12),
      ),
    );
  }

  Widget _incomingCard(dynamic theme, FriendRequest r) {
    final busy = _busyId == r.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.boardBorder),
        color: theme.scoreBackground.withValues(alpha: 0.2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.uiSecondary,
            backgroundImage: r.fromPhotoUrl != null
                ? NetworkImage(r.fromPhotoUrl!)
                : null,
            child: r.fromPhotoUrl == null
                ? Icon(Icons.person, color: theme.uiPrimary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              UsernameValidator.display(r.fromUsername),
              style: TextStyle(
                color: theme.uiPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _miniBtn(theme, 'REJECT', busy, () => _reject(r)),
          const SizedBox(width: 6),
          _miniBtn(theme, 'ACCEPT', busy, () => _accept(r), accent: true),
        ],
      ),
    );
  }

  Widget _sentCard(dynamic theme, FriendRequest r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.boardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              UsernameValidator.display(r.toUsername ?? 'player'),
              style: TextStyle(color: theme.uiPrimary, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            'PENDING',
            style: TextStyle(color: theme.scoreLabel, fontSize: 10, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _miniBtn(
    dynamic theme,
    String label,
    bool busy,
    VoidCallback onTap, {
    bool accent = false,
  }) {
    return Material(
      color: theme.uiSecondary,
      child: InkWell(
        onTap: busy ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: accent ? theme.uiAccent : theme.boardBorder),
          ),
          child: busy
              ? SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.uiPrimary,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: accent ? theme.uiAccent : theme.uiPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _accept(FriendRequest r) async {
    final me = AuthController.instance.profile;
    if (me == null) return;
    setState(() => _busyId = r.id);
    final ok = await SocialController.instance.acceptRequest(r, me);
    if (!mounted) return;
    setState(() => _busyId = null);
    showRetroSnack(
      context,
      ok ? 'Friend added!' : 'Could not accept request',
    );
    if (ok) {
      AuthController.instance.updateProfileLocal(
        me.copyWith(friendsCount: me.friendsCount + 1),
      );
    }
  }

  Future<void> _reject(FriendRequest r) async {
    final uid = AuthController.instance.uid;
    if (uid == null) return;
    setState(() => _busyId = r.id);
    await SocialController.instance.rejectRequest(r, uid);
    if (!mounted) return;
    setState(() => _busyId = null);
    showRetroSnack(context, 'Request declined');
  }
}
