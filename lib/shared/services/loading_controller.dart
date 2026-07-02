import 'package:flutter/foundation.dart';

/// Reference-counted global loading overlay controller.
abstract final class LoadingController extends ChangeNotifier {
  LoadingController._();

  static final LoadingController instance = _LoadingControllerImpl();

  bool get isLoading;
  String? get message;

  void show({String? message});
  void hide();

  Future<T> run<T>(
    Future<T> Function() action, {
    String? message,
  });
}

final class _LoadingControllerImpl extends LoadingController {
  _LoadingControllerImpl() : super._();

  int _depth = 0;
  String? _message;

  @override
  bool get isLoading => _depth > 0;

  @override
  String? get message => _message;

  @override
  void show({String? message}) {
    _depth++;
    if (message != null) _message = message;
    notifyListeners();
  }

  @override
  void hide() {
    if (_depth == 0) return;
    _depth--;
    if (_depth == 0) _message = null;
    notifyListeners();
  }

  @override
  Future<T> run<T>(
    Future<T> Function() action, {
    String? message,
  }) async {
    show(message: message);
    try {
      return await action();
    } finally {
      hide();
    }
  }
}
