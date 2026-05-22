import 'package:flutter/material.dart';

import 'data/services/auth_controller.dart';
import 'features/auth/welcome_screen.dart';
import 'features/social/username_setup_screen.dart';
import 'game/screens/home_screen.dart';
import 'shared/widgets/session_loading_screen.dart';

/// Routes between welcome, profile sync, username setup, and home.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    AuthController.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    AuthController.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Widget _routeFor(AuthController auth) {
    if (!auth.onboardingComplete) {
      return const WelcomeScreen(key: ValueKey('welcome'));
    }
    if (auth.isResolvingSession) {
      return const SessionLoadingScreen(key: ValueKey('loading'));
    }
    if (auth.needsUsernameSetup) {
      return const UsernameSetupScreen(key: ValueKey('username'));
    }
    return HomeScreen(key: ValueKey('home_${auth.uid}'));
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    final child = _routeFor(auth);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: child,
    );
  }
}
