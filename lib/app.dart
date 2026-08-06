import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/config/router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'shared/providers/app_config_provider.dart';
import 'shared/providers/sync_providers.dart';

/// Root widget.
///
/// A [ConsumerWidget] so it can watch the theme mode: flipping dark mode
/// anywhere rebuilds only this widget, and `MaterialApp` animates between the
/// two themes rather than snapping.
///
/// It is deliberately thin — no business logic, no navigation rules. The
/// router owns routing, the notifiers own state; this is a composition root.
class PocketPilotApp extends ConsumerWidget {
  const PocketPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final GoRouter router = ref.watch(routerProvider);
    final ThemeMode themeMode = ref.watch(persistedThemeModeProvider);

    // Keeps the sync coordinator alive for the app's lifetime so it can react
    // to connectivity from any screen. Watching it here (rather than in a
    // feature screen) is what makes "sync when back online" work globally.
    ref.watch(syncCoordinatorProvider);

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: !config.isProd,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        // Clamp text scaling so extreme accessibility settings cannot break
        // the dense financial layouts, while still honouring user intent.
        final MediaQueryData mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
