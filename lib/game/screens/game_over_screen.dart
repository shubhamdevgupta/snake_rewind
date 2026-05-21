import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../services/audio_service.dart';
import '../widgets/retro_button.dart';
import 'game_screen.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    super.key,
    required this.score,
    required this.highScore,
    required this.isNewRecord,
    required this.snakeLength,
  });

  final int score;
  final int highScore;
  final bool isNewRecord;
  final int snakeLength;

  int get _foodsEaten {
    final p = ThemeManager.instance.settings.difficulty.pointsForFood();
    return p > 0 ? score ~/ p : 0;
  }

  void _playAgain(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(initialHighScore: highScore),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final difficulty = ThemeManager.instance.settings.difficulty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context);
      },
      child: Scaffold(
        backgroundColor: theme.scaffold,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: theme.scoreBackground,
                      border: Border.all(color: theme.boardBorder, width: 4),
                    ),
                    child: Text(
                      'GAME OVER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.scoreText,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                  if (isNewRecord) ...[
                    const SizedBox(height: 16),
                    Text(
                      '★ NEW RECORD ★',
                      style: TextStyle(
                        color: theme.uiAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _row(theme, 'SCORE', score.toString().padLeft(4, '0')),
                  const SizedBox(height: 8),
                  _row(theme, 'BEST', highScore.toString().padLeft(4, '0')),
                  const SizedBox(height: 8),
                  _row(theme, 'FOOD', _foodsEaten.toString().padLeft(2, '0')),
                  const SizedBox(height: 8),
                  _row(theme, 'LENGTH', snakeLength.toString().padLeft(2, '0')),
                  const SizedBox(height: 8),
                  _row(theme, 'MODE', difficulty.label),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 220,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            RetroButton(
                              theme: theme,
                              label: 'AGAIN',
                              flex: 2,
                              onPressed: () {
                                if (ThemeManager.instance.soundEnabled) {
                                  AudioService.playClick();
                                }
                                _playAgain(context);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            RetroButton(
                              theme: theme,
                              label: 'HOME',
                              flex: 2,
                              onPressed: () {
                                if (ThemeManager.instance.soundEnabled) {
                                  AudioService.playClick();
                                }
                                _goHome(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(dynamic theme, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scoreBackground,
        border: Border.all(color: theme.boardBorder, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: theme.scoreLabel,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          Text(value,
              style: TextStyle(
                  color: theme.scoreText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
