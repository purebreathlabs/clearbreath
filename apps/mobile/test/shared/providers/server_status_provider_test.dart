import 'dart:async';
import 'dart:io';

import 'package:clearbreath/shared/providers/connection_status_provider.dart';
import 'package:clearbreath/shared/providers/server_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late ProviderContainer container;

  tearDown(() async {
    container.dispose();
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
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
    return container;
  }

  test('emits true when /ready returns 200', () async {
    final c = await startServer(200);
    final completer = Completer<bool>();
    c.listen(serverStatusProvider, (prev, next) {
      if (next is AsyncData<bool> && !completer.isCompleted) {
        completer.complete(next.value);
      }
    });
    final value = await completer.future;
    expect(value, isTrue);
  });

  test('emits false when /ready returns 503', () async {
    final c = await startServer(503);
    final completer = Completer<bool>();
    c.listen(serverStatusProvider, (prev, next) {
      if (next is AsyncData<bool> && !completer.isCompleted) {
        completer.complete(next.value);
      }
    });
    final value = await completer.future;
    expect(value, isFalse);
  });
}
