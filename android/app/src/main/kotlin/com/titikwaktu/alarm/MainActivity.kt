package com.titikwaktu.alarm

import android.app.AlarmManager
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import io.flutter.embedding.engine.FlutterEngineCache
import com.titikwaktu.alarm.services.AlarmService

class MainActivity : FlutterFragmentActivity() {

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

        private const val RINGTONE_PICKER_CHANNEL = "com.titikwaktu.alarm/ringtone_picker"
        private const val METHOD_PICK_SYSTEM_RINGTONE = "pickSystemRingtone"
        private const val METHOD_TAKE_PERSISTABLE_URI_PERMISSION = "takePersistableUriPermission"
        private const val METHOD_GET_RINGTONE_TITLE = "getRingtoneTitle"
    }

    private val alarmService by lazy { AlarmService(this) }
    private var pendingRingtoneResult: MethodChannel.Result? = null

    private val ringtonePickerLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { activityResult ->
        val data = activityResult.data
        val pickedUri: Uri? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
        }

        if (pickedUri != null) {
            val title = try {
                val ringtone = RingtoneManager.getRingtone(this, pickedUri)
                ringtone?.getTitle(this) ?: pickedUri.lastPathSegment ?: "Ringtone"
            } catch (e: Exception) {
                pickedUri.lastPathSegment ?: "Ringtone"
            }
            pendingRingtoneResult?.success(mapOf(
                "uri" to pickedUri.toString(),
                "title" to title
            ))
        } else {
            pendingRingtoneResult?.success(null)
        }
        pendingRingtoneResult = null
    }

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
                    val ringtoneUri = call.argument<String>("ringtoneUri")
                    
                    if (scheduleId.isNotEmpty() && triggerTimeMillis > 0L) {
                        alarmService.scheduleAlarm(scheduleId, triggerTimeMillis, title, description, ringtoneUri)
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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RINGTONE_PICKER_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_PICK_SYSTEM_RINGTONE -> {
                    val currentUriStr = call.argument<String>("currentUri")
                    val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                        putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
                        if (!currentUriStr.isNullOrEmpty()) {
                            putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, Uri.parse(currentUriStr))
                        }
                    }
                    pendingRingtoneResult = result
                    ringtonePickerLauncher.launch(intent)
                }
                METHOD_TAKE_PERSISTABLE_URI_PERMISSION -> {
                    val uriStr = call.argument<String>("uri")
                    if (!uriStr.isNullOrEmpty()) {
                        try {
                            val uri = Uri.parse(uriStr)
                            val takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                            contentResolver.takePersistableUriPermission(uri, takeFlags)
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e("MainActivity", "Failed to take persistable URI permission: ${e.message}", e)
                            result.error("PERMISSION_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Missing URI", null)
                    }
                }
                METHOD_GET_RINGTONE_TITLE -> {
                    val uriStr = call.argument<String>("uri")
                    if (!uriStr.isNullOrEmpty()) {
                        try {
                            val uri = Uri.parse(uriStr)
                            val ringtone = RingtoneManager.getRingtone(this, uri)
                            val title = ringtone?.getTitle(this) ?: uri.lastPathSegment ?: "Ringtone"
                            result.success(title)
                        } catch (e: Exception) {
                            result.success(null)
                        }
                    } else {
                        result.success(null)
                    }
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
