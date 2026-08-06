import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/isar_service.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/storage/secure_storage_service.dart';
import 'app_config_provider.dart';

/// Infrastructure providers.
///
/// [isarServiceProvider] and [preferencesServiceProvider] are *unimplemented*
/// on purpose: both require `await` during boot, and a provider that returns a
/// half-built database is worse than one that refuses to exist. `main()`
/// resolves them and overrides them, which is the standard Riverpod recipe for
/// async-initialised singletons.
final isarServiceProvider = Provider<IsarService>(
  (Ref ref) => throw UnimplementedError(
    'isarServiceProvider must be overridden in main()',
  ),
  name: 'isarService',
);

final preferencesServiceProvider = Provider<PreferencesService>(
  (Ref ref) => throw UnimplementedError(
    'preferencesServiceProvider must be overridden in main()',
  ),
  name: 'preferences',
);

final secureStorageProvider = Provider<SecureStorageService>(
  (Ref ref) => SecureStorageService(),
  name: 'secureStorage',
);

final connectivityServiceProvider = Provider<ConnectivityService>(
  (Ref ref) => ConnectivityService(),
  name: 'connectivity',
);

/// Live connectivity as a stream — the offline banner and the sync engine both
/// watch this. A `StreamProvider` is exactly right here: the source is a
/// push-based stream and Riverpod handles the subscription lifecycle.
final connectivityStreamProvider = StreamProvider<bool>((Ref ref) async* {
  final ConnectivityService service = ref.watch(connectivityServiceProvider);
  // Seed with the current value so listeners do not sit in `loading` until the
  // first interface change.
  yield await service.isOnline;
  yield* service.onStatusChange;
}, name: 'connectivityStream');

/// Convenience: `true` when we believe we can reach the network.
/// Defaults to online while the first check is in flight, so a cold start
/// never renders an incorrect "offline" banner.
final isOnlineProvider = Provider<bool>(
  (Ref ref) => ref.watch(connectivityStreamProvider).value ?? true,
  name: 'isOnline',
);

/// The configured HTTP client.
///
/// `onSessionExpired` is injected as a callback rather than as a provider
/// dependency to avoid a cycle: the auth notifier depends on Dio, so Dio
/// cannot depend on the auth notifier.
final dioProvider = Provider<Dio>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  final client = DioClient(
    config: config,
    storage: ref.watch(secureStorageProvider),
    onSessionExpired: () async {
      ref.read(sessionExpiredProvider.notifier).expire();
    },
  );
  ref.onDispose(client.dio.close);
  return client.dio;
}, name: 'dio');

/// Flipped by the auth interceptor when a token refresh definitively fails.
/// The router watches it and bounces the user back to the login screen.
///
/// Riverpod 3 moved `StateProvider` to the legacy library; a two-line
/// [Notifier] is the modern equivalent and gives the transitions names.
class SessionExpiredNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void expire() => state = true;

  void acknowledge() => state = false;
}

final sessionExpiredProvider =
    NotifierProvider<SessionExpiredNotifier, bool>(
      SessionExpiredNotifier.new,
      name: 'sessionExpired',
    );
