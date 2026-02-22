import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/secure_storage/secure_storage.dart';

final deviceIdProvider = FutureProvider<String>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final store = DeviceIdStore(storage);
  return store.getOrCreate();
});

class DeviceIdStore {
  DeviceIdStore(this._storage);

  final SecureStorage _storage;

  static const _kDeviceId = 'auth.device_id';

  Future<String> getOrCreate({String Function()? idGenerator}) async {
    final existing = await _storage.readString(_kDeviceId);
    if (existing != null) {
      return existing;
    }

    final generateId = idGenerator ?? () => const Uuid().v4();
    final next = generateId().trim();
    if (next.isEmpty) {
      throw StateError('device id generation failed');
    }

    await _storage.writeString(_kDeviceId, next);
    return next;
  }
}
