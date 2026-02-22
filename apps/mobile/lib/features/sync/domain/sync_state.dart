sealed class SyncState {
  const SyncState();
}

final class SyncIdle extends SyncState {
  const SyncIdle();
}

final class SyncInProgress extends SyncState {
  const SyncInProgress(this.message);

  final String message;
}

final class SyncComplete extends SyncState {
  const SyncComplete({
    required this.accepted,
    required this.duplicates,
    required this.rejected,
  });

  final int accepted;
  final int duplicates;
  final int rejected;
}

final class SyncFailed extends SyncState {
  const SyncFailed(this.error);

  final String error;
}

