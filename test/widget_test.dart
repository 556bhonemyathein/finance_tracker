import 'package:finance_tracker/app.dart';
import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/shared/providers/app_config_provider.dart';
import 'package:finance_tracker/shared/providers/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Boots the real app with a test config injected through the same provider
  /// override `main()` uses — no globals to reset between tests.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(AppConfig.dev)],
        child: const PocketPilotApp(),
      ),
    );
    // Entry animations (flutter_animate) schedule tickers; settle them so the
    // test does not finish with pending timers.
    await tester.pumpAndSettle();
  }

  testWidgets('renders the app shell with the branded title', (tester) async {
    await pumpApp(tester);

    expect(find.text('PocketPilot'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('theme toggle flips MaterialApp into dark mode', (tester) async {
    final container = ProviderContainer(
      overrides: [appConfigProvider.overrideWithValue(AppConfig.dev)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PocketPilotApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.system);

    container.read(themeModeProvider.notifier).toggle();
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}
