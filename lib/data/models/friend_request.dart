import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.fromUid,
    required this.fromUsername,
    required this.toUid,
    this.fromPhotoUrl,
    this.toUsername,
    this.status = FriendRequestStatus.pending,
    this.createdAt,
  });

  final String id;
  final String fromUid;
  final String fromUsername;
  final String toUid;
  final String? fromPhotoUrl;
  final String? toUsername;
  final FriendRequestStatus status;
  final DateTime? createdAt;

  factory FriendRequest.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return FriendRequest(
      id: doc.id,
      fromUid: d['fromUid'] as String? ?? '',
      fromUsername: d['fromUsername'] as String? ?? 'player',
      toUid: d['toUid'] as String? ?? '',
      fromPhotoUrl: d['fromPhotoUrl'] as String?,
      toUsername: d['toUsername'] as String?,
      status: _statusFromString(d['status'] as String?),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'fromUid': fromUid,
        'fromUsername': fromUsername,
        'toUid': toUid,
        if (fromPhotoUrl != null) 'fromPhotoUrl': fromPhotoUrl,
        if (toUsername != null) 'toUsername': toUsername,
        'status': status.name,
        'createdAt': FieldValue.serverTimestamp(),
      };

  static FriendRequestStatus _statusFromString(String? s) =>
      FriendRequestStatus.values.firstWhere(
        (e) => e.name == s,
        orElse: () => FriendRequestStatus.pending,
      );
}
