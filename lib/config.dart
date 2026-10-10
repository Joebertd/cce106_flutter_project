import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String _read(String key, String compileTimeValue) {
    if (compileTimeValue.isNotEmpty) {
      return compileTimeValue;
    }
    return dotenv.env[key] ?? '';
  }

  static String get supabaseUrl => _read(
        'SUPABASE_URL',
        const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
      );

  static String get supabasePublishableKey => _read(
        'SUPABASE_PUBLISHABLE_KEY',
        const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: ''),
      );

  static bool get configured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
