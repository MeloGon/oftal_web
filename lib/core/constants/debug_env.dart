import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_enviroment.dart';

class DebugEnv {
  static void printEnvironmentVariables() {
    print('=== ENVIRONMENT VARIABLES DEBUG ===');
    
    // Check system environment variables
    const systemUrl = String.fromEnvironment('SUPABASE_URL');
    const systemKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    
    print('SYSTEM ENV - SUPABASE_URL: ${systemUrl.isEmpty ? "NOT FOUND" : "FOUND"}');
    print('SYSTEM ENV - SUPABASE_ANON_KEY: ${systemKey.isEmpty ? "NOT FOUND" : "FOUND"}');
    
    // Check .env file variables
    print('DOTENV - URL: ${dotenv.env["URL"] ?? "NOT FOUND"}');
    print('DOTENV - ANONKEY: ${dotenv.env["ANONKEY"] ?? "NOT FOUND"}');
    print('DOTENV - API_BASE_URL: ${dotenv.env["API_BASE_URL"] ?? "NOT FOUND"}');
    print('DOTENV - API_TIMEOUT: ${dotenv.env["API_TIMEOUT"] ?? "NOT FOUND"}');
    print('DOTENV - APP_NAME: ${dotenv.env["APP_NAME"] ?? "NOT FOUND"}');
    print('DOTENV - APP_VERSION: ${dotenv.env["APP_VERSION"] ?? "NOT FOUND"}');
    print('DOTENV - DEBUG_MODE: ${dotenv.env["DEBUG_MODE"] ?? "NOT FOUND"}');
    
    // Show final values that will be used
    print('FINAL VALUES:');
    print('URL: ${AppEnviroment.url}');
    print('ANONKEY: ${AppEnviroment.anonKey}');
    print('===================================');
  }
}
