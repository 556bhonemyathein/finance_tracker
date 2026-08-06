import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/sync_service.dart';
import '../../core/utils/app_logger.dart';
import '../../features/transactions/presentation/providers/transaction_providers.dart';
import 'app_config_provider.dart';
import 'core_providers.dart';

final syncServiceProvider = Provider<SyncService>(
  (Ref ref) => SyncService(
    transactions: ref.watch(transactionRepositoryProvider),
    preferences: ref.watch(preferencesServiceProvider),
    dio: ref.watch(dioProvider),
    config: ref.watch(appConfigProvider),
  ),
  name: 'syncService',
);

/// Drives sync from connectivity changes.
///
/// This is a *listener* provider: nothing reads its value, it exists for the
/// side effect. `ref.listen` inside `build` is how Riverpod models "when X
/// changes, do Y" without a widget having to own the subscription — and
/// because the app shell keeps it alive, it works on every screen.
class SyncCoordinator extends Notifier<SyncReport> {
  @override
  SyncReport build() {
    ref.listen<bool>(isOnlineProvider, (bool? wasOnline, bool isOnline) {
      // Only on the offline → online edge; re-running while already online
      // would sync on every unrelated interface change.
      if (wasOnline == false && isOnline) {
        AppLogger.i('Connectivity restored — draining sync queue');
        syncNow();
      }
    });
    return SyncReport.idle;
  }

  Future<SyncReport> syncNow() async {
    final SyncReport report = await ref.read(syncServiceProvider).sync();
    state = report;
    return report;
  }

  DateTime? get lastSyncAt => ref.read(syncServiceProvider).lastSyncAt;
}

final syncCoordinatorProvider =
    NotifierProvider<SyncCoordinator, SyncReport>(
      SyncCoordinator.new,
      name: 'syncCoordinator',
    );

/// Count of rows still waiting to be pushed — rendered as a badge in settings.
final pendingSyncCountProvider = FutureProvider<int>((Ref ref) async {
  // Re-runs whenever a sync completes, so the badge self-corrects.
  ref.watch(syncCoordinatorProvider);
  final result = await ref.watch(transactionRepositoryProvider).pendingSync();
  return result.dataOrNull?.length ?? 0;
}, name: 'pendingSyncCount');
