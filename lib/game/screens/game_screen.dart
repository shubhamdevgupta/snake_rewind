import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/theme_manager.dart';
import '../controllers/game_controller.dart';
import '../controllers/input_controller.dart';
import '../controllers/score_controller.dart';
import '../engine/snake_flame_game.dart';
import '../models/direction.dart';
import '../../data/services/progression_service.dart';
import '../services/audio_service.dart';
import '../widgets/control_pad.dart';
import '../widgets/game_board.dart';
import '../widgets/retro_status_bar.dart';
import '../widgets/score_board.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.initialHighScore});

  final int initialHighScore;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final InputController _input;
  late final ScoreController _scores;
  late final GameController _game;
  late final SnakeFlameGame _flameGame;
  bool _navigatingToGameOver = false;

  @override
  void initState() {
    super.initState();
    final settings = ThemeManager.instance.settings;
    AudioService.muted = !settings.soundEnabled;

    _input = InputController();
    _scores = ScoreController()..highScore.value = widget.initialHighScore;
    _game = GameController(
      difficulty: settings.difficulty,
      input: _input,
      scoreController: _scores,
      onGameOver: _onGameOver,
    );
    _flameGame = SnakeFlameGame(
      gameController: _game,
      inputController: _input,
    );
    _game.start();
    if (settings.soundEnabled) AudioService.startMusic();
    ProgressionService.instance.trackGameStart();
    ThemeManager.instance.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _onGameOver(GameOverInfo info) {
    if (_navigatingToGameOver || !mounted) return;
    _navigatingToGameOver = true;
    AudioService.stopMusic();
    final settings = ThemeManager.instance.settings;
    final foods = settings.difficulty.pointsForFood() > 0
        ? info.score ~/ settings.difficulty.pointsForFood()
        : 0;
    ProgressionService.instance.onGameEnd(info, foodsEaten: foods);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) => GameOverScreen(
            score: info.score,
            highScore: info.highScore,
            isNewRecord: info.isNewRecord,
            snakeLength: info.snakeLength,
          ),
          transitionsBuilder: (_, anim, __, child) => ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOut),
            ),
            child: FadeTransition(opacity: anim, child: child),
          ),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    });
  }

  void _enqueue(Direction d) {
    _input.enqueue(d, _game.direction);
    if (ThemeManager.instance.soundEnabled) AudioService.playClick();
  }

  void _restart() {
    _navigatingToGameOver = false;
    _flameGame.resetLoop();
    _game.reset();
    _game.start();
  }

  @override
  void dispose() {
    ThemeManager.instance.removeListener(_onThemeChanged);
    _game.dispose();
    _scores.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final playing = _game.state == GameState.playing;
    final paused = _game.state == GameState.paused;
    final controlsEnabled = playing && !paused;

    return Scaffold(
      backgroundColor: theme.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _scores.score,
              builder: (_, score, child) => ValueListenableBuilder<int>(
                valueListenable: _scores.highScore,
                builder: (_, high, child) => ValueListenableBuilder<int?>(
                  valueListenable: _scores.scorePopup,
                  builder: (_, popup, child) => Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Column(
                      children: [
                        ScoreBoard(
                          theme: theme,
                          score: score,
                          highScore: high,
                          scorePopup: popup,
                        ),
                        if (paused)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'PAUSED',
                              style: TextStyle(
                                color: theme.uiPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: RepaintBoundary(
                  child: GameBoard(
                    flameGame: _flameGame,
                    gameController: _game,
                    inputController: _input,
                    enabled: controlsEnabled,
                    borderColor: theme.boardBorder,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ControlPad(
                theme: theme,
                enabled: controlsEnabled,
                onDirection: _enqueue,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _chip(
                      theme,
                      paused ? 'RESUME' : 'PAUSE',
                      () {
                        if (ThemeManager.instance.soundEnabled) {
                          AudioService.playClick();
                        }
                        _game.togglePause();
                        if (_game.state == GameState.playing) {
                          _flameGame.resetLoop();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _chip(theme, 'RESTART', () {
                      if (ThemeManager.instance.soundEnabled) {
                        AudioService.playClick();
                      }
                      _restart();
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(dynamic theme, String label, VoidCallback onTap) {
    return Material(
      color: theme.uiSecondary,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: theme.boardBorder, width: 2),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: theme.uiPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
