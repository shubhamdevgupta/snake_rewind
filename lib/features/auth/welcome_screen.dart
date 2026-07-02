import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../game/widgets/retro_button.dart';
import '../../shared/widgets/retro_dialogs.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    AnalyticsService.logScreen('welcome');
    AuthController.instance.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AuthController.instance.removeListener(_onAuthChanged);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final auth = AuthController.instance;
    final busy = auth.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffold,
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _anim, curve: Curves.easeOut),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'SNAKE',
                  style: TextStyle(
                    color: theme.uiPrimary,
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                    fontFamily: 'monospace',
                    shadows: [
                      Shadow(
                        color: theme.uiAccent.withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'REWIND',
                  style: TextStyle(
                    color: theme.uiAccent,
                    fontSize: 18,
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Classic arcade. Cloud ranks. Retro soul.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.uiPrimary.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      auth.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.uiAccent, fontSize: 12),
                    ),
                  ),
                if (Platform.isIOS)
                  SizedBox(
                    width: double.infinity,
                    child: RetroButton(
                      theme: theme,
                      label: 'CONTINUE WITH APPLE',
                      onPressed: busy ? null : () => auth.signInWithApple(),
                    ),
                  ),
                if (Platform.isIOS) const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      RetroButton(
                        theme: theme,
                        label: 'Sign In With Google',
                        flex: 2,
                        onPressed: busy ? null : () => auth.signInWithGoogle(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      RetroButton(
                        theme: theme,
                        label: 'GUEST',
                        flex: 2,
                        onPressed: busy ? null : () => auth.continueAsGuest(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _link(theme, 'Privacy'),
                    Text(
                      ' · ',
                      style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.4)),
                    ),
                    _link(theme, 'Terms'),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _link(dynamic theme, String label) {
    return TextButton(
      onPressed: () => RetroDialogs.showError(
        context,
        title: label.toUpperCase(),
        message: 'Add your $label policy URL before App Store release.',
      ),
      child: Text(
        label,
        style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.6), fontSize: 11),
      ),
    );
  }
}
