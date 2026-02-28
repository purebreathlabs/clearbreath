import 'package:flutter/foundation.dart';

enum ConnectionStatus {
  checking,
  userOffline,
  serverDown,
  online,
}

@immutable
class AppConnectionState {
  const AppConnectionState({
    required this.status,
    required this.hasInternet,
    required this.serverReachable,
    required this.lastCheckedAt,
  });

  const AppConnectionState.initial()
      : status = ConnectionStatus.checking,
        hasInternet = null,
        serverReachable = null,
        lastCheckedAt = null;

  final ConnectionStatus status;
  final bool? hasInternet;
  final bool? serverReachable;
  final DateTime? lastCheckedAt;
}
