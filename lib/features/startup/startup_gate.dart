import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_root.dart';
import '../../core/startup/startup_theme.dart';
import 'startup_screen.dart';

/// Shows [StartupScreen] until initialization completes, then fades into [AppRoot].
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _ready = false;

  void _onStartupComplete() {
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return StartupScreen(onComplete: _onStartupComplete);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: const AppRoot(),
    );
  }
}

/// Ensures system UI stays retro-dark during startup.
class StartupShell extends StatelessWidget {
  const StartupShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: StartupTheme.systemUi,
      child: child,
    );
  }
}
