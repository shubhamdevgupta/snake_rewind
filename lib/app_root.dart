import 'package:flutter/material.dart';

import 'data/services/auth_controller.dart';
import 'features/auth/welcome_screen.dart';
import 'game/screens/home_screen.dart';

/// Routes between welcome (first launch) and main home — preserves game stack.
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

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    if (!auth.onboardingComplete) {
      return const WelcomeScreen();
    }
    return const HomeScreen();
  }
}
