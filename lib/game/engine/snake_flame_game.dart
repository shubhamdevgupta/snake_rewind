import 'dart:ui';

import 'package:flame/game.dart';

import '../../core/constants/game_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../controllers/game_controller.dart';
import '../controllers/input_controller.dart';
import 'board_renderer.dart';
import 'game_loop.dart';
import 'snake_renderer.dart';

class SnakeFlameGame extends FlameGame {
  SnakeFlameGame({
    required this.gameController,
    required this.inputController,
  });

  final GameController gameController;
  final InputController inputController;
  final GameLoop _loop = GameLoop();

  void resetLoop() => _loop.reset();

  double _cellSize = 0;
  double _boardW = 0;
  double _boardH = 0;

  @override
  Color backgroundColor() => ThemeManager.instance.theme.scaffold;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout(size.x, size.y);
  }

  void _layout(double w, double h) {
    final innerW = w - GameConstants.boardPadding * 2;
    final innerH = h - GameConstants.boardPadding * 2;
    final fromW = innerW / GameConstants.gridColumns;
    final fromH = innerH / GameConstants.gridRows;
    _cellSize = fromW < fromH ? fromW : fromH;
    _boardW = _cellSize * GameConstants.gridColumns;
    _boardH = _cellSize * GameConstants.gridRows;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final step = gameController.difficulty.tickMs / 1000.0;
    gameController.updateRender(dt, step);

    if (gameController.state != GameState.playing) return;

    _loop.update(
      dt: dt,
      stepSeconds: step,
      onTick: gameController.logicTick,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final theme = ThemeManager.instance.theme;
    final settings = ThemeManager.instance.settings;
    final highPerf = settings.highPerformanceMode;
    final ox = (size.x - _boardW) / 2;
    final oy = (size.y - _boardH) / 2;

    canvas.save();
    canvas.translate(ox, oy);

    BoardRenderer.paintBoard(
      canvas: canvas,
      theme: theme,
      boardW: _boardW,
      boardH: _boardH,
      cellSize: _cellSize,
      showGrid: settings.showGrid,
    );

    final food = gameController.renderFood;
    if (food != null) {
      BoardRenderer.paintFood(
        canvas: canvas,
        theme: theme,
        food: food,
        prevFood: gameController.previousFoodPosition,
        foodLerp: gameController.foodMoveProgress,
        cellSize: _cellSize,
        time: highPerf ? gameController.gameTime : 0,
        smooth: settings.smoothMovement,
        animated: highPerf,
      );
    }

    if (gameController.eatFlash > 0 && food != null) {
      final fp = food.position;
      BoardRenderer.paintEatFlash(
        canvas,
        Offset(
          fp.x * _cellSize + _cellSize / 2,
          fp.y * _cellSize + _cellSize / 2,
        ),
        _cellSize,
        gameController.eatFlash,
        theme.foodGlow,
      );
    }

    SnakeRenderer.paint(
      canvas: canvas,
      theme: theme,
      snake: gameController.renderSnake,
      direction: gameController.direction,
      previousSegments: gameController.previousSegments,
      lerp: gameController.moveProgress,
      cellSize: _cellSize,
      smooth: settings.smoothMovement,
      glowEffects: highPerf,
    );

    canvas.restore();

    if (settings.crtEffect && highPerf) {
      BoardRenderer.paintCrtOverlay(canvas, Size(size.x, size.y));
    }
  }
}
