import 'dart:io';
import 'dart:typed_data';

import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/features/leaderboard/data/leaderboard_repository.dart';
import 'package:clearbreath/features/leaderboard/domain/leaderboard_ranking.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetchList caches and serves cached on failure', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'clearbreath_leaderboard_',
    );
    final dbFile = File('${tempDir.path}/leaderboard.sqlite');

    final db = AppDatabase(NativeDatabase(dbFile));
    addTearDown(() async {
      await db.close();
      await tempDir.delete(recursive: true);
    });

    var shouldFail = false;
    final dio = Dio();
    dio.httpClientAdapter = _TestAdapter((options) async {
      if (options.path == '/v1/leaderboard') {
        if (shouldFail) {
          return ResponseBody.fromString(
            '{"error":"internal","code":"internal","request_id":"r"}',
            500,
            headers: {
              'content-type': ['application/json'],
            },
          );
        }

        expect(options.queryParameters['ranking'], equals('xp'));
        return ResponseBody.fromString(
          _weeklyListJson(),
          200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      }

      return ResponseBody.fromString(
        '{"error":"not_found","code":"not_found","request_id":"r"}',
        404,
        headers: {
          'content-type': ['application/json'],
        },
      );
    });

    final repo = LeaderboardRepository(dio: dio, db: db);

    final first = await repo.fetchList(LeaderboardRanking.xp);
    expect(first.fromCache, isFalse);
    expect(first.entries.length, 2);
    expect(first.entries.first.rank, 1);
    expect(first.entries.first.totalXp, 120);

    shouldFail = true;
    final second = await repo.fetchList(LeaderboardRanking.xp);
    expect(second.fromCache, isTrue);
    expect(second.entries.length, 2);
    expect(second.entries.first.rank, 1);
    expect(second.errorMessage, isNotNull);
  });
}

class _TestAdapter implements HttpClientAdapter {
  _TestAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

String _weeklyListJson() {
  return '''
{
  "ranking":"xp",
  "generated_at_utc":"2026-02-18T12:00:00Z",
  "top":[
    {
      "rank":1,
      "username":"AB",
      "avatar_seed":"seed-a",
      "total_xp":120,
      "level":5,
      "user_id":"user-a"
    },
    {
      "rank":2,
      "username":"CD",
      "avatar_seed":"seed-b",
      "total_xp":60,
      "level":3,
      "user_id":"user-b"
    }
  ]
}
''';
}
