import 'package:flutter_dotenv/flutter_dotenv.dart';

class DebugEnv {
  static void printEnvironmentVariables() {
    print('=== ENVIRONMENT VARIABLES DEBUG ===');
    print('URL: ${dotenv.env["URL"] ?? "NOT FOUND"}');
    print('ANONKEY: ${dotenv.env["ANONKEY"] ?? "NOT FOUND"}');
    print('API_BASE_URL: ${dotenv.env["API_BASE_URL"] ?? "NOT FOUND"}');
    print('API_TIMEOUT: ${dotenv.env["API_TIMEOUT"] ?? "NOT FOUND"}');
    print('APP_NAME: ${dotenv.env["APP_NAME"] ?? "NOT FOUND"}');
    print('APP_VERSION: ${dotenv.env["APP_VERSION"] ?? "NOT FOUND"}');
    print('DEBUG_MODE: ${dotenv.env["DEBUG_MODE"] ?? "NOT FOUND"}');
    print('===================================');
  }
}
