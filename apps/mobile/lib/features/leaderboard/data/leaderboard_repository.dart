import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/models/leaderboard_models.dart' as api;
import '../../../shared/providers/app_database_provider.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/leaderboard_ranking.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return LeaderboardRepository(dio: dio, db: db);
});

@immutable
class LeaderboardListResult {
  const LeaderboardListResult({
    required this.entries,
    required this.generatedAtUtc,
    required this.fetchedAtUtc,
    required this.fromCache,
    required this.errorMessage,
  });

  final List<LeaderboardEntry> entries;
  final DateTime generatedAtUtc;
  final DateTime fetchedAtUtc;
  final bool fromCache;
  final String? errorMessage;

  LeaderboardListResult copyWith({
    List<LeaderboardEntry>? entries,
    DateTime? generatedAtUtc,
    DateTime? fetchedAtUtc,
    bool? fromCache,
    String? errorMessage,
  }) {
    return LeaderboardListResult(
      entries: entries ?? this.entries,
      generatedAtUtc: generatedAtUtc ?? this.generatedAtUtc,
      fetchedAtUtc: fetchedAtUtc ?? this.fetchedAtUtc,
      fromCache: fromCache ?? this.fromCache,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@immutable
class LeaderboardSelfResult {
  const LeaderboardSelfResult({required this.rank, required this.metricValue});

  final int? rank;
  final int metricValue;
}

class LeaderboardRepository {
  LeaderboardRepository({required Dio dio, required AppDatabase db})
    : _dio = dio,
      _db = db;

  final Dio _dio;
  final AppDatabase _db;

  Future<LeaderboardListResult> fetchList(
    LeaderboardRanking ranking, {
    int limit = 50,
  }) async {
    final safeLimit = limit.clamp(1, 50);
    final rankingParam = ranking.toQueryParam();
    final now = DateTime.now().toUtc();

    try {
      final resp = await _dio.get<dynamic>(
        '/v1/leaderboard',
        queryParameters: {'ranking': rankingParam, 'limit': safeLimit},
      );
      final data = resp.data;
      if (data is! Map) {
        throw FormatException('Invalid leaderboard response.');
      }

      final parsed = api.LeaderboardListResponse.fromJson(
        data.cast<String, dynamic>(),
      );

      final entries = parsed.top.map(_toEntry).toList(growable: false);
      final rowsJson = jsonEncode(_encodeApiRows(parsed.top));

      try {
        await _db.into(_db.leaderboardCache).insertOnConflictUpdate(
          LeaderboardCacheCompanion.insert(
            ranking: rankingParam,
            rowsJson: rowsJson,
            generatedAtUtc: parsed.generatedAtUtc.toUtc(),
            fetchedAt: now,
          ),
        );
      } catch (_) {}

      return LeaderboardListResult(
        entries: entries,
        generatedAtUtc: parsed.generatedAtUtc.toUtc(),
        fetchedAtUtc: now,
        fromCache: false,
        errorMessage: null,
      );
    } on DioException catch (e) {
      final message = ApiError.fromDioException(e).message;
      final cached = await _readCachedList(rankingParam);
      if (cached != null) {
        return cached.copyWith(fromCache: true, errorMessage: message);
      }
      rethrow;
    } catch (_) {
      final cached = await _readCachedList(rankingParam);
      if (cached != null) {
        return cached.copyWith(fromCache: true, errorMessage: 'Could not refresh.');
      }
      rethrow;
    }
  }

  Future<LeaderboardSelfResult> fetchSelf(LeaderboardRanking ranking) async {
    final rankingParam = ranking.toQueryParam();

    final resp = await _dio.get<dynamic>(
      '/v1/leaderboard/self',
      queryParameters: {'ranking': rankingParam},
    );
    final data = resp.data;
    if (data is! Map) {
      throw FormatException('Invalid leaderboard response.');
    }

    final parsed = api.LeaderboardSelfResponse.fromJson(
      data.cast<String, dynamic>(),
    );

    return LeaderboardSelfResult(
      rank: parsed.user.rank,
      metricValue: parsed.user.metricValue,
    );
  }

  List<Map<String, dynamic>> _encodeApiRows(List<api.LeaderboardRow> rows) {
    return rows
        .map(
          (row) => <String, dynamic>{
            'rank': row.rank,
            'display_name_or_initials': row.displayNameOrInitials,
            'avatar_seed': row.avatarSeed,
            'metric_value': row.metricValue,
            'user_id': row.userId,
          },
        )
        .toList(growable: false);
  }

  LeaderboardEntry _toEntry(api.LeaderboardRow row) {
    return LeaderboardEntry(
      rank: row.rank,
      displayNameOrInitials: row.displayNameOrInitials,
      avatarSeed: row.avatarSeed,
      metricValue: row.metricValue,
      userId: row.userId,
    );
  }

  Future<LeaderboardListResult?> _readCachedList(String rankingParam) async {
    final row = await (_db.select(
      _db.leaderboardCache,
    )..where((row) => row.ranking.equals(rankingParam))).getSingleOrNull();
    if (row == null) {
      return null;
    }

    final entries = _decodeEntries(row.rowsJson);
    return LeaderboardListResult(
      entries: entries,
      generatedAtUtc: row.generatedAtUtc.toUtc(),
      fetchedAtUtc: row.fetchedAt.toUtc(),
      fromCache: true,
      errorMessage: null,
    );
  }

  List<LeaderboardEntry> _decodeEntries(String rowsJson) {
    try {
      final decoded = jsonDecode(rowsJson);
      if (decoded is! List) {
        return const [];
      }
      final result = <LeaderboardEntry>[];
      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }
        final row = api.LeaderboardRow.fromJson(item.cast<String, dynamic>());
        result.add(_toEntry(row));
      }
      return result;
    } catch (_) {
      return const [];
    }
  }
}
