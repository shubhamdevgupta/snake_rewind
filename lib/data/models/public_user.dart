import 'package:cloud_firestore/cloud_firestore.dart';

/// Search result — uid used only for actions, never shown in UI.
enum SocialRelation {
  none,
  self,
  friends,
  pendingSent,
  pendingReceived,
}

class PublicUser {
  const PublicUser({
    required this.uid,
    required this.username,
    this.photoUrl,
    this.bestScore = 0,
    this.favoriteTheme = 'classic',
    this.relation = SocialRelation.none,
    this.pendingRequestId,
  });

  final String uid;
  final String username;
  final String? photoUrl;
  final int bestScore;
  final String favoriteTheme;
  final SocialRelation relation;
  final String? pendingRequestId;

  String get displayName => '@$username';

  factory PublicUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    SocialRelation relation = SocialRelation.none,
    String? pendingRequestId,
  }) {
    final d = doc.data() ?? {};
    return PublicUser(
      uid: doc.id,
      username: d['username'] as String? ?? 'player',
      photoUrl: d['photoUrl'] as String?,
      bestScore: (d['bestScore'] as num?)?.toInt() ?? 0,
      favoriteTheme: d['favoriteTheme'] as String? ?? 'classic',
      relation: relation,
      pendingRequestId: pendingRequestId,
    );
  }
}
