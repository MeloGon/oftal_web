class AppEnviroment {
  static Future<void> initEnvironment() async {
    print('✅ Environment initialized');
  }

  // Get from build-time environment variables (MOST SECURE)
  static String get url {
    const url = String.fromEnvironment('SUPABASE_URL');
    print('🔍 URL from build env: ${url.isNotEmpty ? "FOUND" : "NOT FOUND"}');
    return url.isNotEmpty ? url : 'No url';
  }

  static String get anonKey {
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    print(
      '🔍 ANONKEY from build env: ${anonKey.isNotEmpty ? "FOUND" : "NOT FOUND"}',
    );
    return anonKey.isNotEmpty ? anonKey : 'No anon key';
  }
}
