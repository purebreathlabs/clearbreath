import 'dart:async';
import 'dart:io';

import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/features/intro/data/intro_repository.dart';
import 'package:clearbreath/features/intro/domain/intro_gate.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _waitForLoaded(IntroGate gate) async {
  if (gate.isLoaded) {
    return;
  }

  final completer = Completer<void>();
  void listener() {
    if (gate.isLoaded && !completer.isCompleted) {
      completer.complete();
      gate.removeListener(listener);
    }
  }

  gate.addListener(listener);
  await completer.future.timeout(const Duration(seconds: 1));
}

void main() {
  test('persists intro completion across restart', () async {
    final tempDir = await Directory.systemTemp.createTemp('clearbreath_intro_');
    final dbFile = File('${tempDir.path}/prefs.sqlite');

    try {
      final db1 = AppDatabase(NativeDatabase(dbFile));
      final repo1 = IntroRepository(db1);
      final gate1 = IntroGate(repo1);
      await _waitForLoaded(gate1);

      expect(gate1.isComplete, isFalse);
      await gate1.complete();
      expect(gate1.isComplete, isTrue);

      gate1.dispose();
      await db1.close();

      final db2 = AppDatabase(NativeDatabase(dbFile));
      final repo2 = IntroRepository(db2);
      final gate2 = IntroGate(repo2);
      await _waitForLoaded(gate2);

      expect(gate2.isComplete, isTrue);

      gate2.dispose();
      await db2.close();
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
