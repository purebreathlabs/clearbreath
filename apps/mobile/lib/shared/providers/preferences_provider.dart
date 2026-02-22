import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import 'app_database_provider.dart';

final preferencesProvider = StreamProvider<Preference?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.preferences)..where((row) => row.id.equals(1)))
      .watchSingleOrNull();
});

final hapticsEnabledProvider = Provider<bool>((ref) {
  final prefs = ref.watch(preferencesProvider);
  return prefs.maybeWhen(
    data: (row) => row?.hapticsEnabled ?? true,
    orElse: () => true,
  );
});

final keepScreenAwakeEnabledProvider = Provider<bool>((ref) {
  final prefs = ref.watch(preferencesProvider);
  return prefs.maybeWhen(
    data: (row) => row?.keepScreenAwake ?? true,
    orElse: () => true,
  );
});
