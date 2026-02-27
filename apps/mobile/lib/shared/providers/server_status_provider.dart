import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final serverStatusBaseUrlProvider = Provider<String>(
  (_) => 'https://api.clearbreath.life',
);

final serverStatusProvider = StreamProvider.autoDispose<bool>((ref) {
  final baseUrl = ref.watch(serverStatusBaseUrlProvider);
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
      sendTimeout: const Duration(seconds: 3),
      validateStatus: (_) => true,
    ),
  );

  final controller = StreamController<bool>();
  var disposed = false;

  Future<void> check() async {
    if (disposed) return;
    try {
      final response = await dio.get<void>('$baseUrl/ready');
      if (!disposed) controller.add(response.statusCode == 200);
    } catch (_) {
      if (!disposed) controller.add(false);
    }
  }

  check();
  final timer = Timer.periodic(const Duration(seconds: 15), (_) => check());

  ref.onDispose(() {
    disposed = true;
    timer.cancel();
    dio.close();
    controller.close();
  });

  return controller.stream.distinct();
});
