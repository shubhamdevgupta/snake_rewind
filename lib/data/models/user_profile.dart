import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.username,
    this.email,
    this.photoUrl,
    this.bestScore = 0,
    this.totalGames = 0,
    this.foodsEaten = 0,
    this.favoriteTheme = 'classic',
    this.favoriteDifficulty = 'medium',
    this.achievementsUnlocked = 0,
    this.totalPlayTimeSeconds = 0,
    this.country,
    this.isGuest = false,
    this.friendIds = const [],
    this.createdAt,
    this.lastSyncAt,
  });

  final String uid;
  final String username;
  final String? email;
  final String? photoUrl;
  final int bestScore;
  final int totalGames;
  final int foodsEaten;
  final String favoriteTheme;
  final String favoriteDifficulty;
  final int achievementsUnlocked;
  final int totalPlayTimeSeconds;
  final String? country;
  final bool isGuest;
  final List<String> friendIds;
  final DateTime? createdAt;
  final DateTime? lastSyncAt;

  int get rankTier => switch (bestScore) {
        >= 1000 => 5,
        >= 500 => 4,
        >= 250 => 3,
        >= 100 => 2,
        _ => 1,
      };

  String get rankLabel => switch (rankTier) {
        5 => 'LEGEND',
        4 => 'MASTER',
        3 => 'EXPERT',
        2 => 'PRO',
        _ => 'ROOKIE',
      };

  factory UserProfile.guest(String uid) => UserProfile(
        uid: uid,
        username: 'Guest_${uid.substring(0, 6)}',
        isGuest: true,
        createdAt: DateTime.now(),
      );

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      username: d['username'] as String? ?? 'Player',
      email: d['email'] as String?,
      photoUrl: d['photoUrl'] as String?,
      bestScore: (d['bestScore'] as num?)?.toInt() ?? 0,
      totalGames: (d['totalGames'] as num?)?.toInt() ?? 0,
      foodsEaten: (d['foodsEaten'] as num?)?.toInt() ?? 0,
      favoriteTheme: d['favoriteTheme'] as String? ?? 'classic',
      favoriteDifficulty: d['favoriteDifficulty'] as String? ?? 'medium',
      achievementsUnlocked: (d['achievementsUnlocked'] as num?)?.toInt() ?? 0,
      totalPlayTimeSeconds: (d['totalPlayTimeSeconds'] as num?)?.toInt() ?? 0,
      country: d['country'] as String?,
      isGuest: d['isGuest'] as bool? ?? false,
      friendIds: List<String>.from(d['friendIds'] as List? ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      lastSyncAt: (d['lastSyncAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'username': username,
        if (email != null) 'email': email,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'bestScore': bestScore,
        'totalGames': totalGames,
        'foodsEaten': foodsEaten,
        'favoriteTheme': favoriteTheme,
        'favoriteDifficulty': favoriteDifficulty,
        'achievementsUnlocked': achievementsUnlocked,
        'totalPlayTimeSeconds': totalPlayTimeSeconds,
        if (country != null) 'country': country,
        'isGuest': isGuest,
        'friendIds': friendIds,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'lastSyncAt': FieldValue.serverTimestamp(),
      };

  UserProfile copyWith({
    String? username,
    String? email,
    String? photoUrl,
    int? bestScore,
    int? totalGames,
    int? foodsEaten,
    String? favoriteTheme,
    String? favoriteDifficulty,
    int? achievementsUnlocked,
    int? totalPlayTimeSeconds,
    String? country,
    List<String>? friendIds,
    DateTime? lastSyncAt,
  }) {
    return UserProfile(
      uid: uid,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bestScore: bestScore ?? this.bestScore,
      totalGames: totalGames ?? this.totalGames,
      foodsEaten: foodsEaten ?? this.foodsEaten,
      favoriteTheme: favoriteTheme ?? this.favoriteTheme,
      favoriteDifficulty: favoriteDifficulty ?? this.favoriteDifficulty,
      achievementsUnlocked:
          achievementsUnlocked ?? this.achievementsUnlocked,
      totalPlayTimeSeconds:
          totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
      country: country ?? this.country,
      isGuest: isGuest,
      friendIds: friendIds ?? this.friendIds,
      createdAt: createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}
