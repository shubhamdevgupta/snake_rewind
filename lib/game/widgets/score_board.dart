import 'package:flutter/material.dart';

import '../../core/theme/game_theme_data.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({
    super.key,
    required this.theme,
    required this.score,
    required this.highScore,
    this.scorePopup,
  });

  final GameThemeData theme;
  final int score;
  final int highScore;
  final int? scorePopup;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.scoreBackground,
            border: Border.all(color: theme.boardBorder, width: 3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cell('SCORE', score),
              _cell('BEST', highScore),
            ],
          ),
        ),
        if (scorePopup != null)
          Positioned(
            top: -8,
            child: TweenAnimationBuilder<double>(
              key: ValueKey(scorePopup),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) => Opacity(
                opacity: 1 - value,
                child: Transform.translate(
                  offset: Offset(0, -20 * value),
                  child: child,
                ),
              ),
              child: Text(
                '+$scorePopup',
                style: TextStyle(
                  color: theme.uiAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _cell(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.scoreLabel,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        Text(
          value.toString().padLeft(4, '0'),
          style: TextStyle(
            color: theme.scoreText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            height: 1,
          ),
        ),
      ],
    );
  }
}
