import 'package:flutter/foundation.dart';

class ScoreController {
  final score = ValueNotifier<int>(0);
  final highScore = ValueNotifier<int>(0);
  final isPaused = ValueNotifier<bool>(false);
  final scorePopup = ValueNotifier<int?>(null);

  void resetScore() {
    score.value = 0;
    scorePopup.value = null;
  }

  void setHighScore(int value) => highScore.value = value;

  void addPoints(int points) {
    score.value += points;
    scorePopup.value = points;
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (scorePopup.value == points) scorePopup.value = null;
    });
  }

  void dispose() {
    score.dispose();
    highScore.dispose();
    isPaused.dispose();
    scorePopup.dispose();
  }
}
