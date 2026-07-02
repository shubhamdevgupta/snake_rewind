import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInAsGuest() => _auth.signInAnonymously();

  Future<UserCredential> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw StateError('Google sign-in cancelled');
    }
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }
  Future<UserCredential> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw UnsupportedError('Sign in with Apple is only supported on Apple platforms');
    }

    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final idToken = appleCredential.identityToken;
    if (idToken == null) {
      throw StateError('Apple Sign-In failed: missing identity token');
    }

    // Use AppleAuthProvider (native Apple credential path), not OAuthProvider.
    // OAuthProvider("apple.com") routes through signInMethod "oauth", which since
    // firebase_auth 5.2.0 requires accessToken (authorizationCode) and throws
    // invalid-credential when it is omitted.
    final oauthCredential = AppleAuthProvider.credentialWithIDToken(
      idToken,
      rawNonce,
      AppleFullPersonName(
        givenName: appleCredential.givenName,
        familyName: appleCredential.familyName,
      ),
    );

    return _auth.signInWithCredential(oauthCredential);
  }
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

    final random = Random.secure();

    return List.generate(
      length,
          (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signOut() async {
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
    await _googleSignIn.disconnect();
    await _auth.signOut();
  }

  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    await user.delete();
  }

  Future<void> reauthenticateWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw StateError('Google sign-in cancelled');
    }
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> reauthenticateWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw UnsupportedError('Sign in with Apple is only supported on Apple platforms');
    }

    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
      nonce: nonce,
    );
    final idToken = appleCredential.identityToken;
    if (idToken == null) {
      throw StateError('Apple Sign-In failed: missing identity token');
    }
    final credential = AppleAuthProvider.credentialWithIDToken(
      idToken,
      rawNonce,
      AppleFullPersonName(
        givenName: appleCredential.givenName,
        familyName: appleCredential.familyName,
      ),
    );
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    await user.reauthenticateWithCredential(credential);
  }
}
