class AppConfig {
  static final String apiBaseUrl = _sanitizeBaseUrl(
    const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.clearbreath.life',
    ),
  );

  static final bool devAuthEnabled = const bool.fromEnvironment(
    'DEV_AUTH_ENABLED',
    defaultValue: false,
  );

  static final String devAuthSecret = const String.fromEnvironment(
    'DEV_AUTH_SECRET',
    defaultValue: '',
  );

  static final String googleWebClientId = _trimmedDefine(
    const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: ''),
  );

  static final String googleIosClientId = _trimmedDefine(
    const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID', defaultValue: ''),
  );
}

String _sanitizeBaseUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 'https://api.clearbreath.life';
  }

  final normalized = trimmed.endsWith('/')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;

  final uri = Uri.tryParse(normalized);
  if (uri == null) {
    return 'https://api.clearbreath.life';
  }
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return 'https://api.clearbreath.life';
  }
  if (uri.host.trim().isEmpty) {
    return 'https://api.clearbreath.life';
  }

  return normalized;
}

String _trimmedDefine(String value) {
  return value.trim();
}
