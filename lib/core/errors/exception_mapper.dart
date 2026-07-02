import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import 'app_error.dart';

abstract final class ExceptionMapper {
  static String message(Object error) {
    if (error is AppError) return error.message;

    if (error is FirebaseAuthException) {
      return _firebaseAuthMessage(error);
    }

    if (error is FirebaseException) {
      return _firebaseMessage(error);
    }

    if (error is SocketException) {
      return const AppError.networkUnavailable().message;
    }

    if (error is TimeoutException) {
      return const AppError.timeout().message;
    }

    if (error is StateError) {
      final text = error.message.toLowerCase();
      if (text.contains('cancelled') || text.contains('canceled')) {
        return const AppError.loginCancelled().message;
      }
    }

    if (error is UnsupportedError) {
      return error.message ?? 'This action is not supported on this device.';
    }

    return 'Something went wrong. Please try again.';
  }

  static bool shouldReportToCrashlytics(Object error) {
    if (error is AppError) {
      return switch (error.kind) {
        AppErrorKind.networkUnavailable ||
        AppErrorKind.timeout ||
        AppErrorKind.loginCancelled ||
        AppErrorKind.validation ||
        AppErrorKind.permissionDenied =>
          false,
        AppErrorKind.authFailed ||
        AppErrorKind.serverUnavailable ||
        AppErrorKind.unknown =>
          true,
      };
    }

    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'network-request-failed' ||
        'web-context-cancelled' ||
        'popup-closed-by-user' ||
        'cancelled-popup-request' ||
        'user-cancelled' =>
          false,
        _ => true,
      };
    }

    if (error is FirebaseException) {
      return switch (error.code) {
        'unavailable' || 'deadline-exceeded' || 'permission-denied' => false,
        _ => true,
      };
    }

    if (error is SocketException || error is TimeoutException) return false;
    if (error is StateError &&
        error.message.toLowerCase().contains('cancelled')) {
      return false;
    }

    return true;
  }

  static String _firebaseAuthMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'network-request-failed' =>
        'No Internet Connection. Please turn on Wi-Fi or Mobile Data.',
      'web-context-cancelled' ||
      'popup-closed-by-user' ||
      'cancelled-popup-request' ||
      'user-cancelled' =>
        'Login cancelled.',
      'invalid-credential' || 'wrong-password' || 'user-not-found' =>
        'Authentication failed. Please try again.',
      'email-already-in-use' => 'This account is already registered.',
      'too-many-requests' => 'Too many attempts. Please wait and try again.',
      'requires-recent-login' =>
        'For your security, please sign in again to continue.',
      'user-disabled' => 'This account has been disabled.',
      'operation-not-allowed' => 'This sign-in method is not enabled.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }

  static String _firebaseMessage(FirebaseException error) {
    return switch (error.code) {
      'unavailable' => 'Server is temporarily unavailable.',
      'deadline-exceeded' => 'Request timed out. Please try again.',
      'permission-denied' => 'You do not have permission to perform this action.',
      'not-found' => 'The requested data could not be found.',
      'failed-precondition' => 'Unable to complete this action right now.',
      'resource-exhausted' => 'Too many requests. Please try again later.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
