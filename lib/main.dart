import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_root.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'data/services/auth_controller.dart';
import 'game/services/audio_service.dart';
import 'game/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();
  await AudioService.init();
  await ThemeManager.instance.load();
  await FirebaseBootstrap.safeInit();
  await AuthController.instance.initialize();

  final settings = ThemeManager.instance.settings;
  AudioService.muted = !settings.soundEnabled;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SnakeApp());
}

class SnakeApp extends StatefulWidget {
  const SnakeApp({super.key});

  @override
  State<SnakeApp> createState() => _SnakeAppState();
}

class _SnakeAppState extends State<SnakeApp> {
  @override
  void initState() {
    super.initState();
    ThemeManager.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    ThemeManager.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Rewind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.current,
      home: const AppRoot(),
    );
  }
}
