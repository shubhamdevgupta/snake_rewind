import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/firebase/firebase_bootstrap.dart';
import '../models/achievement_model.dart';

class AchievementRepository {
  AchievementRepository({FirebaseFirestore? firestore}) : _db = firestore;

  final FirebaseFirestore? _db;

  FirebaseFirestore? get _firestore {
    if (_db != null) return _db;
    if (!FirebaseBootstrap.initialized || Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? _achievements(String uid) =>
      _firestore?.collection('users').doc(uid).collection('achievements');

  Future<Map<String, AchievementProgress>> fetchProgress(
    String uid,
    List<AchievementDefinition> definitions,
  ) async {
    final col = _achievements(uid);
    if (col == null) {
      return {
        for (final def in definitions)
          def.id: AchievementProgress(definition: def),
      };
    }
    final snap = await col.get();
    final map = <String, Map<String, dynamic>>{
      for (final d in snap.docs) d.id: d.data(),
    };

    return {
      for (final def in definitions)
        def.id: AchievementProgress(
          definition: def,
          progress: (map[def.id]?['progress'] as num?)?.toInt() ?? 0,
          unlocked: map[def.id]?['unlocked'] as bool? ?? false,
          unlockedAt: (map[def.id]?['unlockedAt'] as Timestamp?)?.toDate(),
        ),
    };
  }

  Future<void> saveProgress(String uid, AchievementProgress progress) async {
    final col = _achievements(uid);
    if (col == null) return;
    await col.doc(progress.definition.id).set({
      'progress': progress.progress,
      'unlocked': progress.unlocked,
      'unlockedAt': progress.unlocked
          ? FieldValue.serverTimestamp()
          : null,
    }, SetOptions(merge: true));
  }
}
