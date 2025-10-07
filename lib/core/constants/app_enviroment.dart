import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnviroment {
  static Future<void> initEnvironment() async {
    const env = String.fromEnvironment('ENV', defaultValue: '');
    final fileName = env.isEmpty ? '.env' : '.env.$env';
    
    try {
      await dotenv.load(fileName: fileName);
    } catch (e) {
      print('Warning: Could not load .env file: $e');
    }
  }

  // Try to get from environment variables first, then from .env file
  static String get url {
    // Try environment variables first (for production)
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    
    // Fallback to .env file
    return dotenv.env["URL"] ?? 'No url';
  }
  
  static String get anonKey {
    // Try environment variables first (for production)
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envKey.isNotEmpty) return envKey;
    
    // Fallback to .env file
    return dotenv.env["ANONKEY"] ?? 'No anon key';
  }
}
