import 'package:flutter/services.dart';

abstract final class VibrationService {
  static void light() => HapticFeedback.lightImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void heavy() => HapticFeedback.heavyImpact();
}
