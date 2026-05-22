import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/firebase/firebase_bootstrap.dart';
import '../utils/username_validator.dart';
import '../models/user_profile.dart';

class UsernameRepository {
  UsernameRepository({FirebaseFirestore? firestore}) : _db = firestore;

  final FirebaseFirestore? _db;

  FirebaseFirestore? get _firestore {
    if (_db != null) return _db;
    if (!FirebaseBootstrap.initialized || Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? get _users =>
      _firestore?.collection('users');

  CollectionReference<Map<String, dynamic>>? get _usernames =>
      _firestore?.collection('usernames');

  /// Prefix search — indexed range query, max [limit] results.
  Future<bool> isAvailable(String rawUsername, {String? excludeUid}) async {
    final username = UsernameValidator.normalize(rawUsername);
    if (!UsernameValidator.isValidFormat(username)) return false;
    final names = _usernames;
    if (names == null) return false;
    final snap = await names.doc(username).get();
    if (!snap.exists) return true;
    if (excludeUid != null && snap.data()?['uid'] == excludeUid) return true;
    return false;
  }

  Future<List<PublicUserSearchHit>> searchByPrefix(
    String rawPrefix, {
    int limit = 20,
    String? excludeUid,
  }) async {
    final users = _users;
    if (users == null) return [];
    final prefix = UsernameValidator.normalize(rawPrefix);
    if (prefix.length < 2) return [];

    final snap = await users
        .where('usernameLower', isGreaterThanOrEqualTo: prefix)
        .where('usernameLower', isLessThan: UsernameValidator.prefixEnd(prefix))
        .limit(limit)
        .get();

    return snap.docs
        .where((d) => d.id != excludeUid)
        .map((d) => PublicUserSearchHit.fromFirestore(d))
        .toList();
  }

  /// Atomic claim: usernames/{name} + users/{uid}.
  Future<bool> claimUsername({
    required String uid,
    required String rawUsername,
    required UserProfile baseProfile,
  }) async {
    final firestore = _firestore;
    final names = _usernames;
    final users = _users;
    if (firestore == null || names == null || users == null) return false;

    final username = UsernameValidator.normalize(rawUsername);
    if (!UsernameValidator.isValidFormat(username)) return false;

    try {
      return await firestore.runTransaction<bool>((tx) async {
        final nameRef = names.doc(username);
        final userRef = users.doc(uid);
        final existing = await tx.get(nameRef);
        if (existing.exists && existing.data()?['uid'] != uid) {
          return false;
        }
        tx.set(nameRef, {'uid': uid});
        tx.set(
          userRef,
          {
            'uid': uid,
            'username': username,
            'usernameLower': username,
            'displayName': baseProfile.displayName ?? username,
            if (baseProfile.email != null) 'email': baseProfile.email,
            if (baseProfile.photoUrl != null) 'photoUrl': baseProfile.photoUrl,
            'bestScore': baseProfile.bestScore,
            'friendsCount': baseProfile.friendsCount,
            'isGuest': baseProfile.isGuest,
            'createdAt': baseProfile.createdAt != null
                ? Timestamp.fromDate(baseProfile.createdAt!)
                : FieldValue.serverTimestamp(),
            'lastSyncAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return true;
      });
    } on Object {
      return false;
    }
  }
}

/// Lightweight search DTO (no uid in UI layer — use via PublicUser).
class PublicUserSearchHit {
  const PublicUserSearchHit({
    required this.uid,
    required this.username,
    this.photoUrl,
    this.bestScore = 0,
    this.favoriteTheme = 'classic',
  });

  final String uid;
  final String username;
  final String? photoUrl;
  final int bestScore;
  final String favoriteTheme;

  factory PublicUserSearchHit.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return PublicUserSearchHit(
      uid: doc.id,
      username: d['username'] as String? ?? 'player',
      photoUrl: d['photoUrl'] as String?,
      bestScore: (d['bestScore'] as num?)?.toInt() ?? 0,
      favoriteTheme: d['favoriteTheme'] as String? ?? 'classic',
    );
  }
}
