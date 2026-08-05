import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // English-first UI chrome per docs/PRD.md decision — locale controls
      // date/number formatting only, not a bilingual UI toggle in v1.
      routerConfig: router,
    );
  }
}
