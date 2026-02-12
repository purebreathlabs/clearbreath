import 'package:go_router/go_router.dart';

import '../../features/design_system/presentation/design_system_screen.dart';
import '../../features/home/presentation/home_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/design-system',
      builder: (context, state) => const DesignSystemScreen(),
    ),
  ],
);
