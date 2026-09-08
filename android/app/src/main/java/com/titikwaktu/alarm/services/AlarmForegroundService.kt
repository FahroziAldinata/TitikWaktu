package com.titikwaktu.alarm.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import com.titikwaktu.alarm.R
import com.titikwaktu.alarm.receivers.DismissReceiver
import com.titikwaktu.alarm.receivers.SnoozeReceiver

import android.util.Log

class AlarmForegroundService : Service() {
    
    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onCreate() {
        super.onCreate()
        Log.i("AlarmForegroundService", "onCreate: creating notification channel and acquiring wakelock")
        createNotificationChannel()
        acquireWakeLock()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val scheduleId = intent?.getStringExtra(EXTRA_SCHEDULE_ID) ?: return START_NOT_STICKY
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "Alarm"
        val description = intent.getStringExtra(EXTRA_DESCRIPTION) ?: ""
        
        Log.i("AlarmForegroundService", "🔔 onStartCommand: Alarm triggered: '$title' (ID: $scheduleId)")

        if (intent.getBooleanExtra(ACTION_DISMISS, false)) {
            Log.i("AlarmForegroundService", "ACTION_DISMISS received: stopping alarm")
            stopAlarm()
            stopForeground(true)
            stopSelf()
            return START_NOT_STICKY
        }
        
        val notification = createNotification(scheduleId, title, description)
        startForeground(NOTIFICATION_ID, notification)
        
        startAlarmSound()
        
        return START_STICKY
    }
    
    override fun onDestroy() {
        Log.i("AlarmForegroundService", "🛑 onDestroy: releasing wakelock and stopping alarm")
        stopAlarm()
        releaseWakeLock()
        super.onDestroy()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Alarm Kegiatan",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Channel untuk alarm kegiatan penuh"
                enableVibration(true)
                setBypassDnd(true)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(scheduleId: String, title: String, description: String): Notification {
        val dismissIntent = Intent(this, DismissReceiver::class.java).apply {
            putExtra(DismissReceiver.EXTRA_SCHEDULE_ID, scheduleId)
        }
        val dismissPendingIntent = PendingIntent.getBroadcast(
            this,
            scheduleId.hashCode(),
            dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val snoozeIntent = Intent(this, SnoozeReceiver::class.java).apply {
            putExtra(SnoozeReceiver.EXTRA_SCHEDULE_ID, scheduleId)
            putExtra(SnoozeReceiver.EXTRA_SNOOZE_DURATION, 5 * 60 * 1000L)
        }
        val snoozePendingIntent = PendingIntent.getBroadcast(
            this,
            scheduleId.hashCode() + 1,
            snoozeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val fullScreenIntent = Intent(this, com.titikwaktu.alarm.MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("route", "/alarm/$scheduleId")
            putExtra("schedule_id", scheduleId)
            putExtra("title", title)
            putExtra("description", description)
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            scheduleId.hashCode() + 2,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(description)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(false)
            .setOngoing(true)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .addAction(R.mipmap.ic_launcher, "Matikan", dismissPendingIntent)
            .addAction(R.mipmap.ic_launcher, "Tunda 5 Menit", snoozePendingIntent)
            .build()
    }
    
    private fun startAlarmSound() {
        try {
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            
            val resourceId = resources.getIdentifier("default_alarm", "raw", packageName)
            if (resourceId != 0) {
                mediaPlayer = MediaPlayer.create(this, resourceId).apply {
                    setAudioAttributes(audioAttributes)
                    isLooping = true
                    start()
                }
            } else {
                val alarmUri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                mediaPlayer = MediaPlayer.create(this, alarmUri).apply {
                    setAudioAttributes(audioAttributes)
                    isLooping = true
                    start()
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun stopAlarm() {
        mediaPlayer?.apply {
            if (isPlaying) {
                stop()
            }
            release()
        }
        mediaPlayer = null
    }
    
    private fun acquireWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
            "TitikWaktu:AlarmWakeLock"
        ).apply {
            acquire(MAX_ALARM_DURATION_MS)
        }
    }
    
    private fun releaseWakeLock() {
        wakeLock?.apply {
            if (isHeld) {
                release()
            }
        }
        wakeLock = null
    }
    
    companion object {
        const val CHANNEL_ID = "alarm_channel"
        const val NOTIFICATION_ID = 1001
        const val EXTRA_SCHEDULE_ID = "schedule_id"
        const val EXTRA_TITLE = "title"
        const val EXTRA_DESCRIPTION = "description"
        const val ACTION_DISMISS = "action_dismiss"
        const val MAX_ALARM_DURATION_MS = 30 * 60 * 1000L // 30 minutes
    }
}
