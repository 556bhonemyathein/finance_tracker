import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Answers one question: can we reach the network right now?
///
/// Exposed as a stream so the offline-first repositories can react the moment
/// connectivity returns and drain the pending-sync queue, and so the UI can
/// show an offline banner without polling.
class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Emits `true` when at least one non-`none` interface is available.
  ///
  /// Note this reports *reachability of an interface*, not of our API — a
  /// captive-portal Wi-Fi still reads as online. The Dio error mapper is the
  /// second line of defence for that case.
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_isOnline);

  Future<bool> get isOnline async =>
      _isOnline(await _connectivity.checkConnectivity());

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((ConnectivityResult r) => r != ConnectivityResult.none);
}
