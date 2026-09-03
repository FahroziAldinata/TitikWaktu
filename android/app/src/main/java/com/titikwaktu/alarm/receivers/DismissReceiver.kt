package com.titikwaktu.alarm.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.titikwaktu.alarm.services.AlarmForegroundService

class DismissReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        val scheduleId = intent.getStringExtra(EXTRA_SCHEDULE_ID) ?: return
        
        val serviceIntent = Intent(context, AlarmForegroundService::class.java).apply {
            putExtra(AlarmForegroundService.ACTION_DISMISS, true)
            putExtra(EXTRA_SCHEDULE_ID, scheduleId)
        }
        
        context.startService(serviceIntent)
    }
    
    companion object {
        const val EXTRA_SCHEDULE_ID = "schedule_id"
    }
}
