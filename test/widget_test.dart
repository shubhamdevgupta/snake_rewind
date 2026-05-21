import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snake_game/core/theme/app_theme.dart';
import 'package:snake_game/core/theme/theme_manager.dart';
import 'package:snake_game/game/screens/home_screen.dart';
import 'package:snake_game/game/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await ThemeManager.instance.load();
  });

  testWidgets('Home screen shows title and play', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.current,
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('SNAKE'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });
}
