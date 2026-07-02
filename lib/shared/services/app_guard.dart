import 'package:flutter/material.dart';

import '../../core/errors/app_error.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/network/network_service.dart';
import '../../data/services/crashlytics_service.dart';
import '../widgets/retro_dialogs.dart';
import 'loading_controller.dart';

abstract final class AppGuard {
  static Future<T?> runRemote<T>({
    required Future<T> Function() action,
    BuildContext? context,
    String? loadingMessage,
    bool showLoading = true,
    bool requireNetwork = true,
    bool showErrorDialog = false,
    void Function(String message)? onError,
  }) async {
    if (requireNetwork && !await NetworkService.ensureOnline()) {
      const message = 'No Internet Connection';
      onError?.call(message);
      if (context != null && context.mounted) {
        if (showErrorDialog) {
          await RetroDialogs.showNetworkError(context);
        } else {
          RetroDialogs.showNetworkSnack(context);
        }
      }
      return null;
    }

    Future<T> execute() => action();

    try {
      if (showLoading) {
        return await LoadingController.instance.run(
          execute,
          message: loadingMessage,
        );
      }
      return await execute();
    } on Object catch (error, stack) {
      final message = ExceptionMapper.message(error);
      onError?.call(message);
      if (ExceptionMapper.shouldReportToCrashlytics(error)) {
        await CrashlyticsService.recordError(error, stack, reason: 'app_guard');
      }
      if (context != null && context.mounted && showErrorDialog) {
        await RetroDialogs.showError(context, message: message);
      }
      return null;
    }
  }

  static Future<bool> ensureNetwork(BuildContext context) async {
    if (await NetworkService.hasConnection()) return true;
    if (context.mounted) {
      await RetroDialogs.showNetworkError(context);
    }
    return false;
  }

  static Never throwIfOffline() {
    throw const AppError.networkUnavailable();
  }
}
