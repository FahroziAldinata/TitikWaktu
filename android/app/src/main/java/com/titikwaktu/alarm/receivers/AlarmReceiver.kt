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
        
        Log.i("AlarmReceiver", "🔥 onReceive: Triggering Alarm for schedule #$scheduleId: '$title'")
        
        val serviceIntent = Intent(context, AlarmForegroundService::class.java).apply {
            putExtra(EXTRA_SCHEDULE_ID, scheduleId)
            putExtra(EXTRA_TITLE, title)
            putExtra(EXTRA_DESCRIPTION, description)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
    
    companion object {
        const val EXTRA_SCHEDULE_ID = "schedule_id"
        const val EXTRA_TITLE = "title"
        const val EXTRA_DESCRIPTION = "description"
    }
}
