import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/app_error.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/network/network_service.dart';
import '../../core/firebase/firebase_bootstrap.dart';
import '../../game/services/storage_service.dart';
import '../../shared/services/loading_controller.dart';
import '../controllers/social_controller.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import '../repositories/friend_repository.dart';
import '../repositories/user_repository.dart';
import '../services/account_deletion_service.dart';
import 'crashlytics_service.dart';

enum AuthMode { none, guest, google, apple }

enum DeleteAccountResult {
  success,
  requiresReauth,
  failed,
  cancelled,
}

class AuthController extends ChangeNotifier {
  AuthController._();

  static final AuthController instance = AuthController._();

  AuthRepository? _authRepo;
  final UserRepository _userRepo = UserRepository();
  final AccountDeletionService _accountDeletion = AccountDeletionService();

  AuthRepository? get _auth =>
      FirebaseBootstrap.initialized ? (_authRepo ??= AuthRepository()) : null;

  User? _firebaseUser;
  UserProfile? _profile;
  AuthMode _mode = AuthMode.none;
  bool _loading = false;
  bool _onboardingComplete = false;
  bool _profileReady = false;
  String? _error;
  StreamSubscription<UserProfile?>? _profileSub;
  String? _watchingUid;

  User? get firebaseUser => _firebaseUser;

  UserProfile? get profile => _profile;

  AuthMode get mode => _mode;

  bool get isLoading => _loading || LoadingController.instance.isLoading;

  bool get onboardingComplete => _onboardingComplete;

  bool get profileReady => !isSignedIn || _profileReady;

  bool get isResolvingSession => isSignedIn && !_profileReady;

  String? get error => _error;

  String? get uid => _firebaseUser?.uid;

  bool get isSignedIn => _firebaseUser != null;

  bool get needsUsernameSetup =>
      isSignedIn &&
      _profileReady &&
      (_profile == null || !_profile!.hasValidUsername);

  static const Duration _startupProfileTimeout = Duration(seconds: 10);

  /// Cold-start session restore with timeouts and offline fallback.
  /// Never throws — startup must always complete.
  Future<void> initializeForStartup() async {
    try {
      _onboardingComplete = await StorageService.loadOnboardingComplete()
          .timeout(_startupProfileTimeout, onTimeout: () => false);

      if (_auth == null) {
        notifyListeners();
        return;
      }

      _firebaseUser = _auth!.currentUser;
      if (_firebaseUser == null) {
        notifyListeners();
        return;
      }

      _mode = _detectMode(_firebaseUser!);
      await _hydrateProfileWithOfflineFallback();
      notifyListeners();
    } on Object catch (e, st) {
      _profileReady = true;
      if (FirebaseBootstrap.initialized) {
        await CrashlyticsService.recordError(e, st, reason: 'startup_auth');
      }
      notifyListeners();
    }
  }

  /// When Firebase is unavailable — load local onboarding state only.
  Future<void> initializeOfflineOnly() async {
    try {
      _onboardingComplete = await StorageService.loadOnboardingComplete()
          .timeout(_startupProfileTimeout, onTimeout: () => false);
      _firebaseUser = null;
      _profile = null;
      _profileReady = true;
      _mode = AuthMode.none;
      notifyListeners();
    } on Object catch (e, st) {
      _profileReady = true;
      if (FirebaseBootstrap.initialized) {
        await CrashlyticsService.recordError(e, st, reason: 'startup_offline');
      }
      notifyListeners();
    }
  }

  @Deprecated('Use initializeForStartup during cold start')
  Future<void> initialize() => initializeForStartup();

  Future<void> _hydrateProfileWithOfflineFallback() async {
    final id = _firebaseUser!.uid;

    final cached = await _userRepo.loadCachedProfile(id);
    if (cached != null) {
      _profile = cached;
      _profileReady = true;
      notifyListeners();
    }

    try {
      await _loadProfileRemote(id).timeout(_startupProfileTimeout);
    } on TimeoutException catch (e, st) {
      if (FirebaseBootstrap.initialized) {
        await CrashlyticsService.recordError(
          e,
          st,
          reason: 'startup_profile_timeout',
        );
      }
      _applyOfflineProfileFallback();
    } on Object catch (e, st) {
      if (ExceptionMapper.shouldReportToCrashlytics(e)) {
        await CrashlyticsService.recordError(e, st, reason: 'startup_profile');
      }
      _applyOfflineProfileFallback();
    }

    _profileReady = true;
    _startProfileWatch();
  }

  Future<void> _loadProfileRemote(String id) async {
    final fetched = await _userRepo.fetchProfile(id);
    if (fetched != null) {
      _profile = fetched;
    } else {
      _applyOfflineProfileFallback();
    }
    await _persistProfileCache();
  }

  void _applyOfflineProfileFallback() {
    if (_profile != null || _firebaseUser == null) return;
    _profile = _firebaseUser!.isAnonymous
        ? UserProfile.guest(_firebaseUser!.uid)
        : UserProfile(
            uid: _firebaseUser!.uid,
            username: '',
            displayName: _firebaseUser!.displayName ?? 'Player',
            email: _firebaseUser!.email,
            photoUrl: _firebaseUser!.photoURL,
            isGuest: false,
            createdAt: DateTime.now(),
          );
  }

