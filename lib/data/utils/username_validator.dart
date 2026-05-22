class UsernameValidation {
  const UsernameValidation({
    required this.isValid,
    required this.message,
    this.normalized,
  });

  final bool isValid;
  final String message;
  final String? normalized;
}

class UsernameValidator {
  static final RegExp _pattern = RegExp(r'^[a-z0-9_]{3,20}$');

  static UsernameValidation validate(String input) {
    final raw = input.trim();
    if (raw.startsWith('@')) {
      return validate(raw.substring(1));
    }

    final normalized = raw.toLowerCase();
    if (normalized.isEmpty) {
      return const UsernameValidation(
        isValid: false,
        message: 'Enter a username',
      );
    }
    if (normalized.length < 3) {
      return const UsernameValidation(
        isValid: false,
        message: 'At least 3 characters',
      );
    }
    if (normalized.length > 20) {
      return const UsernameValidation(
        isValid: false,
        message: 'Max 20 characters',
      );
    }
    if (normalized.contains(' ')) {
      return const UsernameValidation(
        isValid: false,
        message: 'No spaces allowed',
      );
    }
    if (!_pattern.hasMatch(normalized)) {
      return const UsernameValidation(
        isValid: false,
        message: 'Lowercase letters, numbers, underscore only',
      );
    }
    return UsernameValidation(
      isValid: true,
      message: 'Username available',
      normalized: normalized,
    );
  }

  static String normalize(String input) {
    final raw = input.trim();
    if (raw.startsWith('@')) return raw.substring(1).toLowerCase();
    return raw.toLowerCase();
  }

  static bool isValidFormat(String username) => _pattern.hasMatch(username);

  static String prefixEnd(String prefix) => '$prefix\uf8ff';

  static String display(String username) => '@$username';

  static bool isPlaceholder(String username, String uid) {
    if (username.startsWith('Guest_')) return true;
    if (username == 'Player') return true;
    return false;
  }
}
