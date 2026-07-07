import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../data/services/analytics_service.dart';
import '../../data/services/crashlytics_service.dart';
import 'firebase_options.dart';

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({
    required this.success,
    this.error,
    this.stackTrace,
  });

  final bool success;
  final Object? error;
  final StackTrace? stackTrace;

  String get message =>
      error?.toString() ?? 'Firebase initialization failed.';
}

abstract final class FirebaseBootstrap {
  static bool initialized = false;
  static FirebaseBootstrapResult? lastResult;

  static Future<void> init() async {
    final result = await initForStartup();
    if (!result.success) {
      throw result.error ?? StateError(result.message);
    }
  }

  /// Startup-safe init: returns result instead of swallowing failures.
  static Future<FirebaseBootstrapResult> initForStartup() async {
    if (initialized) {
      return const FirebaseBootstrapResult(success: true);
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await CrashlyticsService.init();
      await AnalyticsService.init();
      initialized = true;
      lastResult = const FirebaseBootstrapResult(success: true);
      unawaited(AnalyticsService.logAppOpen());
      return lastResult!;
    } on Object catch (error, stackTrace) {
      initialized = false;
      lastResult = FirebaseBootstrapResult(
        success: false,
        error: error,
        stackTrace: stackTrace,
      );
      if (kDebugMode) {
        debugPrint('FirebaseBootstrap failed: $error');
      }
      return lastResult!;
    }
  }

  @Deprecated('Use initForStartup during cold start')
  static Future<void> safeInit() async {
    await initForStartup();
  }
}
