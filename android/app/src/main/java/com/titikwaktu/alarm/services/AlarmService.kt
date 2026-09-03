package com.titikwaktu.alarm.services

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import com.titikwaktu.alarm.receivers.AlarmReceiver

class AlarmService(private val context: Context) {
    
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    
    fun scheduleAlarm(
        scheduleId: String,
        triggerTimeMillis: Long,
        title: String,
        description: String
    ) {
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
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
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
