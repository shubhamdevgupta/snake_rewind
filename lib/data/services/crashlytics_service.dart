import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/exception_mapper.dart';

abstract final class CrashlyticsService {
  static FirebaseCrashlytics? _crashlytics;

  static Future<void> init() async {
    _crashlytics = FirebaseCrashlytics.instance;
    await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = (details) {
      if (ExceptionMapper.shouldReportToCrashlytics(details.exception)) {
        _crashlytics?.recordFlutterFatalError(details);
      } else if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (ExceptionMapper.shouldReportToCrashlytics(error)) {
        _crashlytics?.recordError(error, stack, fatal: true);
      }
      return true;
    };
  }

  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!ExceptionMapper.shouldReportToCrashlytics(error)) return;
    await _crashlytics?.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  static Future<void> log(String message) async {
    await _crashlytics?.log(message);
  }
}
