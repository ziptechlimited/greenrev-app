import 'dart:io' show Platform;

class Env {
  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv.replaceAll(RegExp(r'/$'), '');
    }
    
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:4000';
      }
    } catch (_) {}
    
    return 'http://localhost:4000';
  }
}
