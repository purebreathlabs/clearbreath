import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/data/fcm_token_service.dart';
import 'features/notifications/domain/fcm_foreground_handler.dart';
import 'features/notifications/domain/notification_controller.dart';
import 'features/stats/domain/stats_engine.dart';
import 'features/stats/domain/weekly_minutes_provider.dart';
import 'features/sync/domain/merged_stats_provider.dart';
import 'features/sync/domain/sync_controller.dart';
import 'features/xp/domain/xp_provider.dart';

class ClearBreathApp extends ConsumerStatefulWidget {
  const ClearBreathApp({super.key});

  @override
  ConsumerState<ClearBreathApp> createState() => _ClearBreathAppState();
}

class _ClearBreathAppState extends ConsumerState<ClearBreathApp>
    with WidgetsBindingObserver {
  final _fcmForegroundHandler = FCMForegroundHandler();
  bool _fcmInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFCM();
  }

  Future<void> _initFCM() async {
    if (_fcmInitialized) return;
    _fcmInitialized = true;
    await _fcmForegroundHandler.initialize();
    await ref.read(fcmTokenServiceProvider).initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(mergedStatsProvider);
      ref.invalidate(localStatsProvider);
      ref.invalidate(localWeeklyMinutesProvider);
      ref.invalidate(cloudWeeklyMinutesProvider);
      ref.invalidate(mergedWeeklyMinutesProvider);
      ref.invalidate(mergedXPProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
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
