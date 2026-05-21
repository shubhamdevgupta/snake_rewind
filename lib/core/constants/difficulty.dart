import 'game_constants.dart';

enum Difficulty {
  easy(label: 'EASY', tickMs: 280, scoreMultiplier: 1),
  medium(
    label: 'MED',
    tickMs: GameConstants.defaultTickMs,
    scoreMultiplier: 2,
  ),
  hard(label: 'HARD', tickMs: 120, scoreMultiplier: 3);

  const Difficulty({
    required this.label,
    required this.tickMs,
    required this.scoreMultiplier,
  });

  final String label;
  final int tickMs;
  final int scoreMultiplier;

  int pointsForFood() =>
      GameConstants.pointsPerFood * scoreMultiplier;
}
