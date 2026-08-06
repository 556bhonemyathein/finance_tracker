import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/storage/isar_service.dart';
import 'core/storage/preferences_service.dart';
import 'core/utils/app_logger.dart';
import 'features/categories/presentation/providers/category_providers.dart';
import 'features/transactions/presentation/providers/transaction_providers.dart';
import 'shared/providers/app_config_provider.dart';
import 'shared/providers/core_providers.dart';

/// Composition root.
///
/// Responsibilities, in order:
///   1. resolve the build flavor,
///   2. open the async singletons (Isar, preferences) that must exist before
///      the first frame,
///   3. install the Riverpod [ProviderScope] with those bound as overrides,
///   4. run first-launch work (seed categories, materialise recurring rows),
///   5. install global error handlers.
///
/// Nothing else in the app calls `WidgetsFlutterBinding`, opens a database, or
/// reads `dart-define` values — those concerns live here and only here.
Future<void> main() async {
  // `runZonedGuarded` catches errors thrown outside the Flutter framework
  // (async gaps, isolate callbacks) that `FlutterError.onError` would miss.
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final AppConfig config = AppConfig.fromEnvironment();
      AppLogger.configure(enabled: config.enableLogging);
      AppLogger.i('Booting ${config.appName} (${config.flavor.label})');

      // Both are awaited before `runApp` so no provider ever has to represent
      // a half-initialised database.
      final IsarService isar = await IsarService.open();
      final PreferencesService preferences = await PreferencesService.create();

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

      // Dependency injection: the whole graph reads infrastructure through
      // these providers, and this is the single place they are bound.
      final ProviderContainer container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          isarServiceProvider.overrideWithValue(isar),
          preferencesServiceProvider.overrideWithValue(preferences),
        ],
        observers: config.enableLogging
            ? <ProviderObserver>[_LoggingProviderObserver()]
            : const <ProviderObserver>[],
      );

      await _runStartupTasks(container);

      runApp(
        UncontrolledProviderScope(
          container: container,
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

/// One-time work that must happen before the first frame.
///
/// Failures here are logged but never fatal: a user with a broken recurring
/// rule should still get an app they can open.
Future<void> _runStartupTasks(ProviderContainer container) async {
  try {
    // Without categories the app is unusable — nothing can be recorded.
    await container.read(categoryRepositoryProvider).seedDefaultsIfEmpty();

    // Catch up on any recurring transactions that fell due while closed.
    await container.read(transactionRepositoryProvider).materialiseRecurring();
  } catch (error, stackTrace) {
    AppLogger.e('Startup task failed', error, stackTrace);
  }
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
