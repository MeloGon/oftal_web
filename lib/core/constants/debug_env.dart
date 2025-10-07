import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_enviroment.dart';

class DebugEnv {
  static void printEnvironmentVariables() {
    print('=== ENVIRONMENT VARIABLES DEBUG ===');
    
    // Check if dotenv is loaded
    print('DOTENV LOADED: ${dotenv.isInitialized}');
    
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
