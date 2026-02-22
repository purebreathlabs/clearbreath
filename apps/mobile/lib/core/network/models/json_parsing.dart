typedef JsonMap = Map<String, dynamic>;

String readString(JsonMap json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Missing or invalid $key.');
}

String? readNullableString(JsonMap json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  throw FormatException('Missing or invalid $key.');
}

bool readBool(JsonMap json, String key) {
  final value = json[key];
  if (value is bool) {
    return value;
  }
  throw FormatException('Missing or invalid $key.');
}

int readInt(JsonMap json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  throw FormatException('Missing or invalid $key.');
}

int? readNullableInt(JsonMap json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  throw FormatException('Missing or invalid $key.');
}

DateTime readDateTimeUtc(JsonMap json, String key) {
  final raw = readString(json, key);
  return DateTime.parse(raw).toUtc();
}

JsonMap readMap(JsonMap json, String key) {
  final value = json[key];
  if (value is Map) {
    return value.cast<String, dynamic>();
  }
  throw FormatException('Missing or invalid $key.');
}

List<JsonMap> readMapList(JsonMap json, String key) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('Missing or invalid $key.');
  }
  final out = <JsonMap>[];
  for (final item in value) {
    if (item is! Map) {
      throw FormatException('Invalid item in $key.');
    }
    out.add(item.cast<String, dynamic>());
  }
  return out;
}

List<String> readStringList(JsonMap json, String key) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('Missing or invalid $key.');
  }
  final out = <String>[];
  for (final item in value) {
    if (item is! String) {
      throw FormatException('Invalid item in $key.');
    }
    out.add(item);
  }
  return out;
}

Map<String, int> readStringIntMap(JsonMap json, String key) {
  final value = json[key];
  if (value is! Map) {
    throw FormatException('Missing or invalid $key.');
  }
  final out = <String, int>{};
  for (final entry in value.entries) {
    final k = entry.key;
    final v = entry.value;
    if (k is! String) {
      continue;
    }
    if (v is int) {
      out[k] = v;
      continue;
    }
    if (v is num) {
      out[k] = v.round();
    }
  }
  return out;
}

