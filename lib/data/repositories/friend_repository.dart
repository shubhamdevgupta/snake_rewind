import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/firebase/firebase_bootstrap.dart';
import '../models/friend_profile.dart';
import '../models/friend_request.dart';
import '../models/leaderboard_entry.dart';
import '../models/public_user.dart';
import '../models/user_profile.dart';

class FriendRepository {
  FriendRepository({FirebaseFirestore? firestore}) : _db = firestore;

  final FirebaseFirestore? _db;

  FirebaseFirestore? get _firestore {
    if (_db != null) return _db;
    if (!FirebaseBootstrap.initialized || Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? get _requests =>
      _firestore?.collection('friend_requests');

  DocumentReference<Map<String, dynamic>>? _user(String uid) =>
      _firestore?.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>>? _friends(String uid) =>
      _user(uid)?.collection('friends');

  static String requestId(String fromUid, String toUid) => '${fromUid}_$toUid';

  Stream<List<FriendProfile>> watchFriends(String uid) {
    final col = _friends(uid);
    if (col == null) return Stream.value([]);
    return col
        .orderBy('bestScore', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(FriendProfile.fromFirestore).toList());
  }

  Stream<List<FriendRequest>> watchIncoming(String uid) {
    final col = _requests;
    if (col == null) return Stream.value([]);
    return col
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((s) => s.docs.map(FriendRequest.fromFirestore).toList());
  }

  Stream<List<FriendRequest>> watchSent(String uid) {
    final col = _requests;
    if (col == null) return Stream.value([]);
    return col
        .where('fromUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((s) => s.docs.map(FriendRequest.fromFirestore).toList());
  }

  Stream<int> watchIncomingCount(String uid) {
    return watchIncoming(uid).map((list) => list.length);
  }

  Future<bool> isFriend(String uid, String otherUid) async {
    final col = _friends(uid);
    if (col == null) return false;
    final snap = await col.doc(otherUid).get();
    return snap.exists;
  }

  Future<Map<String, SocialRelation>> relationsFor(
    String myUid,
    List<String> targetUids,
  ) async {
    final map = <String, SocialRelation>{};
    for (final id in targetUids) {
      if (id == myUid) {
        map[id] = SocialRelation.self;
      } else {
        map[id] = SocialRelation.none;
      }
    }
    if (_firestore == null) return map;

    await Future.wait(targetUids.where((id) => id != myUid).map((id) async {
      if (await isFriend(myUid, id)) {
        map[id] = SocialRelation.friends;
        return;
      }
      final sentId = requestId(myUid, id);
      final recvId = requestId(id, myUid);
      final sent = await _requests!.doc(sentId).get();
      if (sent.exists && sent.data()?['status'] == 'pending') {
        map[id] = SocialRelation.pendingSent;
        return;
      }
      final recv = await _requests!.doc(recvId).get();
      if (recv.exists && recv.data()?['status'] == 'pending') {
        map[id] = SocialRelation.pendingReceived;
      }
    }));
    return map;
  }

  Future<String?> pendingRequestId(String myUid, String otherUid) async {
    final col = _requests;
    if (col == null) return null;
    final sent = await col.doc(requestId(myUid, otherUid)).get();
    if (sent.exists && sent.data()?['status'] == 'pending') return sent.id;
    final recv = await col.doc(requestId(otherUid, myUid)).get();
    if (recv.exists && recv.data()?['status'] == 'pending') return recv.id;
    return null;
  }

  Future<String?> sendRequest({
    required UserProfile from,
    required String toUid,
    required String toUsername,
  }) async {
    final col = _requests;
    if (col == null) return null;
    if (toUid == from.uid) return null;
    if (await isFriend(from.uid, toUid)) return null;

    final id = requestId(from.uid, toUid);
    final existing = await col.doc(id).get();
    if (existing.exists && existing.data()?['status'] == 'pending') return id;

    final reverse = await col.doc(requestId(toUid, from.uid)).get();
    if (reverse.exists && reverse.data()?['status'] == 'pending') {
      return reverse.id;
    }

    await col.doc(id).set({
      'fromUid': from.uid,
      'fromUsername': from.username,
      'fromPhotoUrl': from.photoUrl,
      'toUid': toUid,
      'toUsername': toUsername,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  Future<bool> acceptRequest({
    required FriendRequest request,
    required UserProfile myProfile,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return false;

    try {
      return await firestore.runTransaction<bool>((tx) async {
        final reqRef = _requests!.doc(request.id);
        final reqSnap = await tx.get(reqRef);
        if (!reqSnap.exists) return false;
        final data = reqSnap.data()!;
        if (data['status'] != 'pending' || data['toUid'] != myProfile.uid) {
          return false;
        }

        final fromUid = data['fromUid'] as String;
        final fromUsername = data['fromUsername'] as String? ?? 'player';
        final fromPhoto = data['fromPhotoUrl'] as String?;

        final myRef = _user(myProfile.uid)!;
        final theirRef = _user(fromUid)!;
        final myFriendRef = myRef.collection('friends').doc(fromUid);
        final theirFriendRef = theirRef.collection('friends').doc(myProfile.uid);

        final theirUserSnap = await tx.get(theirRef);
        final theirData = theirUserSnap.data() ?? {};
        final theirBest = (theirData['bestScore'] as num?)?.toInt() ?? 0;
        final theirTheme =
            theirData['favoriteTheme'] as String? ?? 'classic';

        tx.set(myFriendRef, {
          'uid': fromUid,
          'username': fromUsername,
          if (fromPhoto != null) 'photoUrl': fromPhoto,
          'bestScore': theirBest,
          'favoriteTheme': theirTheme,
          'addedAt': FieldValue.serverTimestamp(),
        });
        tx.set(theirFriendRef, {
          'uid': myProfile.uid,
          'username': myProfile.username,
          if (myProfile.photoUrl != null) 'photoUrl': myProfile.photoUrl,
          'bestScore': myProfile.bestScore,
          'favoriteTheme': myProfile.favoriteTheme,
          'addedAt': FieldValue.serverTimestamp(),
        });

        tx.update(myRef, {'friendsCount': FieldValue.increment(1)});
        tx.update(theirRef, {'friendsCount': FieldValue.increment(1)});
        tx.delete(reqRef);
        return true;
      });
    } on Object {
      return false;
    }
  }

  Future<bool> rejectRequest(FriendRequest request, String myUid) async {
    final col = _requests;
    if (col == null) return false;
    final ref = col.doc(request.id);
    final snap = await ref.get();
    if (!snap.exists || snap.data()?['toUid'] != myUid) return false;
    await ref.delete();
    return true;
  }

  Future<bool> cancelSentRequest(String requestId, String myUid) async {
    final col = _requests;
    if (col == null) return false;
    final ref = col.doc(requestId);
    final snap = await ref.get();
    if (!snap.exists || snap.data()?['fromUid'] != myUid) return false;
    await ref.delete();
    return true;
  }

  Stream<List<LeaderboardEntry>> watchFriendLeaderboard(UserProfile? me) {
    if (me == null) return Stream.value([]);
    final friendsStream = watchFriends(me.uid);
    return friendsStream.map((friends) {
      final entries = <LeaderboardEntry>[
        LeaderboardEntry(
          uid: me.uid,
          username: me.username,
          score: me.bestScore,
          photoUrl: me.photoUrl,
          favoriteTheme: me.favoriteTheme,
        ),
        ...friends.map(
          (f) => LeaderboardEntry(
            uid: f.uid,
            username: f.username,
            score: f.bestScore,
            photoUrl: f.photoUrl,
            favoriteTheme: f.favoriteTheme,
          ),
        ),
      ];
      entries.sort((a, b) => b.score.compareTo(a.score));
      return [
        for (var i = 0; i < entries.length; i++)
          LeaderboardEntry(
            uid: entries[i].uid,
            username: entries[i].username,
            score: entries[i].score,
            photoUrl: entries[i].photoUrl,
            favoriteTheme: entries[i].favoriteTheme,
            country: entries[i].country,
            rank: i + 1,
          ),
      ];
    });
  }

  Future<void> syncScoreToFriends({
    required String uid,
    required int bestScore,
    required String favoriteTheme,
    required String username,
    String? photoUrl,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;

    final friendsSnap = await _friends(uid)?.get();
    if (friendsSnap == null || friendsSnap.docs.isEmpty) return;

    final batch = firestore.batch();
    final myFriendDocs = friendsSnap.docs;
    for (final doc in myFriendDocs) {
      batch.update(doc.reference, {
        'bestScore': bestScore,
        'favoriteTheme': favoriteTheme,
      });
      final friendUid = doc.id;
      final inverse = _friends(friendUid)?.doc(uid);
      if (inverse != null) {
        batch.set(
          inverse,
          {
            'uid': uid,
            'username': username,
            if (photoUrl != null) 'photoUrl': photoUrl,
            'bestScore': bestScore,
            'favoriteTheme': favoriteTheme,
          },
          SetOptions(merge: true),
        );
      }
    }
    await batch.commit();
  }
}
