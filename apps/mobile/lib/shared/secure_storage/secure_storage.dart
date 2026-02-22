import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorage {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();

  Future<DateTime?> readDateTimeUtc(String key);
  Future<void> writeDateTimeUtc(String key, DateTime value);
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  const storage = FlutterSecureStorage();
  return _FlutterSecureStorageAdapter(storage);
});

class _FlutterSecureStorageAdapter implements SecureStorage {
  _FlutterSecureStorageAdapter(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readString(String key) async {
    final value = await _storage.read(key: key);
    return value?.trim().isEmpty ?? true ? null : value;
  }

  @override
  Future<void> writeString(String key, String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await _storage.delete(key: key);
      return;
    }
    await _storage.write(key: key, value: trimmed);
  }

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();

  @override
  Future<DateTime?> readDateTimeUtc(String key) async {
    final raw = await readString(key);
    if (raw == null) {
      return null;
    }
    try {
      return DateTime.parse(raw).toUtc();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeDateTimeUtc(String key, DateTime value) async {
    await writeString(key, value.toUtc().toIso8601String());
  }
}
