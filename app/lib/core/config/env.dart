import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads required config from the local .env file (see .env.example).
/// Throws immediately at startup if a required key is missing, rather than
/// failing confusingly later inside a Supabase call.
class Env {
  Env._();

  static String get supabaseUrl => _require('SUPABASE_URL');
  static String get supabasePublishableKey => _require('SUPABASE_PUBLISHABLE_KEY');

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required env var "$key". Copy .env.example to .env and '
        'fill in your Supabase project values (see app/README.md).',
      );
    }
    return value;
  }
}
