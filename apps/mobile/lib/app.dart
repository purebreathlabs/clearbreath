import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/domain/notification_controller.dart';
import 'features/sync/domain/sync_controller.dart';

class ClearBreathApp extends ConsumerWidget {
  const ClearBreathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    ref.watch(notificationControllerProvider);
    ref.watch(syncControllerProvider);
    return MaterialApp.router(
      title: 'ClearBreath',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
