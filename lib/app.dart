import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'dev/design_system_preview.dart';
import 'shared/providers/app_config_provider.dart';
import 'shared/providers/theme_mode_provider.dart';

/// Root widget.
///
/// [PocketPilotApp] is a [ConsumerWidget] rather than a `StatelessWidget` so it
/// can `watch` the theme mode: when the user flips dark mode anywhere in the
/// app, only this widget rebuilds and `MaterialApp` animates between themes.
///
/// It is deliberately thin — no business logic, no navigation rules. The
/// router is injected in the next step; the app shell stays a composition root.
class PocketPilotApp extends ConsumerWidget {
  const PocketPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: !config.isProd,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // TODO(router): replace with `MaterialApp.router` + goRouterProvider.
      home: const DesignSystemPreview(),
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
