import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/utils/app_logger.dart';
import 'shared/providers/app_config_provider.dart';

/// Composition root.
///
/// Responsibilities, in order:
///   1. resolve the build flavor,
///   2. initialise anything that must exist before the first frame,
///   3. install the Riverpod [ProviderScope] with the resolved overrides,
///   4. install global error handlers.
///
/// Nothing else in the app calls `WidgetsFlutterBinding` or reads `dart-define`
/// values — those concerns live here and here only.
Future<void> main() async {
  // `runZonedGuarded` catches errors thrown outside the Flutter framework
  // (async gaps, isolate callbacks) that `FlutterError.onError` would miss.
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final AppConfig config = AppConfig.fromEnvironment();
      AppLogger.configure(enabled: config.enableLogging);
      AppLogger.i('Booting ${config.appName} (${config.flavor.label})');

      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );

      FlutterError.onError = (FlutterErrorDetails details) {
        AppLogger.e('FlutterError', details.exception, details.stack);
        FlutterError.presentError(details);
        // TODO(crashlytics): forward via recordFlutterError once Firebase lands.
      };

      runApp(
        ProviderScope(
          // Dependency injection: the whole graph reads configuration through
          // `appConfigProvider`, and this is the single place it is bound.
          overrides: [appConfigProvider.overrideWithValue(config)],
          observers: config.enableLogging
              ? <ProviderObserver>[_LoggingProviderObserver()]
              : const <ProviderObserver>[],
          child: const PocketPilotApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      AppLogger.e('Uncaught zone error', error, stack);
      // TODO(crashlytics): forward via recordError once Firebase lands.
    },
  );
}

/// Logs provider lifecycle in debug builds.
///
/// A [ProviderObserver] is the cheapest window into Riverpod state: it shows
/// which provider changed, when, and to what — without adding a single print
/// statement to feature code.
final class _LoggingProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    AppLogger.d(
      '[riverpod] ${context.provider.name ?? context.provider.runtimeType} '
      '=> $newValue',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    AppLogger.e(
      '[riverpod] ${context.provider.name ?? context.provider.runtimeType} '
      'failed',
      error,
      stackTrace,
    );
  }
}
