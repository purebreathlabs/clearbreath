import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/models/safety_models.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../domain/safety_acknowledgement_repository.dart';

final safetySyncServiceProvider = Provider<SafetySyncService>((ref) {
  final dio = ref.watch(apiClientProvider);
  final local = ref.watch(safetyAckRepositoryProvider);
  return SafetySyncService(ref: ref, dio: dio, local: local);
});

class SafetySyncService {
  SafetySyncService({required this.ref, required Dio dio, required this.local})
    : _dio = dio;

  final Ref ref;
  final Dio _dio;
  final SafetyAcknowledgementRepository local;

  Future<void> pullAndMerge() async {
    final auth = ref.read(authStateProvider);
    if (auth is! AuthStateSignedIn || !auth.sessionReady) {
      return;
    }

    try {
      final resp = await _dio.get<dynamic>('/v1/me/safety_acknowledgements');
      final data = resp.data;
      if (data is! Map) {
        return;
      }
      final parsed = SafetyAcknowledgements.fromJson(
        data.cast<String, dynamic>(),
      );
      for (final id in parsed.techniqueIds) {
        await local.acknowledge(id);
      }
      ref.invalidate(safetyAcksProvider);
    } catch (_) {}
  }

  Future<void> pushAcknowledgements(List<String> techniqueIds) async {
    final auth = ref.read(authStateProvider);
    if (auth is! AuthStateSignedIn || !auth.sessionReady) {
      return;
    }
    if (techniqueIds.isEmpty) {
      return;
    }

    try {
      await _dio.post<dynamic>(
        '/v1/me/safety_acknowledgements',
        data: SafetyAcknowledgements(techniqueIds: techniqueIds).toJson(),
      );
    } catch (_) {}
  }
}
