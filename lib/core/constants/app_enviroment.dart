import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnviroment {
  static Future<void> initEnvironment() async {
    const env = String.fromEnvironment('ENV', defaultValue: '');
    final fileName = env.isEmpty ? '.env' : '.env.$env';
    
    try {
      await dotenv.load(fileName: fileName);
      print('✅ .env file loaded successfully');
    } catch (e) {
      print('❌ Error loading .env file: $e');
    }
  }

  static String get url {
    final dotenvUrl = dotenv.env["URL"];
    print('🔍 URL from .env: $dotenvUrl');
    return dotenvUrl ?? 'No url';
  }
  
  static String get anonKey {
    final dotenvKey = dotenv.env["ANONKEY"];
    print('🔍 ANONKEY from .env: $dotenvKey');
    return dotenvKey ?? 'No anon key';
  }
}
