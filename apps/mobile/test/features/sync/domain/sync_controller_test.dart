import 'dart:async';
import 'dart:io';

import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/core/network/models/session_models.dart';
import 'package:clearbreath/core/network/models/stats_models.dart' as api;
import 'package:clearbreath/core/network/models/user_models.dart';
import 'package:clearbreath/features/auth/domain/auth_controller.dart';
import 'package:clearbreath/features/auth/domain/auth_state.dart';
import 'package:clearbreath/features/auth/domain/auth_state_provider.dart';
import 'package:clearbreath/features/session/data/session_repository.dart';
import 'package:clearbreath/features/session/domain/local_session.dart';
import 'package:clearbreath/features/stats/data/stats_cache_repository.dart';
import 'package:clearbreath/features/sync/data/sync_repository.dart';
import 'package:clearbreath/features/sync/domain/sync_controller.dart';
import 'package:clearbreath/features/sync/domain/sync_state.dart';
import 'package:clearbreath/features/techniques/data/safety_sync_service.dart';
import 'package:clearbreath/features/techniques/domain/safety_acknowledgement_repository.dart';
import 'package:clearbreath/shared/providers/app_database_provider.dart';
import 'package:clearbreath/shared/providers/connection_status_provider.dart';
import 'package:drift/native.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sync runs on sign-in and marks accepted sessions as synced', () async {
    final tempDir = await Directory.systemTemp.createTemp('clearbreath_sync_');
    final dbFile = File('${tempDir.path}/sync.sqlite');

    final response = SessionsIngestResponse(
      acceptedCount: 1,
      duplicateCount: 0,
      rejected: const [
        RejectedSession(
          clientSessionId: 's2',
          code: 'validation',
          message: 'invalid',
        ),
      ],
      statsSnapshot: api.StatsSnapshot(
        currentStreakDays: 2,
        longestStreakDays: 5,
        practiceDaysAllTime: 0,
        minutesThisWeek: 12,
        minutesAllTime: 34,
        sessionsAllTime: 7,
        minutesByTechnique: const {'box': 34},
        updatedAtUtc: DateTime.utc(2026, 2, 22, 12, 0),
        totalXp: 150,
        currentLevel: 2,
      ),
      xpAwards: const [],
      totalXp: 150,
      currentLevel: 2,
    );

    late _SpySafetySyncService safetySpy;
    final fakeSyncRepo = _FakeSyncRepository(response);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase(dbFile));
          ref.onDispose(db.close);
          return db;
        }),
        authStateProvider.overrideWith(_TestAuthController.new),
        syncRepositoryProvider.overrideWithValue(fakeSyncRepo),
        safetySyncServiceProvider.overrideWith((ref) {
          final local = ref.read(safetyAckRepositoryProvider);
          safetySpy = _SpySafetySyncService(ref: ref, local: local);
          return safetySpy;
        }),
        connectivityProvider.overrideWith(
          (ref) => Stream.value(true),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await tempDir.delete(recursive: true);
    });

    final sessions = container.read(sessionRepositoryProvider);
    await sessions.insert(_buildSession(id: 's1', syncedToCloud: false));
    await sessions.insert(_buildSession(id: 's2', syncedToCloud: false));

    container.read(syncControllerProvider);

    Future<SyncState> waitForComplete() {
      final completer = Completer<SyncState>();
      late final ProviderSubscription<SyncState> sub;
      sub = container.listen(syncControllerProvider, (previous, next) {
        if (next is SyncComplete && !completer.isCompleted) {
          completer.complete(next);
          sub.close();
        }
      }, fireImmediately: true);
      return completer.future.timeout(const Duration(seconds: 2));
    }

    final auth =
        container.read(authStateProvider.notifier) as _TestAuthController;
    auth.setSignedIn(_profile('user1'));

    final done = await waitForComplete();
    expect(done, isA<SyncComplete>());

    expect(fakeSyncRepo.syncCalls, equals(1));
    expect(safetySpy.pullCalls, equals(1));

    final remaining = await sessions.unsynced();
    expect(remaining.map((s) => s.clientSessionId), equals(['s2']));

    final cached = await container
        .read(statsCacheRepositoryProvider)
        .readCached();
    expect(cached, isNotNull);
    expect(cached!.minutesAllTime, equals(34));
    expect(cached.currentStreakDays, equals(2));
  });
}

LocalSession _buildSession({required String id, required bool syncedToCloud}) {
  final startedAtUtc = DateTime.utc(2026, 2, 22, 10);
  return LocalSession(
    clientSessionId: id,
    techniqueId: 'box',
    presetId: 'beginner',
    startedAtUtc: startedAtUtc,
    endedAtUtc: startedAtUtc.add(const Duration(minutes: 5)),
    timezoneOffsetMinutes: 0,
    durationSecondsActual: 300,
    breathsCompletedEstimated: 42,
    endedEarly: false,
    syncedToCloud: syncedToCloud,
    createdAt: startedAtUtc,
  );
}

UserProfile _profile(String userId) {
  return UserProfile(
    id: userId,
    username: 'Breather123456',
    name: '',
    avatarSeed: 'seed',
    leaderboardOptIn: true,
    createdAtUtc: DateTime.utc(2026, 2, 22),
    timezoneOffsetMinutesLatest: 0,
  );
}

class _FakeSyncRepository extends SyncRepository {
  _FakeSyncRepository(this._response) : super(Dio());

  final SessionsIngestResponse _response;

  int syncCalls = 0;

  @override
  Future<SessionsIngestResponse> sync(List<LocalSession> sessions) async {
    syncCalls += 1;
    return _response;
  }
}

class _TestAuthController extends AuthController {
  @override
  AuthState build() => const AuthStateGuest();

  void setSignedIn(UserProfile profile) {
    state = AuthStateSignedIn(profile: profile);
  }
}

class _SpySafetySyncService extends SafetySyncService {
  _SpySafetySyncService({required super.ref, required super.local})
    : super(dio: Dio());

  int pullCalls = 0;

  @override
  Future<void> pullAndMerge() async {
    pullCalls += 1;
  }
}
