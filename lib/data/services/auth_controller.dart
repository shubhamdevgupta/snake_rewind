import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../game/services/storage_service.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
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
  String? _error;
  StreamSubscription<UserProfile?>? _profileSub;

  User? get firebaseUser => _firebaseUser;
  UserProfile? get profile => _profile;
  AuthMode get mode => _mode;
  bool get isLoading => _loading;
  bool get onboardingComplete => _onboardingComplete;
  String? get error => _error;
  String? get uid => _firebaseUser?.uid;
  bool get isSignedIn => _firebaseUser != null;

  bool get needsUsernameSetup =>
      isSignedIn && (_profile == null || !_profile!.hasValidUsername);

  Future<void> initialize() async {
    _onboardingComplete = await StorageService.loadOnboardingComplete();
    if (_auth != null) {
      _firebaseUser = _auth!.currentUser;
      if (_firebaseUser != null) {
        _mode = _firebaseUser!.isAnonymous ? AuthMode.guest : AuthMode.google;
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
    try {
      final cred = await _auth!.signInAsGuest();
      _firebaseUser = cred.user;
      _mode = AuthMode.guest;
      _profile = UserProfile.guest(_firebaseUser!.uid);
      await _userRepo.createOrUpdateProfile(_profile!);
      await _completeOnboarding();
      _watchProfile();
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
    try {
      final cred = await _auth!.signInWithGoogle();
      _firebaseUser = cred.user;
      _mode = AuthMode.google;
      _profile = UserProfile(
        uid: _firebaseUser!.uid,
        username: '',
        displayName: _firebaseUser?.displayName ?? 'Player',
        email: _firebaseUser?.email,
        photoUrl: _firebaseUser?.photoURL,
        isGuest: false,
        createdAt: DateTime.now(),
      );
      await _userRepo.createOrUpdateProfile(_profile!);
      await _completeOnboarding();
      _watchProfile();
    } on Object catch (e, st) {
      _error = 'Google sign-in failed';
      await CrashlyticsService.recordError(e, st, reason: 'google_auth');
    } finally {
      _setLoading(false);
    }
  }

  void _watchProfile() {
    _profileSub?.cancel();
    final id = uid;
    if (id == null) return;
    _profileSub = _userRepo.watchProfile(id).listen((p) {
      if (p != null) {
        _profile = p;
        notifyListeners();
      }
    });
  }

  Future<void> signOut() async {
    await _profileSub?.cancel();
    _profileSub = null;
    await _auth?.signOut();
    _firebaseUser = null;
    _profile = null;
    _mode = AuthMode.none;
    _onboardingComplete = false;
    await StorageService.saveOnboardingComplete(false);
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
  }

  void updateProfileLocal(UserProfile profile) {
    _profile = profile;
    notifyListeners();
    _watchProfile();
  }

  Future<void> _loadProfile() async {
    if (uid == null) return;
    _profile = await _userRepo.fetchProfile(uid!);
    _profile ??= _firebaseUser!.isAnonymous
        ? UserProfile.guest(uid!)
        : UserProfile(
            uid: uid!,
            username: '',
            displayName: _firebaseUser!.displayName,
            email: _firebaseUser!.email,
            photoUrl: _firebaseUser!.photoURL,
          );
    notifyListeners();
    _watchProfile();
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
