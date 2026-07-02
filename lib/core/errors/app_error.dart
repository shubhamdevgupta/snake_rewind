enum AppErrorKind {
  networkUnavailable,
  timeout,
  serverUnavailable,
  authFailed,
  loginCancelled,
  permissionDenied,
  validation,
  unknown,
}

class AppError implements Exception {
  const AppError(this.message, {this.kind = AppErrorKind.unknown});

  const AppError.networkUnavailable()
      : message = 'No Internet Connection',
        kind = AppErrorKind.networkUnavailable;

  const AppError.timeout()
      : message = 'Request timed out. Please try again.',
        kind = AppErrorKind.timeout;

  const AppError.serverUnavailable()
      : message = 'Server is temporarily unavailable.',
        kind = AppErrorKind.serverUnavailable;

  const AppError.loginCancelled()
      : message = 'Login cancelled.',
        kind = AppErrorKind.loginCancelled;

  const AppError.permissionDenied()
      : message = 'You do not have permission to perform this action.',
        kind = AppErrorKind.permissionDenied;

  final String message;
  final AppErrorKind kind;

  @override
  String toString() => message;
}
