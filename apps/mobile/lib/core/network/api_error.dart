import 'package:dio/dio.dart';

class ApiError implements Exception {
  const ApiError({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.requestId,
  });

  factory ApiError.fromDioException(DioException error) {
    final response = error.response;
    if (response == null) {
      return ApiError(
        statusCode: null,
        code: 'network_error',
        message: error.message ?? 'Network error',
        requestId: null,
      );
    }

    final parsed = _parseEnvelope(response);
    return ApiError(
      statusCode: response.statusCode,
      code: parsed.code ?? 'http_${response.statusCode ?? 0}',
      message: parsed.message ?? 'Request failed',
      requestId: parsed.requestId,
    );
  }

  final int? statusCode;
  final String code;
  final String message;
  final String? requestId;

  bool get isUnauthorized => statusCode == 401;
  bool get isRateLimited => statusCode == 429;
  bool get isRefreshReplay => statusCode == 409 && code == 'refresh_replay';

  @override
  String toString() {
    final status = statusCode == null ? '' : ' ($statusCode)';
    final rid = requestId == null ? '' : ' [$requestId]';
    return 'ApiError$status $code$rid: $message';
  }
}

({String? code, String? message, String? requestId}) _parseEnvelope(
  Response<dynamic> response,
) {
  final data = response.data;
  if (data is Map) {
    final map = data.cast<String, dynamic>();
    final message = map['error'];
    final code = map['code'];
    final requestId = map['request_id'];
    return (
      code: code is String ? code : null,
      message: message is String ? message : null,
      requestId: requestId is String ? requestId : null,
    );
  }
  return (code: null, message: null, requestId: null);
}
