package com.titikwaktu.alarm.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.app.AlarmManager

class SnoozeReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        val scheduleId = intent.getStringExtra(EXTRA_SCHEDULE_ID) ?: return
        val snoozeDuration = intent.getLongExtra(EXTRA_SNOOZE_DURATION, DEFAULT_SNOOZE_DURATION)
        
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = createAlarmPendingIntent(context, scheduleId)
        
        val triggerTime = SystemClock.elapsedRealtime() + snoozeDuration
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerTime,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerTime,
                pendingIntent
            )
        }
    }
    
    private fun createAlarmPendingIntent(context: Context, scheduleId: String): android.app.PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra(AlarmReceiver.EXTRA_SCHEDULE_ID, scheduleId)
            putExtra(AlarmReceiver.EXTRA_TITLE, "Alarm Ditunda")
            putExtra(AlarmReceiver.EXTRA_DESCRIPTION, "Alarm akan berbunyi lagi")
        }
        
        return android.app.PendingIntent.getBroadcast(
            context,
            scheduleId.hashCode(),
            intent,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
        )
    }
    
    companion object {
        const val EXTRA_SCHEDULE_ID = "schedule_id"
        const val EXTRA_SNOOZE_DURATION = "snooze_duration"
        const val DEFAULT_SNOOZE_DURATION = 5 * 60 * 1000L // 5 minutes
    }
}
