class Env {
  static const String _defaultUrl = 'https://api.greenrevs.com';

  static String get apiBaseUrl {
    const overrideUrl = String.fromEnvironment('API_BASE_URL');
    if (overrideUrl.isNotEmpty) {
      return overrideUrl.replaceAll(RegExp(r'/$'), '');
    }
    return _defaultUrl;
  }
}
