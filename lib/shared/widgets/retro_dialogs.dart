import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';

abstract final class RetroDialogs {
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'CONFIRM',
    String cancelLabel = 'CANCEL',
    bool destructive = false,
  }) {
    final theme = ThemeManager.instance.theme;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RetroDialogShell(
        title: title,
        message: message,
        actions: [
          _DialogAction(
            label: cancelLabel,
            onTap: () => Navigator.pop(ctx, false),
          ),
          _DialogAction(
            label: confirmLabel,
            accent: destructive ? theme.uiAccent : theme.uiPrimary,
            onTap: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String message,
    String title = 'ERROR',
    String buttonLabel = 'OK',
  }) {
    return _showSingleAction(
      context,
      title: title,
      message: message,
      buttonLabel: buttonLabel,
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String message,
    String title = 'SUCCESS',
    String buttonLabel = 'OK',
  }) {
    return _showSingleAction(
      context,
      title: title,
      message: message,
      buttonLabel: buttonLabel,
    );
  }

  static Future<void> showNetworkError(BuildContext context) {
    return showError(
      context,
      title: 'NO INTERNET',
      message: 'Please turn on Wi-Fi or Mobile Data and try again.',
    );
  }

  static void showNetworkSnack(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.uiSecondary,
        content: Text(
          'No Internet Connection',
          style: TextStyle(
            color: theme.uiAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  static Future<void> showLoading(
    BuildContext context, {
    String message = 'PLEASE WAIT',
  }) {
    final theme = ThemeManager.instance.theme;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: theme.scaffold,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: theme.boardBorder, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.uiAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textOnBackground,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> hideLoading(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    return Future.value();
  }

  static Future<void> _showSingleAction(
    BuildContext context, {
    required String title,
    required String message,
    required String buttonLabel,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => _RetroDialogShell(
        title: title,
        message: message,
        actions: [
          _DialogAction(
            label: buttonLabel,
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}

class _RetroDialogShell extends StatelessWidget {
  const _RetroDialogShell({
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;
  final List<_DialogAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    return Dialog(
      backgroundColor: theme.scaffold,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.boardBorder, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.uiAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textOnBackground.withValues(alpha: 0.85),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ...actions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: action,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogAction extends StatelessWidget {
  const _DialogAction({
    required this.label,
    required this.onTap,
    this.accent,
  });

  final String label;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;
    final color = accent ?? theme.uiPrimary;
    return Material(
      color: theme.uiSecondary,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: theme.boardBorder, width: 2),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
