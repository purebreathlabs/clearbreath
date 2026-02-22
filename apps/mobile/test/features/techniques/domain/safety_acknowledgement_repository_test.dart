import 'dart:io';

import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/features/techniques/domain/safety_acknowledgement_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists safety acknowledgements', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'clearbreath_safety_ack_',
    );
    final dbFile = File('${tempDir.path}/prefs.sqlite');

    try {
      final db1 = AppDatabase(NativeDatabase(dbFile));
      final repo1 = SafetyAcknowledgementRepository(db1);

      expect(await repo1.isAcknowledged('kapalbhati'), isFalse);
      await repo1.acknowledge('kapalbhati');
      expect(await repo1.isAcknowledged('kapalbhati'), isTrue);
      expect(await repo1.allAcknowledged(), equals({'kapalbhati'}));

      await db1.close();

      final db2 = AppDatabase(NativeDatabase(dbFile));
      final repo2 = SafetyAcknowledgementRepository(db2);

      expect(await repo2.isAcknowledged('kapalbhati'), isTrue);
      await repo2.acknowledge('bhastrika');
      expect(
        await repo2.allAcknowledged(),
        equals({'kapalbhati', 'bhastrika'}),
      );

      await db2.close();
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
