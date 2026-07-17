import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/profile_screen.dart';
import '../../features/exercises/presentation/screens/exercises_screen.dart';
import '../../features/exercises/presentation/screens/exercise_detail_screen.dart';
import '../../features/ai_coach/presentation/screens/ai_coach_screen.dart';
import '../../features/alarms/presentation/screens/alarms_screen.dart';
import '../../features/alarms/presentation/screens/add_alarm_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../theme/app_theme.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const profile = '/profile';
  static const home           = '/home';
  static const exercises      = '/exercises';
  static const exerciseDetail = '/exercise/:id';
  static const aiCoach        = '/ai-coach/:id';
  static const alarms         = '/alarms';
  static const addAlarm       = '/alarms/add';
  static const stats          = '/stats';
}

class AppRouter {
  AppRouter._();

  static final _rootKey  = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      // Shell con BottomNavigationBar
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.exercises,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ExercisesScreen()),
          ),
          GoRoute(
            path: AppRoutes.stats,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: StatsScreen()),
          ),
          GoRoute(
            path: AppRoutes.alarms,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: AlarmsScreen()),
          ),
        ],
      ),

      // Pantallas de pantalla completa (sin nav bar)
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: AppRoutes.exerciseDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ExerciseDetailScreen(exerciseId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: AppRoutes.aiCoach,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AiCoachScreen(exerciseId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: AppRoutes.addAlarm,
        builder: (context, state) => const AddAlarmScreen(),
      ),
    ],
  );
}

// ── Shell con BottomNavigationBar ─────────────────────────────────────────────

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/exercises')) return 1;
    if (loc.startsWith('/stats'))     return 2;
    if (loc.startsWith('/alarms'))    return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(
        currentIndex: _selectedIndex(context),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0: context.go(AppRoutes.home);      break;
            case 1: context.go(AppRoutes.exercises); break;
            case 2: context.go(AppRoutes.stats);     break;
            case 3: context.go(AppRoutes.alarms);    break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement_outlined),
            activeIcon: Icon(Icons.self_improvement_rounded),
            label: 'Ejercicios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm_outlined),
            activeIcon: Icon(Icons.alarm_rounded),
            label: 'Alarmas',
          ),
        ],
      ),
    );
  }
}