import 'dart:async';
import 'dart:io';

import 'package:clearbreath/shared/providers/connection_status.dart';
import 'package:clearbreath/shared/providers/connection_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late ProviderContainer container;
  late StreamController<bool> connectivityController;

  setUp(() {
    connectivityController = StreamController<bool>();
  });

  tearDown(() async {
    container.dispose();
    connectivityController.close();
    await server.close(force: true);
  });

  Future<ProviderContainer> startServer(int statusCode) async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) {
      request.response
        ..statusCode = statusCode
        ..close();
    });

    final url = 'http://127.0.0.1:${server.port}';
    container = ProviderContainer(
      overrides: [
        serverStatusBaseUrlProvider.overrideWithValue(url),
        connectivityProvider.overrideWith(
          (ref) => connectivityController.stream,
        ),
      ],
    );
    return container;
  }

  test('device offline emits userOffline with hasInternet: false', () async {
    final c = await startServer(200);
    final completer = Completer<AppConnectionState>();

    c.listen(connectionStatusProvider, (prev, next) {
      final state = next.asData?.value;
      if (state != null && !completer.isCompleted) {
        completer.complete(state);
      }
    });

    connectivityController.add(false);

    final state = await completer.future.timeout(const Duration(seconds: 2));
    expect(state.status, ConnectionStatus.userOffline);
    expect(state.hasInternet, isFalse);
  });

  test('device online + server 200 emits online', () async {
    final c = await startServer(200);
    final completer = Completer<AppConnectionState>();

    c.listen(connectionStatusProvider, (prev, next) {
      final state = next.asData?.value;
      if (state != null &&
          state.status == ConnectionStatus.online &&
          !completer.isCompleted) {
        completer.complete(state);
      }
    });

    connectivityController.add(true);

    final state = await completer.future.timeout(const Duration(seconds: 2));
    expect(state.status, ConnectionStatus.online);
    expect(state.hasInternet, isTrue);
    expect(state.serverReachable, isTrue);
  });

  test('device online + server 503 emits serverDown', () async {
    final c = await startServer(503);
    final completer = Completer<AppConnectionState>();

    c.listen(connectionStatusProvider, (prev, next) {
      final state = next.asData?.value;
      if (state != null &&
          state.status != ConnectionStatus.checking &&
          !completer.isCompleted) {
        completer.complete(state);
      }
    });

    connectivityController.add(true);

    final state = await completer.future.timeout(const Duration(seconds: 2));
    expect(state.status, ConnectionStatus.serverDown);
    expect(state.hasInternet, isTrue);
    expect(state.serverReachable, isFalse);
  });

  test('offline to online transition triggers server check', () async {
    final c = await startServer(200);
    final states = <AppConnectionState>[];
    final gotOnline = Completer<void>();

    c.listen(connectionStatusProvider, (prev, next) {
      final state = next.asData?.value;
      if (state != null) {
        states.add(state);
        if (state.status == ConnectionStatus.online && !gotOnline.isCompleted) {
          gotOnline.complete();
        }
      }
    });

    // First go offline
    connectivityController.add(false);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Then go online — should trigger server check
    connectivityController.add(true);
    await gotOnline.future.timeout(const Duration(seconds: 2));

    expect(states.any((s) => s.status == ConnectionStatus.userOffline), isTrue);
    expect(states.any((s) => s.status == ConnectionStatus.online), isTrue);
  });
}
