package com.titikwaktu.alarm

import android.app.AlarmManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import io.flutter.embedding.engine.FlutterEngineCache
import com.titikwaktu.alarm.services.AlarmService

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.titikwaktu.alarm/battery_optimization"
        private const val METHOD_OPEN_BATTERY_OPTIMIZATION_SETTINGS = "openBatteryOptimizationSettings"
        private const val METHOD_OPEN_AUTOSTART_SETTINGS = "openAutostartSettings"
        private const val METHOD_OPEN_NOTIFICATION_SETTINGS = "openNotificationSettings"
        private const val METHOD_OPEN_APP_DETAILS_SETTINGS = "openAppDetailsSettings"

        private const val EXACT_ALARM_CHANNEL = "com.titikwaktu.alarm/exact_alarm"
        private const val METHOD_CAN_SCHEDULE_EXACT_ALARMS = "canScheduleExactAlarms"
        private const val METHOD_REQUEST_EXACT_ALARM_PERMISSION = "requestExactAlarmPermission"

        private const val NATIVE_ALARM_CHANNEL = "com.titikwaktu.alarm/native_alarm"
        private const val METHOD_SCHEDULE_ALARM = "scheduleAlarm"
        private const val METHOD_CANCEL_ALARM = "cancelAlarm"
        private const val METHOD_RESCHEDULE_ALL = "rescheduleAllAlarms"
    }

    private val alarmService by lazy { AlarmService(this) }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                android.view.WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                android.view.WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                android.view.WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineCache.getInstance().put("main_engine", flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_OPEN_BATTERY_OPTIMIZATION_SETTINGS -> {
                    openBatteryOptimizationSettings()
                    result.success(true)
                }
                METHOD_OPEN_AUTOSTART_SETTINGS -> {
                    openAutostartSettings()
                    result.success(true)
                }
                METHOD_OPEN_NOTIFICATION_SETTINGS -> {
                    openNotificationSettings()
                    result.success(true)
                }
                METHOD_OPEN_APP_DETAILS_SETTINGS -> {
                    openAppDetailsSettings()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EXACT_ALARM_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_CAN_SCHEDULE_EXACT_ALARMS -> {
                    result.success(canScheduleExactAlarms())
                }
                METHOD_REQUEST_EXACT_ALARM_PERMISSION -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        requestExactAlarmPermission()
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NATIVE_ALARM_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_SCHEDULE_ALARM -> {
                    val scheduleId = call.argument<Any>("scheduleId")?.toString() ?: ""
                    val triggerTimeMillis = (call.argument<Number>("triggerTimeMillis"))?.toLong() ?: 0L
                    val title = call.argument<String>("title") ?: "Alarm"
                    val description = call.argument<String>("description") ?: ""
                    
                    if (scheduleId.isNotEmpty() && triggerTimeMillis > 0L) {
                        alarmService.scheduleAlarm(scheduleId, triggerTimeMillis, title, description)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "Missing scheduleId or triggerTimeMillis", null)
                    }
                }
                METHOD_CANCEL_ALARM -> {
                    val scheduleId = call.argument<Any>("scheduleId")?.toString() ?: ""
                    if (scheduleId.isNotEmpty()) {
                        alarmService.cancelAlarm(scheduleId)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "Missing scheduleId", null)
                    }
                }
                METHOD_RESCHEDULE_ALL -> {
                    val schedules = call.argument<List<Map<String, Any>>>("schedules") ?: emptyList()
                    alarmService.rescheduleAllAlarms(schedules)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun canScheduleExactAlarms(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
        return alarmManager.canScheduleExactAlarms()
    }

    private fun requestExactAlarmPermission() {
        try {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
        } catch (e: Exception) {
            val fallbackIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(fallbackIntent)
        }
    }

    private fun openBatteryOptimizationSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val pm = getSystemService(POWER_SERVICE) as PowerManager
            val packageName = packageName
            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                try {
                    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                        data = Uri.parse("package:$packageName")
                    }
                    startActivity(intent)
                } catch (e: Exception) {
                    val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    startActivity(fallbackIntent)
                }
            } else {
                val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                startActivity(fallbackIntent)
            }
        }
    }

    private fun openAutostartSettings() {
        // Try MIUI specific AutoStart intent first
        val miuiIntents = listOf(
            Intent().setComponent(android.content.ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")),
            Intent("miui.intent.action.OP_AUTO_START").addCategory(Intent.CATEGORY_DEFAULT),
            Intent().setComponent(android.content.ComponentName("com.letv.android.letvsafe", "com.letv.android.letvsafe.AutobootManageActivity")),
            Intent().setComponent(android.content.ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity")),
            Intent().setComponent(android.content.ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity")),
            Intent().setComponent(android.content.ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity")),
            Intent().setComponent(android.content.ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity")),
            Intent().setComponent(android.content.ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"))
        )

        for (intent in miuiIntents) {
            try {
                startActivity(intent)
                return
            } catch (_: Exception) {}
        }

        // Fallback to app details
        openAppDetailsSettings()
    }

    private fun openNotificationSettings() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                }
                startActivity(intent)
                return
            }
        } catch (_: Exception) {}

        openAppDetailsSettings()
    }

    private fun openAppDetailsSettings() {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
        } catch (_: Exception) {}
    }
}
