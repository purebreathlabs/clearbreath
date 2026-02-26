import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';

final dailyLoginRepositoryProvider = Provider<DailyLoginRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return DailyLoginRepository(dio: dio);
});

class DailyLoginRepository {
  DailyLoginRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  static const _lastClaimKey = 'daily_open_last_claim';

  Future<void> claimIfNeeded(WidgetRef ref) async {
    final auth = ref.read(authStateProvider);
    if (auth is! AuthStateSignedIn || !auth.sessionReady) return;

    final today = _todayString();
    final prefs = await SharedPreferences.getInstance();
    final lastClaim = prefs.getString(_lastClaimKey);
    if (lastClaim == today) return;

    try {
      final tz = DateTime.now().timeZoneOffset.inMinutes;
      await _dio.post<dynamic>(
        '/v1/me/daily-open',
        data: {'timezone_offset_minutes': tz},
      );
      await prefs.setString(_lastClaimKey, today);
    } on DioException {
      // Silently fail — will retry next app open.
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
