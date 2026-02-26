import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/core/network/models/user_models.dart';
import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/auth/domain/auth_controller.dart';
import 'package:clearbreath/features/auth/domain/auth_state.dart';
import 'package:clearbreath/features/auth/domain/auth_state_provider.dart';
import 'package:clearbreath/features/leaderboard/data/leaderboard_repository.dart';
import 'package:clearbreath/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:clearbreath/features/leaderboard/domain/leaderboard_ranking.dart';
import 'package:clearbreath/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('guest sees locked screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const LeaderboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Leaderboard is locked'), findsOneWidget);
  });

  testWidgets('signed-in user sees self rank card', (
    tester,
  ) async {
    final repo = _FakeLeaderboardRepository();
    addTearDown(repo.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(() => _SignedInAuthController()),
          leaderboardRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const LeaderboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('self_rank_card')), findsOneWidget);
    expect(find.text('AB'), findsOneWidget);
  });
}

class _SignedInAuthController extends AuthController {
  @override
  AuthState build() {
    return AuthStateSignedIn(
      profile: UserProfile(
        id: 'user-a',
        displayName: 'Breather123456',
        avatarSeed: 'seed-a',
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
          avatarSeed: 'seed-a',
          totalXp: 500,
          level: 3,
          userId: 'user-a',
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