  Future<void> continueAsGuest() async {
    await _runAuthFlow(
      loadingMessage: 'SIGNING IN',
      action: () async {
        final cred = await _auth!.signInAsGuest();
        _firebaseUser = cred.user;
        _mode = AuthMode.guest;
        await _bootstrapProfileAfterSignIn(isGuest: true);
      },
      reason: 'guest_auth',
      fallbackMessage: 'Guest sign-in failed',
    );
  }

  Future<void> signInWithGoogle() async {
    await _runAuthFlow(
      loadingMessage: 'SIGNING IN',
      action: () async {
        final cred = await _auth!.signInWithGoogle();
        _firebaseUser = cred.user;
        _mode = AuthMode.google;
        await _bootstrapProfileAfterSignIn(isGuest: false);
      },
      reason: 'google_auth',
      fallbackMessage: 'Google sign-in failed',
    );
  }

  Future<void> signInWithApple() async {
    await _runAuthFlow(
      loadingMessage: 'SIGNING IN',
      action: () async {
        final cred = await _auth!.signInWithApple();
        _firebaseUser = cred.user;
        _mode = AuthMode.apple;
        await _bootstrapProfileAfterSignIn(isGuest: false);
      },
      reason: 'apple_auth',
      fallbackMessage: 'Apple sign-in failed',
    );
  }

  Future<DeleteAccountResult> deleteAccount() async {
    if (_auth == null || uid == null) {
      _error = 'Firebase not available';
      notifyListeners();
      return DeleteAccountResult.failed;
    }

    if (!await NetworkService.ensureOnline()) {
      _error = ExceptionMapper.message(const AppError.networkUnavailable());
      notifyListeners();
      return DeleteAccountResult.failed;
    }

    try {
      return await LoadingController.instance.run(() async {
        _setLoading(true);
        try {
          final id = uid!;
          final username =
              _profile?.hasValidUsername == true ? _profile!.username : null;

          await _accountDeletion.deleteAllRemoteData(
            uid: id,
            username: username,
          );
          await _auth!.deleteCurrentUser();
          await _clearLocalSession(id);
          return DeleteAccountResult.success;
        } on FirebaseAuthException catch (e, st) {
          if (e.code == 'requires-recent-login') {
            return DeleteAccountResult.requiresReauth;
          }
          _error = ExceptionMapper.message(e);
          if (ExceptionMapper.shouldReportToCrashlytics(e)) {
            await CrashlyticsService.recordError(e, st, reason: 'delete_account');
          }
          return DeleteAccountResult.failed;
        } on Object catch (e, st) {
          _error = ExceptionMapper.message(e);
          if (ExceptionMapper.shouldReportToCrashlytics(e)) {
            await CrashlyticsService.recordError(e, st, reason: 'delete_account');
          }
          return DeleteAccountResult.failed;
        } finally {
          _setLoading(false);
        }
      }, message: 'DELETING ACCOUNT');
    } on Object catch (e, st) {
      _error = ExceptionMapper.message(e);
      if (ExceptionMapper.shouldReportToCrashlytics(e)) {
        await CrashlyticsService.recordError(e, st, reason: 'delete_account');
      }
      return DeleteAccountResult.failed;
    }
  }

  Future<DeleteAccountResult> reauthenticateAndDeleteAccount() async {
    if (_auth == null) return DeleteAccountResult.failed;

    try {
      await LoadingController.instance.run(() async {
        switch (_mode) {
          case AuthMode.google:
            await _auth!.reauthenticateWithGoogle();
          case AuthMode.apple:
            await _auth!.reauthenticateWithApple();
          case AuthMode.guest:
          case AuthMode.none:
            break;
        }
      }, message: 'VERIFYING');
    } on Object catch (e, st) {
      final message = ExceptionMapper.message(e);
      if (message.toLowerCase().contains('cancelled')) {
        return DeleteAccountResult.cancelled;
      }
      _error = message;
      if (ExceptionMapper.shouldReportToCrashlytics(e)) {
        await CrashlyticsService.recordError(e, st, reason: 'reauth_delete');
      }
      notifyListeners();
      return DeleteAccountResult.failed;
    }

    return deleteAccount();
  }

  Future<void> signOut() async {
    await LoadingController.instance.run(() async {
      _setLoading(true);
      try {
        final id = uid;
        await _profileSub?.cancel();
        _profileSub = null;
        _watchingUid = null;
        try {
          await _auth?.signOut();
        } on Object catch (e, st) {
          _error = ExceptionMapper.message(e);
          if (ExceptionMapper.shouldReportToCrashlytics(e)) {
            await CrashlyticsService.recordError(e, st, reason: 'sign_out');
          }
        }
        if (id != null) {
          await _clearLocalSession(id);
        } else {
          await _resetSessionState();
        }
      } finally {
        _setLoading(false);
      }
    }, message: 'SIGNING OUT');
  }

