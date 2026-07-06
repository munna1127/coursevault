// lib/services/connectivity_service.dart
//
// Thin wrapper around connectivity_plus that exposes a broadcast
// stream of "is currently online?" boolean values, plus a one-shot
// probe. Keeping this in one place isolates the rest of the app
// from the plugin API surface.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Broadcast stream that emits `true` when the device has at least
  /// one non-`none` connectivity result, and `false` otherwise.
  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .map(_hasConnection)
      .distinct();

  /// One-shot check — useful on app start.
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }
}
