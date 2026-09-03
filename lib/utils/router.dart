import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/features/schedule/screens/home_screen.dart';
import 'package:titik_waktu/features/schedule/screens/add_schedule_screen.dart';
import 'package:titik_waktu/features/schedule/screens/schedule_detail_screen.dart';
import 'package:titik_waktu/features/alarm/screens/alarm_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddScheduleScreen(),
    ),
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) => AddScheduleScreen(
        scheduleId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/schedule/:id',
      builder: (context, state) => ScheduleDetailScreen(
        scheduleId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/alarm/:id',
      builder: (context, state) => AlarmScreen(
        scheduleId: state.pathParameters['id']!,
      ),
    ),
  ],
);
