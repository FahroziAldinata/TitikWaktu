import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

enum AppPermission {
  notification,
  exactAlarm,
  batteryOptimization,
  ignoreBatteryOptimization,
}

class PermissionResult {
  final AppPermission permission;
  final bool isGranted;
  final bool isPermanentlyDenied;

  const PermissionResult({
    required this.permission,
    required this.isGranted,
    this.isPermanentlyDenied = false,
  });
}

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  static const MethodChannel _channel = MethodChannel(
    'com.titikwaktu.alarm/battery_optimization',
  );

  static const MethodChannel _exactAlarmChannel = MethodChannel(
    'com.titikwaktu.alarm/exact_alarm',
  );

  Future<bool> isNotificationPermissionGranted() async {
    if (!Platform.isAndroid) return true;
    final status = await ph.Permission.notification.status;
    return status.isGranted;
  }

  Future<PermissionResult> requestNotificationPermission() async {
    if (!Platform.isAndroid) {
      return const PermissionResult(
        permission: AppPermission.notification,
        isGranted: true,
      );
    }

    final status = await ph.Permission.notification.request();
    return PermissionResult(
      permission: AppPermission.notification,
      isGranted: status.isGranted,
      isPermanentlyDenied: status.isPermanentlyDenied,
    );
  }

  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    return await _exactAlarmChannel.invokeMethod<bool>('canScheduleExactAlarms') ??
        false;
  }

  Future<PermissionResult> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) {
      return const PermissionResult(
        permission: AppPermission.exactAlarm,
        isGranted: true,
      );
    }

    final canSchedule = await canScheduleExactAlarms();
    if (canSchedule) {
      return const PermissionResult(
        permission: AppPermission.exactAlarm,
        isGranted: true,
      );
    }

    final granted = await _requestExactAlarmThroughSettings();
    return PermissionResult(
      permission: AppPermission.exactAlarm,
      isGranted: granted,
      isPermanentlyDenied: !granted,
    );
  }

  Future<bool> _requestExactAlarmThroughSettings() async {
    try {
      await _exactAlarmChannel.invokeMethod('requestExactAlarmPermission');
    } on PlatformException {
      return false;
    }
    return canScheduleExactAlarms();
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    return await ph.Permission.ignoreBatteryOptimizations.isGranted;
  }

  Future<PermissionResult> requestIgnoreBatteryOptimization() async {
    if (!Platform.isAndroid) {
      return const PermissionResult(
        permission: AppPermission.batteryOptimization,
        isGranted: true,
      );
    }

    final status = await ph.Permission.ignoreBatteryOptimizations.request();
    return PermissionResult(
      permission: AppPermission.batteryOptimization,
      isGranted: status.isGranted,
      isPermanentlyDenied: status.isPermanentlyDenied,
    );
  }

  Future<bool> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return true;
    try {
      await _channel.invokeMethod('openBatteryOptimizationSettings');
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> openAutostartSettings() async {
    if (!Platform.isAndroid) return true;
    try {
      await _channel.invokeMethod('openAutostartSettings');
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> openNotificationSettings() async {
    if (!Platform.isAndroid) return true;
    try {
      await _channel.invokeMethod('openNotificationSettings');
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> openAppDetailsSettings() async {
    if (!Platform.isAndroid) return true;
    try {
      await _channel.invokeMethod('openAppDetailsSettings');
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  Future<bool> areCriticalPermissionsGranted() async {
    final notificationGranted = await isNotificationPermissionGranted();
    final exactAlarmGranted = await canScheduleExactAlarms();
    return notificationGranted && exactAlarmGranted;
  }

  Future<List<PermissionResult>> requestAllCriticalPermissions() async {
    final results = <PermissionResult>[];

    final notificationResult = await requestNotificationPermission();
    results.add(notificationResult);

    final exactAlarmResult = await requestExactAlarmPermission();
    results.add(exactAlarmResult);

    return results;
  }

  Future<PermissionResult> getPermissionStatus(AppPermission permission) async {
    switch (permission) {
      case AppPermission.notification:
        final status = await ph.Permission.notification.status;
        return PermissionResult(
          permission: permission,
          isGranted: status.isGranted,
          isPermanentlyDenied: status.isPermanentlyDenied,
        );
      case AppPermission.exactAlarm:
        final granted = await canScheduleExactAlarms();
        return PermissionResult(
          permission: permission,
          isGranted: granted,
          isPermanentlyDenied: !granted,
        );
      case AppPermission.batteryOptimization:
      case AppPermission.ignoreBatteryOptimization:
        final granted = await isIgnoringBatteryOptimizations();
        return PermissionResult(
          permission: permission,
          isGranted: granted,
          isPermanentlyDenied: false,
        );
    }
  }
}
