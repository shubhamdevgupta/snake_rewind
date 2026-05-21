class UserStats {
  const UserStats({
    this.totalGames = 0,
    this.totalFoodsEaten = 0,
    this.highestScore = 0,
    this.averageScore = 0,
    this.longestSnake = 0,
    this.favoriteTheme = 'classic',
    this.favoriteDifficulty = 'medium',
    this.totalPlayTimeSeconds = 0,
    this.totalDeaths = 0,
    this.hardModeGames = 0,
    this.amoledThemeWins = 0,
    this.themesUnlocked = 1,
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  final int totalGames;
  final int totalFoodsEaten;
  final int highestScore;
  final int averageScore;
  final int longestSnake;
  final String favoriteTheme;
  final String favoriteDifficulty;
  final int totalPlayTimeSeconds;
  final int totalDeaths;
  final int hardModeGames;
  final int amoledThemeWins;
  final int themesUnlocked;
  final int currentStreak;
  final int bestStreak;

  factory UserStats.fromMap(Map<String, dynamic> m) => UserStats(
        totalGames: (m['totalGames'] as num?)?.toInt() ?? 0,
        totalFoodsEaten: (m['totalFoodsEaten'] as num?)?.toInt() ?? 0,
        highestScore: (m['highestScore'] as num?)?.toInt() ?? 0,
        averageScore: (m['averageScore'] as num?)?.toInt() ?? 0,
        longestSnake: (m['longestSnake'] as num?)?.toInt() ?? 0,
        favoriteTheme: m['favoriteTheme'] as String? ?? 'classic',
        favoriteDifficulty: m['favoriteDifficulty'] as String? ?? 'medium',
        totalPlayTimeSeconds: (m['totalPlayTimeSeconds'] as num?)?.toInt() ?? 0,
        totalDeaths: (m['totalDeaths'] as num?)?.toInt() ?? 0,
        hardModeGames: (m['hardModeGames'] as num?)?.toInt() ?? 0,
        amoledThemeWins: (m['amoledThemeWins'] as num?)?.toInt() ?? 0,
        themesUnlocked: (m['themesUnlocked'] as num?)?.toInt() ?? 1,
        currentStreak: (m['currentStreak'] as num?)?.toInt() ?? 0,
        bestStreak: (m['bestStreak'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'totalGames': totalGames,
        'totalFoodsEaten': totalFoodsEaten,
        'highestScore': highestScore,
        'averageScore': averageScore,
        'longestSnake': longestSnake,
        'favoriteTheme': favoriteTheme,
        'favoriteDifficulty': favoriteDifficulty,
        'totalPlayTimeSeconds': totalPlayTimeSeconds,
        'totalDeaths': totalDeaths,
        'hardModeGames': hardModeGames,
        'amoledThemeWins': amoledThemeWins,
        'themesUnlocked': themesUnlocked,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
      };

  UserStats copyWith({
    int? totalGames,
    int? totalFoodsEaten,
    int? highestScore,
    int? averageScore,
    int? longestSnake,
    String? favoriteTheme,
    String? favoriteDifficulty,
    int? totalPlayTimeSeconds,
    int? totalDeaths,
    int? hardModeGames,
    int? amoledThemeWins,
    int? themesUnlocked,
    int? currentStreak,
    int? bestStreak,
  }) {
    return UserStats(
      totalGames: totalGames ?? this.totalGames,
      totalFoodsEaten: totalFoodsEaten ?? this.totalFoodsEaten,
      highestScore: highestScore ?? this.highestScore,
      averageScore: averageScore ?? this.averageScore,
      longestSnake: longestSnake ?? this.longestSnake,
      favoriteTheme: favoriteTheme ?? this.favoriteTheme,
      favoriteDifficulty: favoriteDifficulty ?? this.favoriteDifficulty,
      totalPlayTimeSeconds:
          totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
      totalDeaths: totalDeaths ?? this.totalDeaths,
      hardModeGames: hardModeGames ?? this.hardModeGames,
      amoledThemeWins: amoledThemeWins ?? this.amoledThemeWins,
      themesUnlocked: themesUnlocked ?? this.themesUnlocked,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }
}
