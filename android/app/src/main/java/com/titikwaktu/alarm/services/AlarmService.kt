package com.titikwaktu.alarm.services

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import com.titikwaktu.alarm.receivers.AlarmReceiver

import android.util.Log

class AlarmService(private val context: Context) {
    
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    
    fun scheduleAlarm(
        scheduleId: String,
        triggerTimeMillis: Long,
        title: String,
        description: String
    ) {
        Log.i("NativeAlarmService", "⏰ scheduleAlarm called for schedule #$scheduleId at $triggerTimeMillis ('$title')")
        
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra(AlarmReceiver.EXTRA_SCHEDULE_ID, scheduleId)
            putExtra(AlarmReceiver.EXTRA_TITLE, title)
            putExtra(AlarmReceiver.EXTRA_DESCRIPTION, description)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            scheduleId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val clockInfo = AlarmManager.AlarmClockInfo(triggerTimeMillis, pendingIntent)
                alarmManager.setAlarmClock(clockInfo, pendingIntent)
                Log.i("NativeAlarmService", "✅ setAlarmClock succeeded for #$scheduleId at $triggerTimeMillis")
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
                Log.i("NativeAlarmService", "✅ setExactAndAllowWhileIdle succeeded for #$scheduleId")
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
            }
        } catch (e: Exception) {
            Log.e("NativeAlarmService", "❌ Failed to setAlarmClock: ${e.message}", e)
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerTimeMillis,
                        pendingIntent
                    )
                }
            } catch (ex: Exception) {
                Log.e("NativeAlarmService", "❌ Fallback setExactAndAllowWhileIdle failed: ${ex.message}", ex)
            }
        }
    }
    
    fun cancelAlarm(scheduleId: String) {
        val intent = Intent(context, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            scheduleId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        alarmManager.cancel(pendingIntent)
    }
    
    fun rescheduleAllAlarms(schedules: List<Map<String, Any>>) {
        for (schedule in schedules) {
            val id = schedule["id"] as? String ?: continue
            val timeMillis = schedule["timeMillis"] as? Long ?: continue
            val title = schedule["title"] as? String ?: ""
            val description = schedule["description"] as? String ?: ""
            val isActive = schedule["isActive"] as? Boolean ?: true
            
            if (isActive) {
                if (timeMillis > System.currentTimeMillis()) {
                    scheduleAlarm(id, timeMillis, title, description)
                }
            }
        }
    }
}
