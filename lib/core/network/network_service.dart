import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../errors/app_error.dart';

abstract final class NetworkService {
  static final Connectivity _connectivity = Connectivity();
  static List<ConnectivityResult> _lastResult = [ConnectivityResult.none];

  static Future<void> init() async {
    _lastResult = await _connectivity.checkConnectivity();
    _connectivity.onConnectivityChanged.listen((result) {
      _lastResult = result;
    });
  }

  static bool get hasConnectivity {
    return !_lastResult.contains(ConnectivityResult.none) &&
        _lastResult.isNotEmpty;
  }

  static Future<bool> hasConnection() async {
    _lastResult = await _connectivity.checkConnectivity();
    if (!hasConnectivity) return false;

    try {
      final result = await InternetAddress.lookup('firebase.google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on Object {
      return hasConnectivity;
    }
  }

  static Future<bool> ensureOnline() async {
    final online = await hasConnection();
    if (!online) {
      if (kDebugMode) {
        debugPrint('NetworkService: offline — blocking remote call');
      }
    }
    return online;
  }

  static Future<void> requireOnline() async {
    if (!await hasConnection()) {
      throw const AppError.networkUnavailable();
    }
  }
}
