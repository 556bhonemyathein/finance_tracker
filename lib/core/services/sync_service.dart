import 'dart:async';

import 'package:dio/dio.dart';

import '../../features/transactions/domain/transaction_repository.dart';
import '../../shared/models/enums.dart';
import '../../shared/models/transaction.dart';
import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../errors/app_exception.dart';
import '../storage/preferences_service.dart';
import '../utils/app_logger.dart';

/// Outcome of one sync pass, surfaced to the settings screen.
class SyncReport {
  const SyncReport({
    required this.pushed,
    required this.failed,
    required this.skipped,
    this.error,
  });

  final int pushed;
  final int failed;
  final int skipped;
  final String? error;

  bool get isSuccess => error == null && failed == 0;

  static const SyncReport idle = SyncReport(pushed: 0, failed: 0, skipped: 0);
}

/// Pushes locally-pending rows to the server.
///
/// The contract with the repositories is deliberately narrow: they own *what*
/// is pending, this owns *when* and *how* it is sent. That split is why the
/// repositories stay testable without a network and why retry policy lives in
/// one place.
///
/// Idempotency is the important property here — every row carries a
/// client-generated UUID, so replaying a push after a dropped response updates
/// the existing row instead of creating a duplicate.
class SyncService {
  SyncService({
    required TransactionRepository transactions,
    required PreferencesService preferences,
    required Dio dio,
    required AppConfig config,
  }) : _transactions = transactions,
       _prefs = preferences,
       _dio = dio,
       _config = config;

  final TransactionRepository _transactions;
  final PreferencesService _prefs;
  final Dio _dio;
  final AppConfig _config;

  /// Guards against two passes overlapping (e.g. a manual sync landing while
  /// the connectivity-triggered one is still running).
  Future<SyncReport>? _inFlight;

  Future<SyncReport> sync() {
    return _inFlight ??= _sync().whenComplete(() => _inFlight = null);
  }

  Future<SyncReport> _sync() async {
    final pending = await _transactions.pendingSync();
    final List<Transaction>? rows = pending.dataOrNull;

    if (rows == null) {
      return SyncReport(
        pushed: 0,
        failed: 0,
        skipped: 0,
        error: pending.failureOrNull?.message,
      );
    }
    if (rows.isEmpty) {
      await _prefs.setLastSyncAt(DateTime.now());
      return SyncReport.idle;
    }

    // With no server to talk to, the local backend marks everything as
    // reconciled: the device *is* the source of truth in that mode.
    if (_config.useLocalBackend) {
      await _transactions.markSynced(rows.map((Transaction t) => t.id));
      await _prefs.setLastSyncAt(DateTime.now());
      AppLogger.i('Local backend: reconciled ${rows.length} rows');
      return SyncReport(pushed: rows.length, failed: 0, skipped: 0);
    }

    final List<String> succeeded = <String>[];
    var failed = 0;

    for (final Transaction row in rows) {
      try {
        await _push(row);
        succeeded.add(row.id);
      } on AppException catch (error) {
        // One bad row must not stall the queue behind it.
        AppLogger.w('Sync failed for ${row.id}: ${error.message}');
        failed++;
      }
    }

    if (succeeded.isNotEmpty) await _transactions.markSynced(succeeded);
    await _prefs.setLastSyncAt(DateTime.now());

    AppLogger.i('Sync complete: ${succeeded.length} pushed, $failed failed');
    return SyncReport(pushed: succeeded.length, failed: failed, skipped: 0);
  }

  Future<void> _push(Transaction row) async {
    switch (row.syncStatus) {
      case SyncStatus.pendingCreate:
        await _dio.post<void>(ApiEndpoints.transactions, data: row.toJson());
      case SyncStatus.pendingUpdate:
        await _dio.put<void>(
          ApiEndpoints.transaction(row.id),
          data: row.toJson(),
        );
      case SyncStatus.pendingDelete:
        await _dio.delete<void>(ApiEndpoints.transaction(row.id));
      case SyncStatus.synced:
        break;
    }
  }

  DateTime? get lastSyncAt => _prefs.lastSyncAt;
}
