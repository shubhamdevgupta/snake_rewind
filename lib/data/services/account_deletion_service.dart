import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/firebase/firebase_bootstrap.dart';
import '../../core/theme/game_themes.dart';
import '../repositories/achievement_repository.dart';
import '../repositories/friend_repository.dart';
import '../repositories/leaderboard_repository.dart';
import '../repositories/username_repository.dart';
import '../repositories/user_repository.dart';

/// Removes all remote user-owned data before Firebase Auth account deletion.
class AccountDeletionService {
  AccountDeletionService({
    FirebaseFirestore? firestore,
    UserRepository? users,
    FriendRepository? friends,
    UsernameRepository? usernames,
    LeaderboardRepository? leaderboard,
    AchievementRepository? achievements,
  })  : _db = firestore,
        _users = users ?? UserRepository(firestore: firestore),
        _friends = friends ?? FriendRepository(firestore: firestore),
        _usernames = usernames ?? UsernameRepository(firestore: firestore),
        _leaderboard = leaderboard ?? LeaderboardRepository(firestore: firestore),
        _achievements = achievements ?? AchievementRepository(firestore: firestore);

  final FirebaseFirestore? _db;
  final UserRepository _users;
  final FriendRepository _friends;
  final UsernameRepository _usernames;
  final LeaderboardRepository _leaderboard;
  final AchievementRepository _achievements;

  FirebaseFirestore? get _firestore {
    if (_db != null) return _db;
    if (!FirebaseBootstrap.initialized || Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  Future<void> deleteAllRemoteData({
    required String uid,
    String? username,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;

    await _friends.purgeUserSocialGraph(uid);
    await _leaderboard.deleteUserEntries(
      uid,
      themeIds: GameThemes.allIds,
    );
    await _achievements.deleteAll(uid);
    await _users.deleteStats(uid);

    if (username != null && username.isNotEmpty) {
      await _usernames.releaseUsername(username, uid: uid);
    }

    await _users.deleteProfileDocument(uid);
  }
}
