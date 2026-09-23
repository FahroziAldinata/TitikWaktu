package com.titikwaktu.alarm.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.titikwaktu.alarm.services.AlarmForegroundService

class AlarmReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        val scheduleId = intent.getStringExtra(EXTRA_SCHEDULE_ID) ?: run {
            Log.w("AlarmReceiver", "onReceive called without scheduleId")
            return
        }
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "Alarm"
        val description = intent.getStringExtra(EXTRA_DESCRIPTION) ?: ""
        val ringtoneUri = intent.getStringExtra(EXTRA_RINGTONE_URI)
        
        Log.i("AlarmReceiver", "🔥 onReceive: Triggering Alarm for schedule #$scheduleId: '$title', ringtone: $ringtoneUri")
        
        val serviceIntent = Intent(context, AlarmForegroundService::class.java).apply {
            putExtra(EXTRA_SCHEDULE_ID, scheduleId)
            putExtra(EXTRA_TITLE, title)
            putExtra(EXTRA_DESCRIPTION, description)
            if (!ringtoneUri.isNullOrEmpty()) {
                putExtra(EXTRA_RINGTONE_URI, ringtoneUri)
            }
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }

        // Direct startActivity saat alarm wake up dari AlarmManager
        try {
            val activityIntent = Intent(context, com.titikwaktu.alarm.AlarmRingingActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra(com.titikwaktu.alarm.AlarmRingingActivity.EXTRA_SCHEDULE_ID, scheduleId)
                putExtra(com.titikwaktu.alarm.AlarmRingingActivity.EXTRA_TITLE, title)
                putExtra(com.titikwaktu.alarm.AlarmRingingActivity.EXTRA_DESCRIPTION, description)
                if (!ringtoneUri.isNullOrEmpty()) {
                    putExtra(com.titikwaktu.alarm.AlarmRingingActivity.EXTRA_RINGTONE_URI, ringtoneUri)
                }
            }
            context.startActivity(activityIntent)
            Log.i("AlarmReceiver", "Direct startActivity(AlarmRingingActivity) from AlarmReceiver succeeded")
        } catch (e: Exception) {
            Log.w("AlarmReceiver", "Direct startActivity from AlarmReceiver skipped: ${e.message}")
        }
    }
    
    companion object {
        const val EXTRA_SCHEDULE_ID = "schedule_id"
        const val EXTRA_TITLE = "title"
        const val EXTRA_DESCRIPTION = "description"
        const val EXTRA_RINGTONE_URI = "ringtone_uri"
    }
}
