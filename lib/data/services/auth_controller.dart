import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../game/services/storage_service.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import '../repositories/friend_repository.dart';
import '../repositories/user_repository.dart';
import '../../core/firebase/firebase_bootstrap.dart';
import '../services/crashlytics_service.dart';

enum AuthMode { none, guest, google }

class AuthController extends ChangeNotifier {
  AuthController._();
  static final AuthController instance = AuthController._();

  AuthRepository? _authRepo;
  final UserRepository _userRepo = UserRepository();

  AuthRepository? get _auth => FirebaseBootstrap.initialized
      ? (_authRepo ??= AuthRepository())
      : null;

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
  bool get isLoading => _loading;
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

  Future<void> initialize() async {
    _onboardingComplete = await StorageService.loadOnboardingComplete();
    if (_auth != null) {
      _firebaseUser = _auth!.currentUser;
      if (_firebaseUser != null) {
        _mode = _firebaseUser!.isAnonymous ? AuthMode.guest : AuthMode.google;
        final cached = await _userRepo.loadCachedProfile(_firebaseUser!.uid);
        if (cached != null) {
          _profile = cached;
          _profileReady = true;
          notifyListeners();
        }
        await _loadProfile();
      }
    }
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    if (_auth == null) {
      _error = 'Firebase not available';
      notifyListeners();
      return;
    }
    _setLoading(true);
    _profileReady = false;
    try {
      final cred = await _auth!.signInAsGuest();
      _firebaseUser = cred.user;
      _mode = AuthMode.guest;
      final existing = await _userRepo.fetchProfile(_firebaseUser!.uid);
      if (existing != null) {
        _profile = existing;
      } else {
        _profile = UserProfile.guest(_firebaseUser!.uid);
        await _userRepo.createOrUpdateProfile(_profile!);
      }
      await _persistProfileCache();
      _profileReady = true;
      await _completeOnboarding();
      _startProfileWatch();
    } on Object catch (e, st) {
      _error = 'Guest sign-in failed';
      await CrashlyticsService.recordError(e, st, reason: 'guest_auth');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    if (_auth == null) {
      _error = 'Firebase not available';
      notifyListeners();
      return;
    }
    _setLoading(true);
    _profileReady = false;
    notifyListeners();
    try {
      final cred = await _auth!.signInWithGoogle();
      _firebaseUser = cred.user;
      _mode = AuthMode.google;
      final id = _firebaseUser!.uid;

      final existing = await _userRepo.fetchProfile(id);
      if (existing != null) {
        _profile = existing;
        await _userRepo.mergeAuthMetadata(
          uid: id,
          email: _firebaseUser!.email,
          photoUrl: _firebaseUser!.photoURL,
          displayName: _firebaseUser!.displayName ?? existing.displayName,
        );
      } else {
        _profile = UserProfile(
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
    } on Object catch (e, st) {
      _error = 'Google sign-in failed';
      await CrashlyticsService.recordError(e, st, reason: 'google_auth');
    } finally {
      _setLoading(false);
    }
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

  Future<void> signOut() async {
    final id = uid;
    await _profileSub?.cancel();
    _profileSub = null;
    _watchingUid = null;
    await _auth?.signOut();
    _firebaseUser = null;
    _profile = null;
    _profileReady = false;
    _mode = AuthMode.none;
    _onboardingComplete = false;
    if (id != null) await StorageService.clearCachedProfile(id);
    FriendRepository.clearStreamCache();
    await StorageService.saveOnboardingComplete(false);
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
  }

  void updateProfileLocal(UserProfile profile) {
    _profile = profile;
    unawaited(_persistProfileCache());
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
    _error = null;
    notifyListeners();
  }
}
