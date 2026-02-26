import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/models/session_models.dart';

final dailyLoginRepositoryProvider = Provider<DailyLoginRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return DailyLoginRepository(dio: dio);
});

class DailyOpenResult {
  const DailyOpenResult({
    required this.awarded,
    required this.award,
    required this.totalXp,
    required this.currentLevel,
  });

  final bool awarded;
  final XPAward? award;
  final int totalXp;
  final int currentLevel;
}

class DailyLoginRepository {
  DailyLoginRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  static const _lastClaimKeyPrefix = 'daily_open_last_claim:';

  Future<DailyOpenResult?> claimIfNeeded({required String userId}) async {
    final key = '$_lastClaimKeyPrefix$userId';
    final today = _todayString();
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
    final lastClaim = prefs.getString(key);
    if (lastClaim == today) return null;

    try {
      final tz = DateTime.now().timeZoneOffset.inMinutes;
      final resp = await _dio.post<dynamic>(
        '/v1/me/daily-open',
        data: {'timezone_offset_minutes': tz},
      );
      final data = resp.data;
      if (data is! Map) {
        return null;
      }

      final json = data.cast<String, dynamic>();
      final awarded = json['awarded'] == true;
      final totalXp = (json['total_xp'] as num?)?.toInt() ?? 0;
      final currentLevel = (json['current_level'] as num?)?.toInt() ?? 0;

      XPAward? award;
      final awardJson = json['xp_award'];
      if (awardJson is Map) {
        award = XPAward.fromJson(awardJson.cast<String, dynamic>());
      }

      try {
        await prefs.setString(key, today);
      } catch (_) {}
      return DailyOpenResult(
        awarded: awarded,
        award: award,
        totalXp: totalXp,
        currentLevel: currentLevel,
      );
    } on DioException {
      return null;
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
