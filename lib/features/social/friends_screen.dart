import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/controllers/social_controller.dart';
import '../../data/models/friend_profile.dart';
import '../../data/models/friend_request.dart';
import '../../data/models/public_user.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../data/utils/username_validator.dart';
import '../../shared/widgets/retro_screen_shell.dart';
import '../../shared/widgets/social_snackbar.dart';
import '../../shared/widgets/user_search_card.dart';
import 'friend_requests_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _search = TextEditingController();
  String? _busyUid;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('friends');
    SocialController.instance.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SocialController.instance.removeListener(_rebuild);
    _search.dispose();
    super.dispose();
  }

  Future<void> _onCardAction(PublicUser user) async {
    final auth = AuthController.instance;
    final me = auth.profile;
    final uid = auth.uid;
    if (me == null || uid == null) return;

    setState(() => _busyUid = user.uid);
    try {
      if (user.relation == SocialRelation.pendingReceived &&
          user.pendingRequestId != null) {
        final req = FriendRequest(
          id: user.pendingRequestId!,
          fromUid: user.uid,
          fromUsername: user.username,
          toUid: uid,
          fromPhotoUrl: user.photoUrl,
        );
        final ok = await SocialController.instance.acceptRequest(req, me);
        if (!mounted) return;
        showRetroSnack(
          context,
          ok ? 'Friend added!' : 'Could not accept',
        );
        if (ok) {
          auth.updateProfileLocal(
            me.copyWith(friendsCount: me.friendsCount + 1),
          );
        }
      } else if (user.relation == SocialRelation.none) {
        final id = await SocialController.instance.sendFriendRequest(me, user);
        if (!mounted) return;
        showRetroSnack(
          context,
          id != null ? 'Request sent' : 'Could not send request',
        );
      }
      await SocialController.instance.searchUsers(
        _search.text,
        myUid: uid,
      );
    } finally {
      if (mounted) setState(() => _busyUid = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final uid = AuthController.instance.uid;
    final social = SocialController.instance;

    return RetroScreenShell(
      title: 'SEARCH FRIENDS',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    style: TextStyle(color: theme.uiPrimary, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'Search @username',
                      hintStyle: TextStyle(color: theme.scoreLabel),
                      prefixIcon: Icon(Icons.search, color: theme.uiAccent, size: 20),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.boardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.boardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.uiAccent, width: 2),
                      ),
                    ),
                    onChanged: (v) {
                      social.debouncedSearch(v, myUid: uid);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.mail_outline, color: theme.uiAccent),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FriendRequestsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (social.isSearching)
            Padding(
              padding: const EdgeInsets.all(8),
              child: LinearProgressIndicator(
                color: theme.uiAccent,
                backgroundColor: theme.boardBorder,
                minHeight: 2,
              ),
            ),
          Expanded(
            child: _search.text.trim().length < 2
                ? _friendsList(theme, uid)
                : _searchResults(theme, social),
          ),
        ],
      ),
    );
  }

  Widget _searchResults(dynamic theme, SocialController social) {
    if (social.searchResults.isEmpty) {
      return Center(
        child: Text(
          'No players found.',
          style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.5)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: social.searchResults.length,
      itemBuilder: (_, i) {
        final u = social.searchResults[i];
        return UserSearchCard(
          user: u,
          theme: theme,
          busy: _busyUid == u.uid,
          onAction: () => _onCardAction(u),
        );
      },
    );
  }

  Widget _friendsList(dynamic theme, String? uid) {
    if (uid == null) {
      return Center(
        child: Text(
          'Sign in to add friends',
          style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.5)),
        ),
      );
    }
    return StreamBuilder<List<FriendProfile>>(
      stream: SocialController.instance.friendsRepo.watchFriends(uid),
      builder: (context, snap) {
        final friends = snap.data ?? [];
        if (friends.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Add friends to compete together.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.uiPrimary.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: friends.length,
          itemBuilder: (_, i) {
            final f = friends[i];
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
                    radius: 20,
                    backgroundColor: theme.uiSecondary,
                    backgroundImage:
                        f.photoUrl != null ? NetworkImage(f.photoUrl!) : null,
                    child: f.photoUrl == null
                        ? Icon(Icons.person, color: theme.uiPrimary, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UsernameValidator.display(f.username),
                          style: TextStyle(
                            color: theme.uiPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'BEST ${f.bestScore.toString().padLeft(4, '0')}',
                          style: TextStyle(
                            color: theme.scoreLabel,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'FRIENDS',
                    style: TextStyle(color: theme.uiAccent, fontSize: 9),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
