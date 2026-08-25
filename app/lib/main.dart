import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/supabase_service.dart';
import 'core/startup/startup_failure_app.dart';
import 'features/settings/presentation/providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _start();
}

/// Startup always ends in a `runApp` — either the real app or a screen that
/// explains why it couldn't start. Letting an exception escape `main`
/// instead leaves the user at a black window with no error, no spinner, and
/// no way to retry, which is exactly what a stale refresh token used to
/// produce (see [initSupabase] on why init is time-bounded).
Future<void> _start() async {
  try {
    await dotenv.load(fileName: '.env');
    await initSupabase();
  } catch (error, stackTrace) {
    debugPrint('Startup failed: $error\n$stackTrace');
    runApp(StartupFailureApp(error: error, onRetry: _retryStart));
    return;
  }

  runApp(_app());
}

/// The root scope, built in one place so both start paths below get the
/// same overrides. [settingsOverrides] is what points the app's Hijri and
/// prayer-calculation seams at the user's saved preferences — without it
/// the app runs on the built-in defaults and the Settings screen appears
/// to do nothing.
Widget _app() => ProviderScope(overrides: settingsOverrides, child: const TadabburApp());

/// Retries startup in place. Returns false if it failed again, leaving the
/// failure screen up so the user can try once more; on success the running
/// app has already been replaced by [_start].
Future<bool> _retryStart() async {
  try {
    await dotenv.load(fileName: '.env');
    await initSupabase();
  } catch (error) {
    debugPrint('Startup retry failed: $error');
    return false;
  }
  runApp(_app());
  return true;
}
