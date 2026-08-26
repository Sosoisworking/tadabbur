import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/platform/display_insets.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class TadabburApp extends ConsumerWidget {
  const TadabburApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Tadabbur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      // English-first UI chrome per docs/PRD.md decision — locale controls
      // date/number formatting only, not a bilingual UI toggle in v1.
      routerConfig: router,
      // Web only: hands SafeArea and MediaQuery.viewPaddingOf the real
      // env(safe-area-inset-*) values, which the web engine otherwise pins to
      // zero, and tops up MediaQuery.viewInsets with a visualViewport
      // measurement of the on-screen keyboard for the cases the engine's own
      // keyboard tracking does not catch. No-op on native, and on any page
      // with no safe area and no keyboard.
      builder: (context, child) =>
          DisplayInsets(child: child ?? const SizedBox.shrink()),
    );
  }
}
