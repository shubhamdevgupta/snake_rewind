import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/models/friend_request.dart';
import '../../data/repositories/friend_repository.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../data/utils/username_validator.dart';
import '../../shared/widgets/retro_avatar.dart';
import '../../shared/widgets/retro_screen_shell.dart';
import '../../shared/widgets/social_snackbar.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final _friendRepo = FriendRepository();
  late final Stream<List<FriendRequest>> _incomingStream;
  late final Stream<List<FriendRequest>> _sentStream;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('friend_requests');
    final uid = AuthController.instance.uid ?? '';
    _incomingStream = _friendRepo.watchIncoming(uid);
    _sentStream = _friendRepo.watchSent(uid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final uid = AuthController.instance.uid;

    return RetroScreenShell(
      title: 'REQUESTS',
      child: uid == null
          ? Center(
              child: Text(
                'Sign in to manage requests',
                style: TextStyle(color: theme.textMuted),
              ),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(child: _sectionTitle(theme, 'INCOMING')),
                ),
                StreamBuilder<List<FriendRequest>>(
                  stream: _incomingStream,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting &&
                        !snap.hasData) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    final list = snap.data ?? [];
                    if (list.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _empty(theme, 'No pending requests.'),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => RepaintBoundary(
                          child: _incomingCard(theme, list[i]),
                        ),
                        childCount: list.length,
                      ),
                    );
                  },
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  sliver: SliverToBoxAdapter(child: _sectionTitle(theme, 'SENT')),
                ),
                StreamBuilder<List<FriendRequest>>(
                  stream: _sentStream,
                  builder: (context, snap) {
                    final list = snap.data ?? [];
                    if (list.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _empty(theme, 'No sent requests.'),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => RepaintBoundary(
                          child: _sentCard(theme, list[i]),
                        ),
                        childCount: list.length,
                      ),
                    );
                  },
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
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
      child: Text(text, style: TextStyle(color: theme.textMuted, fontSize: 12)),
    );
  }

  Widget _incomingCard(dynamic theme, FriendRequest r) {
    final busy = _busyId == r.id;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.boardBorder),
        color: theme.scoreBackground.withValues(alpha: 0.2),
      ),
      child: Row(
        children: [
          RetroAvatar(photoUrl: r.fromPhotoUrl, radius: 22, theme: theme),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              UsernameValidator.display(r.fromUsername),
              style: TextStyle(
                color: theme.textOnSurface,
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.boardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              UsernameValidator.display(r.toUsername ?? 'player'),
              style: TextStyle(
                color: theme.textOnSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'PENDING',
            style: TextStyle(
              color: theme.textMuted,
              fontSize: 10,
              letterSpacing: 1,
            ),
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
                    color: theme.textOnSurface,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: accent ? theme.uiAccent : theme.textOnSurface,
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
    final ok = await _friendRepo.acceptRequest(request: r, myProfile: me);
    if (!mounted) return;
    setState(() => _busyId = null);
    showRetroSnack(context, ok ? 'Friend added!' : 'Could not accept request');
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
    await _friendRepo.rejectRequest(r, uid);
    if (!mounted) return;
    setState(() => _busyId = null);
    showRetroSnack(context, 'Request declined');
  }
}
