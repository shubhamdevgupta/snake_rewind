import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/crashlytics_service.dart';

abstract final class FirebaseBootstrap {
  static bool initialized = false;

  static Future<void> init() async {
    if (initialized) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await CrashlyticsService.init();
    await AnalyticsService.init();
    initialized = true;
    unawaited(AnalyticsService.logAppOpen());
  }

  static Future<void> safeInit() async {
    try {
      await init();
    } on Object catch (e, st) {
      debugPrint('Firebase init skipped: $e');
      if (initialized) {
        await CrashlyticsService.recordError(e, st, reason: 'firebase_init');
      }
    }
  }
}
