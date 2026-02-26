import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../data/leaderboard_repository.dart';
import 'leaderboard_entry.dart';
import 'leaderboard_ranking.dart';
import 'leaderboard_state.dart';

final leaderboardControllerProvider =
    NotifierProvider<LeaderboardController, LeaderboardState>(
      LeaderboardController.new,
    );

class LeaderboardController extends Notifier<LeaderboardState> {
  int _requestId = 0;

  @override
  LeaderboardState build() {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      final becameReady =
          (previous is! AuthStateSignedIn || !previous.sessionReady) &&
          next is AuthStateSignedIn &&
          next.sessionReady;
      if (becameReady) {
        unawaited(Future.microtask(load));
      }
      if (next is AuthStateGuest) {
        state = LeaderboardState.initial();
      }
    });

    final auth = ref.read(authStateProvider);
    if (auth is AuthStateSignedIn && auth.sessionReady) {
      unawaited(Future.microtask(load));
    }

    return LeaderboardState.initial();
  }

  Future<void> refresh() => load();

  Future<void> load() async {
    final auth = ref.read(authStateProvider);
    if (auth is! AuthStateSignedIn || !auth.sessionReady) {
      return;
    }

    final requestId = ++_requestId;
    const ranking = LeaderboardRanking.xp;

    state = state.copyWith(
      loading: true,
      bannerMessage: null,
      errorMessage: null,
    );

    final repo = ref.read(leaderboardRepositoryProvider);

    try {
      final list = await repo.fetchList(ranking);

      if (requestId != _requestId) {
        return;
      }

      final userId = auth.profile.id;
      final fromList = _findSelf(list.entries, userId);
      final self = fromList ?? await _fetchSelfFallback(repo, ranking, auth);

      if (requestId != _requestId) {
        return;
      }

      final banner = list.fromCache && list.errorMessage != null
          ? "Couldn't refresh. Showing saved results."
          : null;

      state = state.copyWith(
        loading: false,
        entries: list.entries,
        self: self,
        generatedAtUtc: list.generatedAtUtc,
        fetchedAtUtc: list.fetchedAtUtc,
        bannerMessage: banner,
        errorMessage: null,
      );
    } on DioException catch (e) {
      final message = ApiError.fromDioException(e).message;
      if (requestId != _requestId) {
        return;
      }
      state = state.copyWith(
        loading: false,
        bannerMessage: null,
        errorMessage: message,
      );
    } catch (_) {
      if (requestId != _requestId) {
        return;
      }
      state = state.copyWith(
        loading: false,
        bannerMessage: null,
        errorMessage: 'Could not load leaderboard.',
      );
    }
  }

  Future<LeaderboardEntry> _fetchSelfFallback(
    LeaderboardRepository repo,
    LeaderboardRanking ranking,
    AuthStateSignedIn auth,
  ) async {
    try {
      final self = await repo.fetchSelf(ranking);
      return LeaderboardEntry(
        rank: self.rank,
        displayNameOrInitials: auth.profile.leaderboardInitialsOnly
            ? _initials(auth.profile.displayName)
            : auth.profile.displayName,
        avatarSeed: auth.profile.avatarSeed,
        totalXp: self.totalXp,
        level: self.level,
        userId: auth.profile.id,
      );
    } catch (_) {
      return LeaderboardEntry(
        rank: null,
        displayNameOrInitials: auth.profile.leaderboardInitialsOnly
            ? _initials(auth.profile.displayName)
            : auth.profile.displayName,
        avatarSeed: auth.profile.avatarSeed,
        totalXp: 0,
        level: 0,
        userId: auth.profile.id,
      );
    }
  }

  LeaderboardEntry? _findSelf(List<LeaderboardEntry> entries, String userId) {
    for (final entry in entries) {
      if (entry.userId == userId) {
        return entry;
      }
    }
    return null;
  }
}

String _initials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return 'C';
  }
  final parts = trimmed
      .split(RegExp(r'\\s+'))
      .where((p) => p.trim().isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'C';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  final first = parts.first.substring(0, 1).toUpperCase();
  final last = parts.last.substring(0, 1).toUpperCase();
  return '$first$last';
}
