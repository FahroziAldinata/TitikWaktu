package com.titikwaktu.alarm.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.plugin.common.MethodChannel

class BootReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        android.util.Log.i("BootReceiver", "🚀 onReceive: action=${intent.action}")
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON" ||
            intent.action == "com.htc.intent.action.QUICKBOOT_POWERON" ||
            intent.action == "android.intent.action.MY_PACKAGE_REPLACED") {
            
            rescheduleAllAlarms(context)
        }
    }
    
    private fun rescheduleAllAlarms(context: Context) {
        android.util.Log.i("BootReceiver", "🔄 rescheduleAllAlarms called")
        try {
            val engine = FlutterEngineCache.getInstance().get("main_engine")
            
            if (engine != null) {
                val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.titikwaktu.alarm/native_alarm")
                channel.invokeMethod("rescheduleAllAlarms", null)
            } else {
                // Start Flutter engine if not cached
                val flutterEngine = FlutterEngine(context.applicationContext)
                flutterEngine.dartExecutor.executeDartEntrypoint(
                    DartEntrypoint.createDefault()
                )
                
                val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.titikwaktu.alarm/native_alarm")
                channel.invokeMethod("rescheduleAllAlarms", null)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
