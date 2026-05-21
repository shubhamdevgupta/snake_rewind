import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/firebase/firebase_bootstrap.dart';
import '../models/leaderboard_entry.dart';

enum LeaderboardType { global, weekly, theme, friends }

class LeaderboardRepository {
  LeaderboardRepository({FirebaseFirestore? firestore}) : _db = firestore;

  final FirebaseFirestore? _db;

  FirebaseFirestore? get _firestore {
    if (_db != null) return _db;
    if (!FirebaseBootstrap.initialized || Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  static const int pageSize = 20;

  String _weekId() {
    final now = DateTime.now().toUtc();
    final jan1 = DateTime.utc(now.year, 1, 1);
    final dayOfYear = now.difference(jan1).inDays + 1;
    final week = ((dayOfYear + jan1.weekday - 1) / 7).ceil();
    return '${now.year}-W$week';
  }

  CollectionReference<Map<String, dynamic>>? _collection(
    LeaderboardType type, {
    String? themeId,
  }) {
    final db = _firestore;
    if (db == null) return null;
    switch (type) {
      case LeaderboardType.global:
        return db.collection('leaderboards').doc('global').collection('entries');
      case LeaderboardType.weekly:
        return db
            .collection('leaderboards')
            .doc('weekly')
            .collection(_weekId());
      case LeaderboardType.theme:
        return db
            .collection('leaderboards')
            .doc('themes')
            .collection(themeId ?? 'classic');
      case LeaderboardType.friends:
        return db.collection('leaderboards').doc('friends').collection('entries');
    }
  }

  Future<void> submitScore({
    required String uid,
    required LeaderboardEntry entry,
    String? themeId,
  }) async {
    final data = entry.toFirestore();
    final db = _firestore;
    if (db == null) return;

    final batch = db.batch();
    final global = _collection(LeaderboardType.global);
    final weekly = _collection(LeaderboardType.weekly);
    if (global != null) batch.set(global.doc(uid), data, SetOptions(merge: true));
    if (weekly != null) batch.set(weekly.doc(uid), data, SetOptions(merge: true));
    if (themeId != null) {
      final theme = _collection(LeaderboardType.theme, themeId: themeId);
      if (theme != null) batch.set(theme.doc(uid), data, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Stream<List<LeaderboardEntry>> watchTop({
    LeaderboardType type = LeaderboardType.global,
    String? themeId,
    int limit = 20,
  }) {
    final col = _collection(type, themeId: themeId);
    if (col == null) return Stream.value([]);
    return col.orderBy('score', descending: true).limit(limit).snapshots().map((s) {
      var rank = 0;
      return s.docs.map((d) {
        rank++;
        return LeaderboardEntry.fromFirestore(d, rank: rank);
      }).toList();
    });
  }
}
