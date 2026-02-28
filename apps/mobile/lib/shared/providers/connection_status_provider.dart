import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import 'connection_status.dart';

final serverStatusBaseUrlProvider = Provider<String>(
  (_) => AppConfig.apiBaseUrl,
);

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );
});

final connectionStatusProvider = StreamProvider.autoDispose<AppConnectionState>(
  (ref) {
    final baseUrl = ref.watch(serverStatusBaseUrlProvider);
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        sendTimeout: const Duration(seconds: 3),
        validateStatus: (_) => true,
      ),
    );

    final controller = StreamController<AppConnectionState>();
    var disposed = false;
    Timer? pollTimer;
    DateTime? lastChecked;
    bool? lastKnownConnectivity;

    void emit(
      ConnectionStatus status, {
      bool? hasInternet,
      bool? serverReachable,
    }) {
      if (disposed) return;
      controller.add(
        AppConnectionState(
          status: status,
          hasInternet: hasInternet,
          serverReachable: serverReachable,
          lastCheckedAt: lastChecked,
        ),
      );
    }

    Future<void> checkServer() async {
      if (disposed) return;
      final hasInternet = lastKnownConnectivity;

      if (hasInternet == false) {
        lastChecked = DateTime.now();
        emit(ConnectionStatus.userOffline, hasInternet: false);
        return;
      }

      try {
        final response = await dio.get<void>('$baseUrl/ready');
        lastChecked = DateTime.now();
        if (disposed) return;
        final ok = response.statusCode == 200;
        emit(
          ok ? ConnectionStatus.online : ConnectionStatus.serverDown,
          hasInternet: hasInternet ?? true,
          serverReachable: ok,
        );
      } catch (_) {
        lastChecked = DateTime.now();
        if (disposed) return;
        emit(
          ConnectionStatus.serverDown,
          hasInternet: hasInternet ?? true,
          serverReachable: false,
        );
      }
    }

    void restartPolling() {
      pollTimer?.cancel();
      checkServer();
      if (lastKnownConnectivity != false) {
        pollTimer = Timer.periodic(
          const Duration(seconds: 15),
          (_) => checkServer(),
        );
      }
    }

    ref.listen(connectivityProvider, (prev, next) {
      final value = next.asData?.value;
      if (value == null) return;
      lastKnownConnectivity = value;
      restartPolling();
    });

    ref.onDispose(() {
      disposed = true;
      pollTimer?.cancel();
      dio.close();
      controller.close();
    });

    return controller.stream;
  },
);
