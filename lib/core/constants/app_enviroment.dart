import 'package:flutter/foundation.dart';

class AppEnviroment {
  static Future<void> initEnvironment() async {
    debugPrint('✅ Environment initialized');
  }

  // Get from build-time environment variables (MOST SECURE)
  static String get url {
    const url = String.fromEnvironment('SUPABASE_URL');
    debugPrint(
      '🔍 URL from build env: ${url.isNotEmpty ? "FOUND" : "NOT FOUND"}',
    );
    return url.isNotEmpty ? url : 'No url';
  }

  static String get publishableKey {
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    debugPrint(
      '🔍 ANONKEY from build env: ${key.isNotEmpty ? "FOUND" : "NOT FOUND"}',
    );
    return key.isNotEmpty ? key : 'No anon key';
  }
}
