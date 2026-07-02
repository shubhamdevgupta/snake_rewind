import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_controller.dart';
import '../../data/utils/username_validator.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/social/friends_screen.dart';
import '../../shared/navigation/retro_navigation.dart';
import '../../shared/services/app_guard.dart';
import '../../shared/widgets/retro_avatar.dart';
import '../../shared/widgets/retro_dialogs.dart';
import '../../shared/widgets/retro_screen_shell.dart';
import '../../shared/widgets/social_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('profile');
    AuthController.instance.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AuthController.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  bool get _isBusy => _busy || AuthController.instance.isLoading;

  Future<void> _logout() async {
    if (_isBusy) return;
    final confirmed = await RetroDialogs.showConfirmation(
      context,
      title: 'LOG OUT?',
      message: 'You will return to the welcome screen.',
      confirmLabel: 'LOG OUT',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    await AuthController.instance.signOut();
    if (!mounted) return;
    setState(() => _busy = false);

    final error = AuthController.instance.error;
    if (error != null) {
      await RetroDialogs.showError(context, message: error);
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _deleteAccount() async {
    if (_isBusy) return;
    final confirmed = await RetroDialogs.showConfirmation(
      context,
      title: 'DELETE ACCOUNT?',
      message: 'This action cannot be undone.',
      confirmLabel: 'DELETE',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    if (!await AppGuard.ensureNetwork(context)) return;

    setState(() => _busy = true);
    var result = await AuthController.instance.deleteAccount();
    if (result == DeleteAccountResult.requiresReauth && mounted) {
      final reauth = await RetroDialogs.showConfirmation(
        context,
        title: 'VERIFY IDENTITY',
        message:
            'For your security, please sign in again to delete your account.',
        confirmLabel: 'CONTINUE',
      );
      if (reauth == true) {
        result = await AuthController.instance.reauthenticateAndDeleteAccount();
      } else {
        result = DeleteAccountResult.cancelled;
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case DeleteAccountResult.success:
        Navigator.of(context).popUntil((route) => route.isFirst);
        if (mounted) {
          showRetroSnack(context, 'Account deleted');
        }
      case DeleteAccountResult.cancelled:
        break;
      case DeleteAccountResult.requiresReauth:
      case DeleteAccountResult.failed:
        final message = AuthController.instance.error ??
            'Unable to delete account. Please try again.';
        if (mounted) {
          await RetroDialogs.showError(context, message: message);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;

    return RetroScreenShell(
      title: 'PROFILE',
      child: ListenableBuilder(
        listenable: AuthController.instance,
        builder: (context, _) {
          final p = AuthController.instance.profile;
          if (p == null) {
            return Center(
              child: Text(
                'Sign in to sync profile',
                style: TextStyle(color: theme.textOnBackground),
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    RepaintBoundary(
                      child: Center(
                        child: RetroAvatar(
                          photoUrl: p.photoUrl,
                          radius: 44,
                          theme: theme,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        p.hasValidUsername
                            ? UsernameValidator.display(p.username)
                            : 'Set username in setup',
                        style: TextStyle(
                          color: theme.uiAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    if (p.displayName != null && p.displayName != p.username) ...[
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          p.displayName!,
                          style: TextStyle(color: theme.textMuted, fontSize: 11),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _ProfileRow(theme: theme, label: 'RANK', value: p.rankLabel),
                    _ProfileRow(
                      theme: theme,
                      label: 'BEST',
                      value: p.bestScore.toString().padLeft(4, '0'),
                    ),
                    _ProfileRow(theme: theme, label: 'FRIENDS', value: '${p.friendsCount}'),
                    _ProfileRow(theme: theme, label: 'GAMES', value: '${p.totalGames}'),
                    _ProfileRow(theme: theme, label: 'FOOD', value: '${p.foodsEaten}'),
                    _ProfileRow(
                      theme: theme,
                      label: 'THEME',
                      value: p.favoriteTheme.toUpperCase(),
                    ),
                    _ProfileRow(
                      theme: theme,
                      label: 'MODE',
                      value: p.favoriteDifficulty.toUpperCase(),
                    ),
                    _ProfileRow(
                      theme: theme,
                      label: 'PLAY TIME',
                      value: '${p.totalPlayTimeSeconds ~/ 60} min',
                    ),
                    _ProfileRow(
                      theme: theme,
                      label: 'ACHIEVEMENTS',
                      value: '${p.achievementsUnlocked}',
                    ),
                    _ProfileRow(
                      theme: theme,
                      label: 'SYNC',
                      value: p.lastSyncAt != null ? 'Cloud OK' : 'Local',
                    ),
                    const SizedBox(height: 16),
                    _ProfileButton(
                      theme: theme,
                      label: 'ADD FRIENDS',
                      enabled: !_isBusy,
                      onTap: () => pushRetroScreen(context, const FriendsScreen()),
                    ),
                    const SizedBox(height: 8),
                    _ProfileButton(
                      theme: theme,
                      label: 'ACHIEVEMENTS',
                      enabled: !_isBusy,
                      onTap: () =>
                          pushRetroScreen(context, const AchievementsScreen()),
                    ),
                    const SizedBox(height: 8),
                    _ProfileButton(
                      theme: theme,
                      label: 'LOGOUT',
                      enabled: !_isBusy,
                      onTap: _logout,
                    ),
                    const SizedBox(height: 8),
                    _ProfileButton(
                      theme: theme,
                      label: 'DELETE ACCOUNT',
                      enabled: !_isBusy,
                      accent: theme.uiAccent,
                      onTap: _deleteAccount,
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.theme,
    required this.label,
    required this.value,
  });

  final dynamic theme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.scoreBackground,
          border: Border.all(color: theme.boardBorder, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.textMuted,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: theme.scoreText,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({
    required this.theme,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.accent,
  });

  final dynamic theme;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final textColor = enabled
        ? (accent ?? theme.textOnSurface)
        : theme.textMuted;
    return Material(
      color: enabled ? theme.uiSecondary : theme.scoreBackground,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: theme.boardBorder, width: 2),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
