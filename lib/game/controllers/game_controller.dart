import 'dart:async';

import '../../core/constants/difficulty.dart';
import '../../core/utils/food_spawner.dart';
import '../engine/collision_engine.dart';
import '../models/direction.dart';
import '../models/food.dart';
import '../models/position.dart';
import '../models/snake.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../services/vibration_service.dart';
import '../../core/theme/theme_manager.dart';
import 'input_controller.dart';
import 'score_controller.dart';

enum GameState { idle, playing, paused, gameOver }

class GameOverInfo {
  const GameOverInfo({
    required this.score,
    required this.highScore,
    required this.isNewRecord,
    required this.snakeLength,
  });

  final int score;
  final int highScore;
  final bool isNewRecord;
  final int snakeLength;
}

typedef GameOverCallback = void Function(GameOverInfo info);

class GameController {
  GameController({
    required this.difficulty,
    required this.input,
    required this.scoreController,
    this.onGameOver,
  }) {
    reset();
  }

  Difficulty difficulty;
  final InputController input;
  final ScoreController scoreController;
  GameOverCallback? onGameOver;

  GameState state = GameState.idle;
  Snake snake = Snake.initial();
  Food? food;
  Direction direction = Direction.right;

  /// Previous segment positions for smooth interpolation.
  List<Position> previousSegments = [];
  Position? previousFoodPosition;
  double moveProgress = 1.0;
  double foodMoveProgress = 1.0;
  double eatFlash = 0;
  double gameTime = 0;

  bool _ending = false;

  Snake get renderSnake => snake;
  Food? get renderFood => food;

  void reset() {
    _ending = false;
    snake = Snake.initial();
    direction = Direction.right;
    input.clear();
    food = FoodSpawner.spawn(snake);
    previousSegments = List.from(snake.segments);
    previousFoodPosition = food?.position;
    moveProgress = 1.0;
    foodMoveProgress = 1.0;
    eatFlash = 0;
    scoreController.resetScore();
    state = GameState.idle;
    scoreController.isPaused.value = false;
  }

  void start() {
    if (state == GameState.gameOver) reset();
    state = GameState.playing;
    scoreController.isPaused.value = false;
  }

  void pause() {
    if (state != GameState.playing) return;
    state = GameState.paused;
    scoreController.isPaused.value = true;
  }

  void resume() {
    if (state != GameState.paused) return;
    state = GameState.playing;
    scoreController.isPaused.value = false;
  }

  void togglePause() {
    if (state == GameState.paused) {
      resume();
    } else if (state == GameState.playing) {
      pause();
    }
  }

  void setDirection(Direction newDirection) {
    if (isGameOver || state != GameState.playing) return;
    final active = input.peekQueued() ?? direction;
    if (newDirection == active.opposite) return;
    input.enqueue(newDirection, direction);
  }

  bool get isGameOver => state == GameState.gameOver;

  /// Advance interpolation each frame (Flame update).
  void updateRender(double dt, double stepSeconds) {
    gameTime += dt;
    if (eatFlash > 0) eatFlash = (eatFlash - dt * 4).clamp(0.0, 1.0);

    if (state != GameState.playing || stepSeconds <= 0) return;

    final smooth = ThemeManager.instance.smoothMovement;
    if (!smooth) {
      moveProgress = 1.0;
      foodMoveProgress = 1.0;
      return;
    }

    moveProgress = (moveProgress + dt / stepSeconds).clamp(0.0, 1.0);
    foodMoveProgress = (foodMoveProgress + dt / stepSeconds).clamp(0.0, 1.0);
  }

  void logicTick() {
    if (state != GameState.playing || _ending) return;

    previousSegments = List.from(snake.segments);
    previousFoodPosition = food?.position;
    moveProgress = 0;
    foodMoveProgress = 0;

    final nextDir = input.consume(direction);
    if (nextDir != null) direction = nextDir;

    final ate = food != null && _willEatFood();
    final next = snake.moved(direction, grow: ate);

    if (CollisionEngine.hitsWall(next.head)) {
      _endGame();
      return;
    }

    snake = next;

    if (CollisionEngine.hitsSelf(snake)) {
      _endGame();
      return;
    }

    if (ate) {
      scoreController.addPoints(difficulty.pointsForFood());
      eatFlash = 1.0;
      if (ThemeManager.instance.soundEnabled) {
        unawaited(AudioService.playEat());
      }
      if (ThemeManager.instance.vibrationEnabled) {
        VibrationService.light();
      }
      try {
        food = FoodSpawner.spawn(snake);
      } on StateError {
        _endGame();
      }
    }
  }

  bool _willEatFood() {
    if (food == null) return false;
    final (dx, dy) = direction.delta;
    return Position(snake.head.x + dx, snake.head.y + dy) == food!.position;
  }

  void _endGame() {
    if (_ending) return;
    _ending = true;
    state = GameState.gameOver;
    moveProgress = 1.0;

    final current = scoreController.score.value;
    final previousHigh = scoreController.highScore.value;
    final isNewRecord = current > previousHigh;

    if (isNewRecord) {
      scoreController.highScore.value = current;
      unawaited(StorageService.saveHighScore(current));
    }

    onGameOver?.call(
      GameOverInfo(
        score: current,
        highScore: scoreController.highScore.value,
        isNewRecord: isNewRecord,
        snakeLength: snake.length,
      ),
    );
    if (ThemeManager.instance.soundEnabled) {
      unawaited(AudioService.playGameOver());
    }
    if (ThemeManager.instance.vibrationEnabled) {
      VibrationService.heavy();
    }
  }

  void dispose() {
    onGameOver = null;
  }
}
