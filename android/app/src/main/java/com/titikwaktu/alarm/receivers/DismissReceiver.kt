package com.titikwaktu.alarm.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.titikwaktu.alarm.services.AlarmForegroundService

class DismissReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        val scheduleId = intent.getStringExtra(EXTRA_SCHEDULE_ID) ?: return
        Log.i("DismissReceiver", "🛑 Dismiss received for schedule #$scheduleId: stopping service")
        try {
            val serviceIntent = Intent(context, AlarmForegroundService::class.java)
            context.stopService(serviceIntent)
        } catch (e: Exception) {
            Log.e("DismissReceiver", "Failed to stop service: ${e.message}", e)
        }
    }
    
    companion object {
        const val EXTRA_SCHEDULE_ID = "schedule_id"
    }
}
