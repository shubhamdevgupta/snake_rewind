import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/startup/startup_theme.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'features/startup/startup_gate.dart';
import 'shared/widgets/global_loading_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    SystemChrome.setSystemUIOverlayStyle(StartupTheme.systemUi);
    ThemeManager.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    ThemeManager.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Rewinds',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.current,
      builder: (context, child) {
        return GlobalLoadingOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const StartupGate(),
    );
  }
}
