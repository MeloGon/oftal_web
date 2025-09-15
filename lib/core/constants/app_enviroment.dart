import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnviroment {
  static Future<void> initEnvironment() async {
    const env = String.fromEnvironment('ENV', defaultValue: '');
    final fileName = env.isEmpty ? '.env' : '.env.$env';
    await dotenv.load(fileName: fileName);
  }

  static String url = dotenv.env["URL"] ?? 'No url';
  static String anonKey = dotenv.env["ANONKEY"] ?? 'No anon key';
}
