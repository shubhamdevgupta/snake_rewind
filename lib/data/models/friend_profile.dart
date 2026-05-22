import 'package:cloud_firestore/cloud_firestore.dart';

/// Friend entry in users/{uid}/friends/{friendUid} — public fields only.
class FriendProfile {
  const FriendProfile({
    required this.uid,
    required this.username,
    this.photoUrl,
    this.bestScore = 0,
    this.favoriteTheme = 'classic',
    this.addedAt,
  });

  final String uid;
  final String username;
  final String? photoUrl;
  final int bestScore;
  final String favoriteTheme;
  final DateTime? addedAt;

  factory FriendProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return FriendProfile(
      uid: doc.id,
      username: d['username'] as String? ?? 'player',
      photoUrl: d['photoUrl'] as String?,
      bestScore: (d['bestScore'] as num?)?.toInt() ?? 0,
      favoriteTheme: d['favoriteTheme'] as String? ?? 'classic',
      addedAt: (d['addedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'username': username,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'bestScore': bestScore,
        'favoriteTheme': favoriteTheme,
        'addedAt': FieldValue.serverTimestamp(),
      };
}
