import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../data/services/auth_controller.dart';
import '../../data/services/crashlytics_service.dart';
import '../../game/services/audio_service.dart';
import '../../game/services/storage_service.dart';
import '../firebase/firebase_bootstrap.dart';
import '../network/network_service.dart';
import '../theme/theme_manager.dart';

enum StartupPhase { idle, running, success, failed }

enum StartupStep {
  preferences('Loading Preferences...'),
  network('Connecting Network...'),
  settings('Loading Settings...'),
  audio('Preparing Audio...'),
  firebase('Connecting Firebase...'),
  session('Syncing Profile...'),
  finalize('Preparing Arcade...');

  const StartupStep(this.label);
  final String label;
}

/// Orchestrates cold-start initialization with timeouts, retry, and offline fallback.
class StartupController extends ChangeNotifier {
  StartupController._();

  static final StartupController instance = StartupController._();

  static const Duration stepTimeout = Duration(seconds: 10);
  static const Duration totalTimeout = Duration(seconds: 45);

  StartupPhase _phase = StartupPhase.idle;
  StartupStep? _step;
  String? _errorMessage;
  Object? _lastError;

  StartupPhase get phase => _phase;
  StartupStep? get step => _step;
  String? get errorMessage => _errorMessage;

  bool get isComplete => _phase == StartupPhase.success;
  bool get hasFailed => _phase == StartupPhase.failed;
  bool get isRunning => _phase == StartupPhase.running;

  Future<void> run() async {
    if (_phase == StartupPhase.running) return;

    _phase = StartupPhase.running;
    _errorMessage = null;
    _lastError = null;
    notifyListeners();

    try {
      await _runAll().timeout(
        totalTimeout,
        onTimeout: () {
          throw TimeoutException(
            'Application initialization timed out.',
            totalTimeout,
          );
        },
      );
      _phase = StartupPhase.success;
      _step = null;
      notifyListeners();
    } on Object catch (error, stack) {
      await _record(error, stack, reason: 'startup_failed');
      _lastError = error;
      _errorMessage = _messageFor(error);
      _phase = StartupPhase.failed;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    _phase = StartupPhase.idle;
    _step = null;
    _errorMessage = null;
    notifyListeners();
    await run();
  }

  Future<void> _runAll() async {
    await _runStep(StartupStep.preferences, StorageService.init);
    await _runStep(StartupStep.network, NetworkService.init);
    await _runStep(StartupStep.settings, ThemeManager.instance.load);
    await _runStep(StartupStep.audio, AudioService.init);

    final firebaseOk = await _runStep(
      StartupStep.firebase,
      _initFirebase,
      optional: true,
    );

    if (firebaseOk == true) {
      await _runStep(
        StartupStep.session,
        AuthController.instance.initializeForStartup,
        optional: true,
      );
    } else {
      _setStep(StartupStep.session);
      await _runStep(
        StartupStep.session,
        AuthController.instance.initializeOfflineOnly,
        optional: true,
      );
    }

    await _runStep(StartupStep.finalize, _finalize);
  }

  Future<bool> _initFirebase() async {
    final result = await FirebaseBootstrap.initForStartup();
    return result.success;
  }

  Future<T?> _runStep<T>(
    StartupStep step,
    Future<T> Function() action, {
    bool optional = false,
  }) async {
    _setStep(step);
    try {
      return await action().timeout(
        stepTimeout,
        onTimeout: () {
          throw TimeoutException(step.label, stepTimeout);
        },
      );
    } on Object catch (error, stack) {
      await _record(error, stack, reason: 'startup_${step.name}');
      if (optional) {
        if (kDebugMode) {
          debugPrint('Startup optional step failed (${step.name}): $error');
        }
        return null;
      }
      rethrow;
    }
  }

  void _setStep(StartupStep step) {
    _step = step;
    notifyListeners();
  }

  Future<void> _finalize() async {
    final settings = ThemeManager.instance.settings;
    AudioService.muted = !settings.soundEnabled;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  }

  String _messageFor(Object error) {
    if (error is TimeoutException) {
      return 'Unable to initialize application.\nPlease check your connection and try again.';
    }
    return 'Unable to initialize application.\nPlease try again.';
  }

  Future<void> _record(Object error, StackTrace stack, {required String reason}) async {
    if (FirebaseBootstrap.initialized) {
      await CrashlyticsService.recordError(error, stack, reason: reason);
    } else if (kDebugMode) {
      debugPrint('Startup [$reason]: $error');
      debugPrint('$stack');
    }
  }
}
