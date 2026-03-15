import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

void main() {
  runApp(const ProviderScope(child: TactixApp()));
}

class TactixApp extends ConsumerWidget {
  const TactixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.buildTheme(),
      routerConfig: router,
    );
  }
}
