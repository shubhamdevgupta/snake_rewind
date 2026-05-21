import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.uid,
    required this.username,
    required this.score,
    this.photoUrl,
    this.favoriteTheme = 'classic',
    this.country,
    this.rank = 0,
    this.updatedAt,
  });

  final String uid;
  final String username;
  final int score;
  final String? photoUrl;
  final String favoriteTheme;
  final String? country;
  final int rank;
  final DateTime? updatedAt;

  factory LeaderboardEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    int rank = 0,
  }) {
    final d = doc.data() ?? {};
    return LeaderboardEntry(
      uid: doc.id,
      username: d['username'] as String? ?? 'Player',
      score: (d['score'] as num?)?.toInt() ?? 0,
      photoUrl: d['photoUrl'] as String?,
      favoriteTheme: d['favoriteTheme'] as String? ?? 'classic',
      country: d['country'] as String?,
      rank: rank,
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'username': username,
        'score': score,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'favoriteTheme': favoriteTheme,
        if (country != null) 'country': country,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
