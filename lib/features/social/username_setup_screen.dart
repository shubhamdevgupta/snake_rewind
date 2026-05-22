import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/controllers/social_controller.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../data/utils/username_validator.dart';
import '../../shared/widgets/social_snackbar.dart';

class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('username_setup');
    SocialController.instance.addListener(_onSocial);
  }

  void _onSocial() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SocialController.instance.removeListener(_onSocial);
    _controller.dispose();
    super.dispose();
  }

  bool get _canContinue {
    final social = SocialController.instance;
    final validation = UsernameValidator.validate(_controller.text);
    return validation.isValid &&
        social.usernameAvailable == true &&
        !social.isCheckingAvailability &&
        !_submitting;
  }

  Future<void> _continue() async {
    if (!_canContinue) return;
    final auth = AuthController.instance;
    final profile = auth.profile;
    if (profile == null) return;
    setState(() => _submitting = true);
    final ok = await SocialController.instance.claimUsername(
      profile,
      _controller.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      final name = UsernameValidator.normalize(_controller.text);
      auth.updateProfileLocal(profile.copyWith(username: name));
      await auth.refreshProfile();
      if (!mounted) return;
      showRetroSnack(context, 'Welcome @$name');
    } else {
      showRetroSnack(context, 'Username unavailable — try another');
      SocialController.instance.checkAvailability(
        _controller.text,
        excludeUid: auth.uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final social = SocialController.instance;
    final validation = UsernameValidator.validate(_controller.text);
    final statusColor = social.usernameAvailable == true
        ? theme.uiAccent
        : theme.textMuted;

    return Scaffold(
      backgroundColor: theme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'CHOOSE USERNAME',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textHighContrast,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your public arcade identity',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 32),
              RepaintBoundary(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.uiAccent, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    style: TextStyle(
                      color: theme.textOnBackground,
                      fontSize: 20,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixText: '@',
                      prefixStyle: TextStyle(
                        color: theme.uiAccent,
                        fontSize: 20,
                        fontFamily: 'monospace',
                      ),
                      hintText: 'retroking',
                      hintStyle: TextStyle(color: theme.textMuted.withValues(alpha: 0.5)),
                    ),
                    onChanged: (v) {
                      SocialController.instance.resetAvailability();
                      SocialController.instance.debouncedAvailability(
                        v,
                        excludeUid: AuthController.instance.uid,
                      );
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (social.isCheckingAvailability)
                Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.uiAccent,
                    ),
                  ),
                )
              else
                Text(
                  social.availabilityMessage ?? validation.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              const Spacer(),
              Material(
                color: _canContinue ? theme.uiSecondary : theme.scoreBackground,
                child: InkWell(
                  onTap: _canContinue ? _continue : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _canContinue ? theme.uiAccent : theme.boardBorder,
                        width: 2,
                      ),
                    ),
                    child: _submitting
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.textOnSurface,
                            ),
                          )
                        : Text(
                            'CONTINUE',
                            style: TextStyle(
                              color: _canContinue ? theme.uiAccent : theme.textMuted,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
