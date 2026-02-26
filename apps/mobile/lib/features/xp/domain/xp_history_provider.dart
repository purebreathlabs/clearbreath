import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/models/json_parsing.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';

class XPDayEntry {
  const XPDayEntry({
    required this.localDay,
    required this.totalXP,
    required this.practiceXP,
    required this.loginXP,
  });

  factory XPDayEntry.fromJson(JsonMap json) {
    return XPDayEntry(
      localDay: readString(json, 'local_day'),
      totalXP: readInt(json, 'total_xp'),
      practiceXP: readInt(json, 'practice_xp'),
      loginXP: readInt(json, 'login_xp'),
    );
  }

  final String localDay;
  final int totalXP;
  final int practiceXP;
  final int loginXP;
}

final xpHistoryProvider = FutureProvider.family<List<XPDayEntry>, int>((
  ref,
  days,
) async {
  final auth = ref.watch(authStateProvider);
  if (auth is! AuthStateSignedIn || !auth.sessionReady) {
    return [];
  }

  final dio = ref.watch(apiClientProvider);
  final tz = DateTime.now().timeZoneOffset.inMinutes;
  try {
    final resp = await dio.get<dynamic>(
      '/v1/xp/history',
      queryParameters: {'days': days, 'timezone_offset_minutes': tz},
    );
    final data = resp.data;
    if (data is! Map) return [];
    final daysList = data['days'];
    if (daysList is! List) return [];
    return daysList
        .whereType<Map>()
        .map((e) => XPDayEntry.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  } on DioException {
    return [];
  }
});
