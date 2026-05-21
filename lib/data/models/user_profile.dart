import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/username_validator.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.username,
    this.displayName,
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
    this.friendsCount = 0,
    this.friendIds = const [],
    this.createdAt,
    this.lastSyncAt,
  });

  final String uid;
  final String username;
  final String? displayName;
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
  final int friendsCount;
  final List<String> friendIds;
  final DateTime? createdAt;
  final DateTime? lastSyncAt;

  bool get hasValidUsername =>
      username.isNotEmpty &&
      UsernameValidator.isValidFormat(username) &&
      !UsernameValidator.isPlaceholder(username, uid);

  String get atUsername => UsernameValidator.display(username);

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
        username: '',
        displayName: 'Guest',
        isGuest: true,
        createdAt: DateTime.now(),
      );

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      username: d['username'] as String? ?? '',
      displayName: d['displayName'] as String?,
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
      friendsCount: (d['friendsCount'] as num?)?.toInt() ?? 0,
      friendIds: List<String>.from(d['friendIds'] as List? ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      lastSyncAt: (d['lastSyncAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'username': username,
        if (username.isNotEmpty) 'usernameLower': username.toLowerCase(),
        if (displayName != null) 'displayName': displayName,
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
        'friendsCount': friendsCount,
        'friendIds': friendIds,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'lastSyncAt': FieldValue.serverTimestamp(),
      };

  UserProfile copyWith({
    String? username,
    String? displayName,
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
    int? friendsCount,
    List<String>? friendIds,
    DateTime? lastSyncAt,
  }) {
    return UserProfile(
      uid: uid,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
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
      friendsCount: friendsCount ?? this.friendsCount,
      friendIds: friendIds ?? this.friendIds,
      createdAt: createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}
