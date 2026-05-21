import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'vibration_service.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  static bool get muted => instance._muted;
  static set muted(bool value) => instance._muted = value;

  bool _muted = false;
  bool _initialized = false;
  final AudioPlayer _sfx = AudioPlayer();
  final AudioPlayer _music = AudioPlayer();

  static Future<void> init() async {
    if (instance._initialized) return;
    instance._initialized = true;
    await instance._music.setReleaseMode(ReleaseMode.loop);
    await instance._music.setVolume(0.22);
  }

  static Future<void> setMuted(bool value) async {
    instance._muted = value;
    if (value) {
      await instance._music.stop();
    } else {
      await startMusic();
    }
  }

  static Future<void> playClick() async {
    if (instance._muted) return;
    await instance._play('audio/click.wav');
    VibrationService.selection();
  }

  static Future<void> playEat() async {
    if (instance._muted) return;
    await instance._play('audio/eat.wav');
  }

  static Future<void> playGameOver() async {
    if (instance._muted) return;
    await instance._play('audio/game_over.wav');
  }

  static Future<void> startMusic() async {
    if (instance._muted) return;
    try {
      await instance._music.play(AssetSource('audio/bg.wav'));
    } on Object catch (e) {
      debugPrint('Music: $e');
    }
  }

  static Future<void> stopMusic() async => instance._music.stop();

  Future<void> _play(String path) async {
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource(path));
    } on Object {
      try {
        await SystemSound.play(SystemSoundType.click);
      } on Object catch (_) {}
    }
  }

  static void dispose() {
    instance._sfx.dispose();
    instance._music.dispose();
  }
}
