import 'package:clearbreath/app.dart';
import 'package:clearbreath/core/network/models/user_models.dart';
import 'package:clearbreath/features/auth/domain/auth_controller.dart';
import 'package:clearbreath/features/auth/domain/auth_state.dart';
import 'package:clearbreath/features/auth/domain/auth_state_provider.dart';
import 'package:clearbreath/features/leaderboard/data/leaderboard_repository.dart';
import 'package:clearbreath/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:clearbreath/features/leaderboard/domain/leaderboard_ranking.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_gate.dart';
import 'package:clearbreath/features/stats/domain/stats_snapshot.dart';
import 'package:clearbreath/features/sync/domain/merged_stats_provider.dart';
import 'package:clearbreath/features/xp/domain/xp_provider.dart';
import 'package:clearbreath/features/xp/domain/xp_state.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clearbreath/core/database/app_database.dart';

void main() {
  testWidgets('leaderboard unlocks when signed in', (tester) async {
    final repo = _FakeLeaderboardRepository();
    addTearDown(repo.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(() => _SignedInAuthController()),
          leaderboardRepositoryProvider.overrideWithValue(repo),
          onboardingGateProvider.overrideWith((ref) {
            final repository = ref.watch(onboardingRepositoryProvider);
            final gate = OnboardingGate(
              repository,
              initialStatus: OnboardingStatus.complete,
              loadOnInit: false,
            );
            ref.onDispose(gate.dispose);
            return gate;
          }),
          mergedStatsProvider.overrideWith(
            (ref) async => StatsSnapshot.empty(),
          ),
          mergedXPProvider.overrideWith(
            (ref) async => XPState.empty(),
          ),
        ],
        child: const ClearBreathApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Leaderboard is locked'), findsNothing);
    expect(find.byKey(const Key('self_rank_card')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

class _SignedInAuthController extends AuthController {
  @override
  AuthState build() {
    return AuthStateSignedIn(
      profile: UserProfile(
        id: 'test-user',
        displayName: 'Breather123456',
        avatarSeed: 'seed',
        leaderboardOptIn: true,
        leaderboardInitialsOnly: false,
        createdAtUtc: DateTime.utc(2026, 2, 22),
        timezoneOffsetMinutesLatest: 0,
      ),
    );
  }
}

class _FakeLeaderboardRepository extends LeaderboardRepository {
  _FakeLeaderboardRepository._(this._db) : super(dio: Dio(), db: _db);

  factory _FakeLeaderboardRepository() {
    final db = AppDatabase(NativeDatabase.memory());
    return _FakeLeaderboardRepository._(db);
  }

  final AppDatabase _db;

  Future<void> dispose() async {
    await _db.close();
  }

  @override
  Future<LeaderboardListResult> fetchList(
    LeaderboardRanking ranking, {
    int limit = 50,
  }) async {
    final now = DateTime.now().toUtc();
    return LeaderboardListResult(
      entries: const [
        LeaderboardEntry(
          rank: 1,
          displayNameOrInitials: 'AB',
          avatarSeed: 'seed',
          totalXp: 500,
          level: 3,
          userId: 'test-user',
        ),
      ],
      generatedAtUtc: now,
      fetchedAtUtc: now,
      fromCache: false,
      errorMessage: null,
    );
  }

  @override
  Future<LeaderboardSelfResult> fetchSelf(LeaderboardRanking ranking) async {
    return const LeaderboardSelfResult(rank: 1, totalXp: 500, level: 3);
  }
}
