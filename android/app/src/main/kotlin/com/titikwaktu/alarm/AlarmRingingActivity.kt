package com.titikwaktu.alarm

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import com.titikwaktu.alarm.receivers.DismissReceiver
import com.titikwaktu.alarm.receivers.SnoozeReceiver
import com.titikwaktu.alarm.services.AlarmForegroundService
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmRingingActivity : Activity() {

    private var scheduleId: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Wake screen and show over lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        setContentView(R.layout.activity_alarm_ringing)

        scheduleId = intent.getStringExtra(EXTRA_SCHEDULE_ID) ?: ""
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "Alarm"
        val description = intent.getStringExtra(EXTRA_DESCRIPTION) ?: ""
        val ringtoneUri = intent.getStringExtra(EXTRA_RINGTONE_URI)

        val tvAlarmTime = findViewById<TextView>(R.id.tvAlarmTime)
        val tvAlarmDate = findViewById<TextView>(R.id.tvAlarmDate)
        val tvAlarmTitle = findViewById<TextView>(R.id.tvAlarmTitle)
        val tvAlarmDescription = findViewById<TextView>(R.id.tvAlarmDescription)
        val btnDismiss = findViewById<Button>(R.id.btnDismiss)
        val btnSnooze = findViewById<Button>(R.id.btnSnooze)

        // Set time and date in Indonesian format
        val now = Date()
        val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
        val dateFormat = SimpleDateFormat("EEEE, d MMMM yyyy", Locale("id", "ID"))
        tvAlarmTime.text = timeFormat.format(now)
        tvAlarmDate.text = dateFormat.format(now)

        tvAlarmTitle.text = title

        if (description.isNotBlank()) {
            tvAlarmDescription.text = description
            tvAlarmDescription.visibility = View.VISIBLE
        } else {
            tvAlarmDescription.visibility = View.GONE
        }

        // Dismiss action: hentikan audio service langsung dan kirim broadcast dismiss
        btnDismiss.setOnClickListener {
            Log.i("AlarmRingingActivity", "Matikan button clicked")
            try {
                stopService(Intent(this, AlarmForegroundService::class.java))
            } catch (e: Exception) {
                Log.e("AlarmRingingActivity", "Error stopping service: ${e.message}")
            }
            val dismissIntent = Intent(this, DismissReceiver::class.java).apply {
                putExtra(DismissReceiver.EXTRA_SCHEDULE_ID, scheduleId)
            }
            sendBroadcast(dismissIntent)
            finish()
        }

        // Snooze action: hentikan audio service langsung, jadwalkan snooze, dan teruskan ringtoneUri
        btnSnooze.setOnClickListener {
            Log.i("AlarmRingingActivity", "Tunda 5 Menit button clicked")
            try {
                stopService(Intent(this, AlarmForegroundService::class.java))
            } catch (e: Exception) {
                Log.e("AlarmRingingActivity", "Error stopping service: ${e.message}")
            }
            val snoozeIntent = Intent(this, SnoozeReceiver::class.java).apply {
                putExtra(SnoozeReceiver.EXTRA_SCHEDULE_ID, scheduleId)
                putExtra(SnoozeReceiver.EXTRA_TITLE, title)
                putExtra(SnoozeReceiver.EXTRA_DESCRIPTION, description)
                if (!ringtoneUri.isNullOrEmpty()) {
                    putExtra(SnoozeReceiver.EXTRA_RINGTONE_URI, ringtoneUri)
                }
                putExtra(SnoozeReceiver.EXTRA_SNOOZE_DURATION, 5 * 60 * 1000L)
            }
            sendBroadcast(snoozeIntent)
            finish()
        }
    }

    override fun onBackPressed() {
        // Prevent accidental dismissal via back button without explicit user action
        // User must tap "Matikan" or "Tunda"
    }

    companion object {
        const val EXTRA_SCHEDULE_ID = "schedule_id"
        const val EXTRA_TITLE = "title"
        const val EXTRA_DESCRIPTION = "description"
        const val EXTRA_RINGTONE_URI = "ringtone_uri"
    }
}
