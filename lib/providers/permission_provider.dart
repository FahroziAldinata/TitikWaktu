import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titik_waktu/services/permission_service.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

class PermissionState {
  final bool notificationGranted;
  final bool exactAlarmGranted;
  final bool batteryOptimizationGranted;
  final bool onboardingComplete;
  final bool isLoading;

  const PermissionState({
    this.notificationGranted = false,
    this.exactAlarmGranted = false,
    this.batteryOptimizationGranted = false,
    this.onboardingComplete = false,
    this.isLoading = true,
  });

  bool get allCriticalGranted => notificationGranted && exactAlarmGranted;

  bool get allGranted =>
      notificationGranted && exactAlarmGranted && batteryOptimizationGranted;

  PermissionState copyWith({
    bool? notificationGranted,
    bool? exactAlarmGranted,
    bool? batteryOptimizationGranted,
    bool? onboardingComplete,
    bool? isLoading,
  }) {
    return PermissionState(
      notificationGranted: notificationGranted ?? this.notificationGranted,
      exactAlarmGranted: exactAlarmGranted ?? this.exactAlarmGranted,
      batteryOptimizationGranted:
          batteryOptimizationGranted ?? this.batteryOptimizationGranted,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PermissionNotifier extends StateNotifier<PermissionState> {
  final PermissionService _permissionService;

  PermissionNotifier(this._permissionService) : super(const PermissionState()) {
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    state = state.copyWith(isLoading: true);

    final notificationGranted =
        await _permissionService.isNotificationPermissionGranted();
    final exactAlarmGranted = await _permissionService.canScheduleExactAlarms();
    final batteryOptGranted =
        await _permissionService.isIgnoringBatteryOptimizations();

    state = state.copyWith(
      notificationGranted: notificationGranted,
      exactAlarmGranted: exactAlarmGranted,
      batteryOptimizationGranted: batteryOptGranted,
      onboardingComplete: notificationGranted && exactAlarmGranted,
      isLoading: false,
    );
  }

  Future<PermissionResult> requestNotificationPermission() async {
    final result = await _permissionService.requestNotificationPermission();
    state = state.copyWith(
      notificationGranted: result.isGranted,
      onboardingComplete: result.isGranted && state.exactAlarmGranted,
    );
    return result;
  }

  Future<PermissionResult> requestExactAlarmPermission() async {
    final result = await _permissionService.requestExactAlarmPermission();
    state = state.copyWith(
      exactAlarmGranted: result.isGranted,
      onboardingComplete: state.notificationGranted && result.isGranted,
    );
    return result;
  }

  Future<PermissionResult> requestBatteryOptimization() async {
    final result = await _permissionService.requestIgnoreBatteryOptimization();
    state = state.copyWith(batteryOptimizationGranted: result.isGranted);
    return result;
  }

  Future<void> openBatterySettings() async {
    await _permissionService.openBatteryOptimizationSettings();
    final granted = await _permissionService.isIgnoringBatteryOptimizations();
    state = state.copyWith(batteryOptimizationGranted: granted);
  }

  Future<void> openAppSettingsPage() async {
    await _permissionService.openAppSettings();
  }

  Future<void> refreshPermissions() async {
    await _checkAllPermissions();
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingComplete: true);
  }
}

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
  return PermissionNotifier(ref.read(permissionServiceProvider));
});