  Future<void> refreshProfile() async {
    if (!await NetworkService.ensureOnline()) {
      _error = ExceptionMapper.message(const AppError.networkUnavailable());
      notifyListeners();
      return;
    }
    await LoadingController.instance.run(() async {
      await _loadProfile();
    }, message: 'SYNCING');
  }

  void updateProfileLocal(UserProfile profile) {
    _profile = profile;
    unawaited(_persistProfileCache());
    notifyListeners();
  }

  AuthMode _detectMode(User user) {
    if (user.isAnonymous) return AuthMode.guest;
    for (final provider in user.providerData) {
      if (provider.providerId == 'apple.com') return AuthMode.apple;
      if (provider.providerId == 'google.com') return AuthMode.google;
    }
    return AuthMode.google;
  }

  Future<void> _runAuthFlow({
    required String loadingMessage,
    required Future<void> Function() action,
    required String reason,
    required String fallbackMessage,
  }) async {
    if (_auth == null) {
      _error = 'Firebase not available';
      notifyListeners();
      return;
    }

    if (!await NetworkService.ensureOnline()) {
      _error = ExceptionMapper.message(const AppError.networkUnavailable());
      notifyListeners();
      return;
    }

    await LoadingController.instance.run(() async {
      _setLoading(true);
      _profileReady = false;
      notifyListeners();
      try {
        await action();
      } on Object catch (e, st) {
        _error = ExceptionMapper.message(e);
        if (_error == fallbackMessage && e is! FirebaseAuthException) {
          _error = ExceptionMapper.message(e);
        }
        if (ExceptionMapper.shouldReportToCrashlytics(e)) {
          await CrashlyticsService.recordError(e, st, reason: reason);
        }
      } finally {
        _setLoading(false);
      }
    }, message: loadingMessage);
  }

  Future<void> _bootstrapProfileAfterSignIn({required bool isGuest}) async {
    final id = _firebaseUser!.uid;
    final existing = await _userRepo.fetchProfile(id);
    if (existing != null) {
      _profile = existing;
      if (!isGuest) {
        await _userRepo.mergeAuthMetadata(
          uid: id,
          email: _firebaseUser!.email,
          photoUrl: _firebaseUser!.photoURL,
          displayName: _firebaseUser!.displayName ?? existing.displayName,
        );
      }
    } else {
      _profile = isGuest
          ? UserProfile.guest(id)
          : UserProfile(
              uid: id,
              username: '',
              displayName: _firebaseUser?.displayName ?? 'Player',
              email: _firebaseUser?.email,
              photoUrl: _firebaseUser?.photoURL,
              isGuest: false,
              createdAt: DateTime.now(),
            );
      await _userRepo.createOrUpdateProfile(_profile!);
    }
    await _persistProfileCache();
    _profileReady = true;
    await _completeOnboarding();
    _startProfileWatch();
  }

  void _startProfileWatch() {
    final id = uid;
    if (id == null) return;
    if (_watchingUid == id && _profileSub != null) return;
    _profileSub?.cancel();
    _watchingUid = id;
    _profileSub = _userRepo.watchProfile(id).listen((p) {
      if (p == null || !_profileMeaningfullyChanged(p)) return;
      _profile = p;
      unawaited(_persistProfileCache());
      notifyListeners();
    });
  }

  bool _profileMeaningfullyChanged(UserProfile next) {
    final cur = _profile;
    if (cur == null) return true;
    return cur.username != next.username ||
        cur.bestScore != next.bestScore ||
        cur.friendsCount != next.friendsCount ||
        cur.achievementsUnlocked != next.achievementsUnlocked ||
        cur.photoUrl != next.photoUrl;
  }

  Future<void> _clearLocalSession(String id) async {
    await StorageService.clearSessionForUser(id);
    FriendRepository.clearStreamCache();
    SocialController.instance.reset();
    await _resetSessionState();
  }

  Future<void> _resetSessionState() async {
    _firebaseUser = null;
    _profile = null;
    _profileReady = false;
    _mode = AuthMode.none;
    _onboardingComplete = false;
    _error = null;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    if (uid == null) return;
    if (!_profileReady) notifyListeners();

    final fetched = await _userRepo.fetchProfile(uid!);
    if (fetched != null) {
      _profile = fetched;
    } else {
      _profile ??= _firebaseUser!.isAnonymous
          ? UserProfile.guest(uid!)
          : UserProfile(
              uid: uid!,
              username: '',
              displayName: _firebaseUser!.displayName,
              email: _firebaseUser!.email,
              photoUrl: _firebaseUser!.photoURL,
            );
    }
    await _persistProfileCache();
    _profileReady = true;
    _startProfileWatch();
    notifyListeners();
  }

  Future<void> _persistProfileCache() async {
    final p = _profile;
    if (p == null || uid == null) return;
    await StorageService.cacheProfileJson(uid!, p.toCacheJson());
  }

  Future<void> _completeOnboarding() async {
    _onboardingComplete = true;
    await StorageService.saveOnboardingComplete(true);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    if (value) _error = null;
    notifyListeners();
  }
}
