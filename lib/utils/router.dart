import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/features/categories/screens/manage_categories_screen.dart';
import 'package:titik_waktu/features/onboarding/screens/permission_onboarding_screen.dart';
import 'package:titik_waktu/features/permissions/screens/permission_management_screen.dart';
import 'package:titik_waktu/features/schedule/screens/home_screen.dart';
import 'package:titik_waktu/features/schedule/screens/add_schedule_screen.dart';
import 'package:titik_waktu/features/schedule/screens/schedule_detail_screen.dart';
import 'package:titik_waktu/features/alarm/screens/alarm_screen.dart';
import 'package:titik_waktu/features/calendar/screens/monthly_calendar_screen.dart';
import 'package:titik_waktu/features/history/screens/history_log_screen.dart';
import 'package:titik_waktu/features/onboarding/screens/miui_onboarding_wizard_screen.dart';
import 'package:titik_waktu/features/splash/screens/splash_screen.dart';

CustomTransitionPage<void> _buildSharedAxisPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/categories',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const ManageCategoriesScreen(),
      ),
    ),
    GoRoute(
      path: '/permissions/onboarding',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const PermissionOnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding/wizard',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const MiuiOnboardingWizardScreen(),
      ),
    ),
    GoRoute(
      path: '/permissions',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const PermissionManagementScreen(),
      ),
    ),
    GoRoute(
      path: '/add',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const AddScheduleScreen(),
      ),
    ),
    GoRoute(
      path: '/edit/:id',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: AddScheduleScreen(
          scheduleId: state.pathParameters['id'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: '/schedule/:id',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: ScheduleDetailScreen(
          scheduleId: state.pathParameters['id'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: '/calendar',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const MonthlyCalendarScreen(),
      ),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const HistoryLogScreen(),
      ),
    ),
    GoRoute(
      path: '/alarm/:id',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: AlarmScreen(
          scheduleId: state.pathParameters['id'] ?? '',
        ),
      ),
    ),
  ],
);
