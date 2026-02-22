import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = Platform.environment.containsKey('FLUTTER_TEST')
      ? AppDatabase(
          DatabaseConnection(
            NativeDatabase.memory(),
            closeStreamsSynchronously: true,
          ),
        )
      : AppDatabase.open();

  ref.onDispose(db.close);
  return db;
});
