class AppEnviroment {
  static Future<void> initEnvironment() async {
    print('✅ Environment initialized');
  }

  // Get from build-time environment variables (MOST SECURE)
  static String get url {
    const url = String.fromEnvironment('SUPABASE_URL');
    print('🔍 URL from build env: ${url.isNotEmpty ? "FOUND" : "NOT FOUND"}');
    return url.isNotEmpty ? url : 'https://gutgxjgfjbodznzjiqtm.supabase.co';
  }

  static String get anonKey {
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    print(
      '🔍 ANONKEY from build env: ${anonKey.isNotEmpty ? "FOUND" : "NOT FOUND"}',
    );
    return anonKey.isNotEmpty
        ? anonKey
        : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd1dGd4amdmamJvZHpuemppcXRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MjMyMjYsImV4cCI6MjA2OTk5OTIyNn0.FnPBtKjorYWm9gNC8TZwH-OFvPhj9VtYhtu_EWRqVPk';
  }
}
