import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/startup/startup_controller.dart';
import '../../core/startup/startup_theme.dart';

/// First screen after launch — never blank; shows retro splash + init progress.
class StartupScreen extends StatefulWidget {
  const StartupScreen({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with TickerProviderStateMixin {
  final _controller = StartupController.instance;
  late final AnimationController _snakeController;
  late final AnimationController _dotsController;
  late final AnimationController _fadeController;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(StartupTheme.systemUi);

    _snakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _controller.addListener(_onStartupChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_controller.run());
    });
  }

  void _onStartupChanged() {
    if (!mounted) return;
    setState(() {});

    if (_controller.isComplete && !_navigated) {
      _navigated = true;
      _fadeController.forward().whenComplete(() {
        if (mounted) widget.onComplete();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStartupChanged);
    _snakeController.dispose();
    _dotsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showError = _controller.hasFailed;

    return Scaffold(
      backgroundColor: StartupTheme.scaffold,
      body: SafeArea(
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(
            CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _LogoBlock(),
                const SizedBox(height: 28),
                _StartupSnakeAnimation(controller: _snakeController),
                const SizedBox(height: 28),
                if (showError) ...[
                  _ErrorPanel(
                    message: _controller.errorMessage ??
                        'Unable to initialize application.',
                    onRetry: () => unawaited(_controller.retry()),
                    onExit: SystemNavigator.pop,
                  ),
                ] else ...[
                  _LoadingDots(controller: _dotsController),
                  const SizedBox(height: 16),
                  Text(
                    _controller.step?.label ?? 'Initializing...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: StartupTheme.textMuted,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const Spacer(flex: 3),
                const Text(
                  '© Snake Rewinds',
                  style: TextStyle(
                    color: StartupTheme.textMuted,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'SNAKE',
          style: TextStyle(
            color: StartupTheme.primary,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: 10,
            fontFamily: 'monospace',
            shadows: [
              Shadow(
                color: StartupTheme.accent.withValues(alpha: 0.45),
                blurRadius: 14,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'REWINDS',
          style: TextStyle(
            color: StartupTheme.accent,
            fontSize: 16,
            letterSpacing: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StartupSnakeAnimation extends StatelessWidget {
  const _StartupSnakeAnimation({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SizedBox(
          height: 24,
          width: 160,
          child: CustomPaint(
            painter: _SnakePainter(progress: controller.value),
          ),
        );
      },
    );
  }
}

class _SnakePainter extends CustomPainter {
  _SnakePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const segments = 5;
    const segmentSize = 12.0;
    const gap = 4.0;
    final headPaint = Paint()..color = StartupTheme.primary;
    final bodyPaint = Paint()..color = StartupTheme.secondary;

    for (var i = 0; i < segments; i++) {
      final phase = (progress + i * 0.12) % 1.0;
      final x = phase * (size.width - segmentSize);
      final y = size.height / 2 + math.sin(phase * math.pi * 2) * 4;
      final paint = i == segments - 1 ? headPaint : bodyPaint;
      canvas.drawRect(
        Rect.fromLTWH(x, y - segmentSize / 2, segmentSize - gap, segmentSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SnakePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final active = ((controller.value * 3).floor() % 3) == index;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? StartupTheme.accent : StartupTheme.secondary,
                border: Border.all(color: StartupTheme.border, width: 1),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    required this.message,
    required this.onRetry,
    required this.onExit,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StartupTheme.secondary,
            border: Border.all(color: StartupTheme.border, width: 2),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: StartupTheme.primary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StartupButton(label: 'RETRY', onTap: onRetry),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StartupButton(label: 'EXIT', onTap: onExit, muted: true),
            ),
          ],
        ),
      ],
    );
  }
}

class _StartupButton extends StatelessWidget {
  const _StartupButton({
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: muted ? StartupTheme.scaffold : StartupTheme.secondary,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: StartupTheme.border, width: 2),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: muted ? StartupTheme.textMuted : StartupTheme.accent,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
