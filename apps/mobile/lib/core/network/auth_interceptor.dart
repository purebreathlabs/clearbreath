import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/token_storage.dart';
import '../../features/auth/domain/auth_refresh_coordinator.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.ref, required this.dio, required this.tokens});

  final Ref ref;
  final Dio dio;
  final TokenStorage tokens;

  static const _kRetriedKey = 'auth.retried';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final access = await tokens.readAccessToken();
      if (access != null) {
        options.headers.putIfAbsent('Authorization', () => 'Bearer $access');
      }
    } catch (_) {}
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final request = err.requestOptions;

    if (response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final alreadyRetried = request.extra[_kRetriedKey] == true;
    if (alreadyRetried) {
      handler.next(err);
      return;
    }

    if (_isAuthPath(request.path)) {
      handler.next(err);
      return;
    }

    try {
      final outcome = await ref
          .read(authRefreshCoordinatorProvider)
          .refreshIfPossible();
      if (outcome == null) {
        handler.next(err);
        return;
      }

      request.extra[_kRetriedKey] = true;
      request.headers['Authorization'] = 'Bearer ${outcome.tokens.accessToken}';
      final retried = await dio.fetch<dynamic>(request);
      handler.resolve(retried);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _isAuthPath(String path) {
    if (path.contains('/v1/auth/refresh')) {
      return true;
    }
    if (path.contains('/v1/auth/provider_sign_in')) {
      return true;
    }
    return false;
  }
}
