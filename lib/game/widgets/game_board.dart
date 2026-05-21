import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/game_controller.dart';
import '../controllers/input_controller.dart';
import '../engine/snake_flame_game.dart';
import '../models/direction.dart';
import '../services/audio_service.dart';
import '../../core/theme/theme_manager.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({
    super.key,
    required this.flameGame,
    required this.gameController,
    required this.inputController,
    required this.enabled,
    required this.borderColor,
  });

  final SnakeFlameGame flameGame;
  final GameController gameController;
  final InputController inputController;
  final bool enabled;
  final Color borderColor;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _direction(Direction d) {
    if (!widget.enabled) return;
    widget.inputController.enqueue(d, widget.gameController.direction);
    if (ThemeManager.instance.soundEnabled) AudioService.playClick();
    _focus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!widget.enabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final d = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => Direction.up,
      LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS => Direction.down,
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => Direction.left,
      LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD => Direction.right,
      _ => null,
    };
    if (d == null) return KeyEventResult.ignored;
    _direction(d);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: GestureDetector(
        onPanEnd: (d) {
          if (!widget.enabled) return;
          final v = d.velocity.pixelsPerSecond;
          if (v.dx.abs() < 28 && v.dy.abs() < 28) return;
          if (v.dx.abs() > v.dy.abs()) {
            _direction(v.dx > 0 ? Direction.right : Direction.left);
          } else {
            _direction(v.dy > 0 ? Direction.down : Direction.up);
          }
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: widget.borderColor, width: 4),
          ),
          child: ClipRect(
            child: GameWidget(
              game: widget.flameGame,
            ),
          ),
        ),
      ),
    );
  }
}
