import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/firebase/firebase_bootstrap.dart';
import '../../game/services/storage_service.dart';
import '../models/user_profile.dart';
import '../models/user_stats.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore}) : _db = firestore;

  final FirebaseFirestore? _db;

  FirebaseFirestore? get _firestore {
    if (_db != null) return _db;
    if (!FirebaseBootstrap.initialized || Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  DocumentReference<Map<String, dynamic>>? _user(String uid) =>
      _firestore?.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>>? _stats(String uid) =>
      _firestore?.collection('stats').doc(uid);

  Future<UserProfile?> fetchProfile(String uid) async {
    final ref = _user(uid);
    if (ref == null) return null;
    final snap = await ref.get();
    if (!snap.exists) return null;
    final profile = UserProfile.fromFirestore(snap);
    await StorageService.cacheProfileJson(uid, profile.toCacheJson());
    return profile;
  }

  Future<UserProfile?> loadCachedProfile(String uid) async {
    final json = await StorageService.loadCachedProfileJson(uid);
    if (json == null) return null;
    return UserProfile.fromCacheJson(json);
  }

  Future<void> createOrUpdateProfile(UserProfile profile) async {
    final ref = _user(profile.uid);
    if (ref == null) return;
    await ref.set(profile.toFirestore(), SetOptions(merge: true));
    await StorageService.cacheProfileJson(profile.uid, profile.toCacheJson());
  }

  /// Updates Google auth metadata only — never clears an existing username.
  Future<void> mergeAuthMetadata({
    required String uid,
    String? email,
    String? photoUrl,
    String? displayName,
  }) async {
    final ref = _user(uid);
    if (ref == null) return;
    await ref.set(
      {
        if (email != null) 'email': email,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (displayName != null) 'displayName': displayName,
        'lastSyncAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<UserStats> fetchStats(String uid) async {
    final ref = _stats(uid);
    if (ref == null) return const UserStats();
    final snap = await ref.get();
    if (!snap.exists) return const UserStats();
    return UserStats.fromMap(snap.data()!);
  }

  Future<void> saveStats(String uid, UserStats stats) async {
    final ref = _stats(uid);
    if (ref == null) return;
    await ref.set(stats.toMap(), SetOptions(merge: true));
  }

  Stream<UserProfile?> watchProfile(String uid) {
    final ref = _user(uid);
    if (ref == null) return Stream.value(null);
    return ref.snapshots().map((s) {
      if (!s.exists) return null;
      return UserProfile.fromFirestore(s);
    });
  }
}
