import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/features/categories/screens/bulk_time_setter_screen.dart';
import 'package:titik_waktu/features/categories/screens/category_calendar_picker_screen.dart';
import 'package:titik_waktu/features/categories/screens/category_detail_screen.dart';
import 'package:titik_waktu/features/categories/screens/manage_categories_screen.dart';
import 'package:titik_waktu/features/main/main_shell_screen.dart';
import 'package:titik_waktu/features/onboarding/screens/permission_onboarding_screen.dart';
import 'package:titik_waktu/features/permissions/screens/permission_management_screen.dart';
import 'package:titik_waktu/features/schedule/screens/home_screen.dart';
import 'package:titik_waktu/features/schedule/screens/add_schedule_screen.dart';
import 'package:titik_waktu/features/schedule/screens/schedule_detail_screen.dart';
import 'package:titik_waktu/features/settings/screens/settings_screen.dart';
import 'package:titik_waktu/features/alarm/screens/alarm_screen.dart';
import 'package:titik_waktu/features/calendar/screens/monthly_calendar_screen.dart';
import 'package:titik_waktu/features/history/screens/history_log_screen.dart';
import 'package:titik_waktu/features/onboarding/screens/miui_onboarding_wizard_screen.dart';
import 'package:titik_waktu/features/splash/screens/splash_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

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
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/splash',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/categories',
              pageBuilder: (context, state) => _buildSharedAxisPage(
                key: state.pageKey,
                child: const ManageCategoriesScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => _buildSharedAxisPage(
                key: state.pageKey,
                child: const HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => _buildSharedAxisPage(
                key: state.pageKey,
                child: const SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/categories/:id',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: CategoryDetailScreen(
          categoryId: int.parse(state.pathParameters['id'] ?? '0'),
        ),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/categories/:id/calendar',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: CategoryCalendarPickerScreen(
          category: state.extra as Category,
        ),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/categories/:id/bulk-time',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: BulkTimeSetterScreen(
          category: state.extra as Category,
        ),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/permissions/onboarding',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const PermissionOnboardingScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/onboarding/wizard',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const MiuiOnboardingWizardScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/permissions',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const PermissionManagementScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/add',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const AddScheduleScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/edit/:id',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: AddScheduleScreen(
          scheduleId: state.pathParameters['id'] ?? '',
        ),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/schedule/:id',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: ScheduleDetailScreen(
          scheduleId: state.pathParameters['id'] ?? '',
        ),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/calendar',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const MonthlyCalendarScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/history',
      pageBuilder: (context, state) => _buildSharedAxisPage(
        key: state.pageKey,
        child: const HistoryLogScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
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
