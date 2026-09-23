package com.titikwaktu.alarm.receivers

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.titikwaktu.alarm.services.AlarmForegroundService

class SnoozeReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        val scheduleId = intent.getStringExtra(EXTRA_SCHEDULE_ID) ?: return
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "Alarm Ditunda"
        val description = intent.getStringExtra(EXTRA_DESCRIPTION) ?: "Alarm akan berbunyi lagi"
        val ringtoneUri = intent.getStringExtra(EXTRA_RINGTONE_URI)
        val snoozeDuration = intent.getLongExtra(EXTRA_SNOOZE_DURATION, DEFAULT_SNOOZE_DURATION)
        
        Log.i("SnoozeReceiver", "💤 Snooze received for schedule #$scheduleId ($snoozeDuration ms, ringtone: $ringtoneUri)")
        
        // 1. Hentikan AlarmForegroundService yang sedang berbunyi
        try {
            val stopIntent = Intent(context, AlarmForegroundService::class.java)
            context.stopService(stopIntent)
            Log.i("SnoozeReceiver", "AlarmForegroundService stopped successfully")
        } catch (e: Exception) {
            Log.e("SnoozeReceiver", "Failed to stop AlarmForegroundService: ${e.message}", e)
        }
        
        // 2. Jadwalkan alarm baru 5 menit ke depan menggunakan setAlarmClock
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val triggerTimeMillis = System.currentTimeMillis() + snoozeDuration
            
            val alarmIntent = Intent(context, AlarmReceiver::class.java).apply {
                putExtra(AlarmReceiver.EXTRA_SCHEDULE_ID, scheduleId)
                putExtra(AlarmReceiver.EXTRA_TITLE, title)
                putExtra(AlarmReceiver.EXTRA_DESCRIPTION, description)
                if (!ringtoneUri.isNullOrEmpty()) {
                    putExtra(AlarmReceiver.EXTRA_RINGTONE_URI, ringtoneUri)
                }
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                scheduleId.hashCode() + 1000,
                alarmIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val clockInfo = AlarmManager.AlarmClockInfo(triggerTimeMillis, pendingIntent)
                alarmManager.setAlarmClock(clockInfo, pendingIntent)
                Log.i("SnoozeReceiver", "✅ setAlarmClock succeeded for snoozed alarm at $triggerTimeMillis")
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
            }
        } catch (e: Exception) {
            Log.e("SnoozeReceiver", "❌ Failed to schedule snooze alarm: ${e.message}", e)
        }
    }
    
    companion object {
        const val EXTRA_SCHEDULE_ID = "schedule_id"
        const val EXTRA_TITLE = "title"
        const val EXTRA_DESCRIPTION = "description"
        const val EXTRA_RINGTONE_URI = "ringtone_uri"
        const val EXTRA_SNOOZE_DURATION = "snooze_duration"
        const val DEFAULT_SNOOZE_DURATION = 5 * 60 * 1000L // 5 minutes
    }
}
