package com.onegoal.onegoal

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.core.app.NotificationCompat

class FocusTimerNotificationManager(private val context: Context) {

    companion object {
        const val CHANNEL_ID = "onegoal_focus_timer"
        const val CHANNEL_NAME = "Mindful Focus Timer"
        const val NOTIFICATION_ID = 1001

        const val ACTION_PAUSE = "com.onegoal.onegoal.ACTION_PAUSE"
        const val ACTION_RESUME = "com.onegoal.onegoal.ACTION_RESUME"
        const val ACTION_COMPLETE = "com.onegoal.onegoal.ACTION_COMPLETE"
        const val ACTION_TOGGLE = "com.onegoal.onegoal.ACTION_TOGGLE"
    }

    private val notificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    init {
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Shows active focus timer countdown and daily flow tasks on lock screen"
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                enableVibration(true)
                lightColor = Color.parseColor("#0E5FC3")
                setShowBadge(true)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun applyDailyFlowStyle(builder: NotificationCompat.Builder, activeTitle: String) {
        val tasks = FocusTimerStateHolder.dailyTasks
        if (tasks.isNotEmpty()) {
            val title = if (FocusTimerStateHolder.isRunning) {
                "Daily Flow • In Focus: $activeTitle"
            } else {
                "Daily Flow • ${FocusTimerStateHolder.remainingTaskCount} remaining"
            }
            val inboxStyle = NotificationCompat.InboxStyle()
                .setBigContentTitle(title)
                .setSummaryText("${FocusTimerStateHolder.completedTaskCount}/${tasks.size} completed")

            for (task in tasks.take(7)) {
                val prefix = when {
                    task.isCompleted -> "✓ "
                    task.isCurrentFocus || task.title == activeTitle -> "◎ "
                    else -> "○ "
                }
                val suffix = when {
                    task.isCompleted -> " (Completed)"
                    task.isCurrentFocus || task.title == activeTitle -> {
                        if (FocusTimerStateHolder.isRunning) " [${FocusTimerStateHolder.formattedTime}]"
                        else if (task.scheduledTime.isNotEmpty()) " • ${task.scheduledTime}"
                        else ""
                    }
                    task.scheduledTime.isNotEmpty() -> " • ${task.scheduledTime}"
                    else -> ""
                }
                inboxStyle.addLine("$prefix${task.title}$suffix")
            }
            builder.setStyle(inboxStyle)
        }
    }

    fun showRunning(
        taskTitle: String,
        subtitle: String,
        remainingSeconds: Int
    ) {
        val targetEndTime = System.currentTimeMillis() + (remainingSeconds * 1000L)
        FocusTimerStateHolder.taskTitle = taskTitle
        FocusTimerStateHolder.subtitle = subtitle
        FocusTimerStateHolder.remainingSeconds = remainingSeconds
        FocusTimerStateHolder.isRunning = true
        FocusTimerStateHolder.isCompleted = false
        FocusTimerStateHolder.targetEndTimeMillis = targetEndTime
        FocusTimerStateHolder.saveToPreferences(context)

        val pauseIntent = PendingIntent.getBroadcast(
            context,
            1,
            Intent(context, FocusTimerActionReceiver::class.java).apply {
                action = ACTION_PAUSE
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val completeIntent = PendingIntent.getBroadcast(
            context,
            2,
            Intent(context, FocusTimerActionReceiver::class.java).apply {
                action = ACTION_COMPLETE
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val contentIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification_focus)
            .setContentTitle("In Focus: $taskTitle")
            .setContentText(if (subtitle.isNotEmpty()) subtitle else "Deep work sprint in progress • Stay calm")
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setColor(Color.parseColor("#0E5FC3"))
            .setColorized(true)
            .setUsesChronometer(true)
            .setChronometerCountDown(true)
            .setWhen(targetEndTime)
            .setShowWhen(true)
            .addAction(R.drawable.ic_btn_pause, "Pause", pauseIntent)
            .addAction(R.drawable.ic_btn_check, "Done", completeIntent)

        applyDailyFlowStyle(builder, taskTitle)

        notificationManager.notify(NOTIFICATION_ID, builder.build())
        FocusTimerAppWidgetProvider.updateAllWidgets(context)
    }

    fun showPaused(
        taskTitle: String,
        subtitle: String,
        remainingSeconds: Int
    ) {
        FocusTimerStateHolder.taskTitle = taskTitle
        FocusTimerStateHolder.subtitle = subtitle
        FocusTimerStateHolder.remainingSeconds = remainingSeconds
        FocusTimerStateHolder.isRunning = false
        FocusTimerStateHolder.isCompleted = false
        FocusTimerStateHolder.saveToPreferences(context)

        val resumeIntent = PendingIntent.getBroadcast(
            context,
            3,
            Intent(context, FocusTimerActionReceiver::class.java).apply {
                action = ACTION_RESUME
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val completeIntent = PendingIntent.getBroadcast(
            context,
            4,
            Intent(context, FocusTimerActionReceiver::class.java).apply {
                action = ACTION_COMPLETE
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val contentIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val formatted = FocusTimerStateHolder.formattedTime

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification_focus)
            .setContentTitle("Paused: $taskTitle")
            .setContentText("Paused with $formatted remaining")
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setColor(Color.parseColor("#272A30"))
            .setUsesChronometer(false)
            .addAction(R.drawable.ic_btn_play, "Resume", resumeIntent)
            .addAction(R.drawable.ic_btn_check, "Done", completeIntent)

        applyDailyFlowStyle(builder, taskTitle)

        notificationManager.notify(NOTIFICATION_ID, builder.build())
        FocusTimerAppWidgetProvider.updateAllWidgets(context)
    }

    fun showDailyFlowOnly() {
        if (FocusTimerStateHolder.isRunning) return
        val tasks = FocusTimerStateHolder.dailyTasks
        if (tasks.isEmpty()) return

        val active = tasks.firstOrNull { !it.isCompleted } ?: tasks.first()
        val contentIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val startIntent = PendingIntent.getBroadcast(
            context,
            5,
            Intent(context, FocusTimerActionReceiver::class.java).apply {
                action = ACTION_RESUME
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification_focus)
            .setContentTitle("Daily Flow • ${FocusTimerStateHolder.remainingTaskCount} remaining")
            .setContentText("Next: ${active.title}")
            .setContentIntent(contentIntent)
            .setOngoing(false)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setColor(Color.parseColor("#0E5FC3"))
            .addAction(R.drawable.ic_btn_play, "Start Focus", startIntent)

        applyDailyFlowStyle(builder, active.title)

        notificationManager.notify(NOTIFICATION_ID, builder.build())
        FocusTimerAppWidgetProvider.updateAllWidgets(context)
    }

    fun showCompleted(taskTitle: String) {
        FocusTimerStateHolder.isRunning = false
        FocusTimerStateHolder.isCompleted = true
        FocusTimerStateHolder.remainingSeconds = 0
        FocusTimerStateHolder.saveToPreferences(context)

        val contentIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification_focus)
            .setContentTitle("Focus Sprint Complete! 🎉")
            .setContentText("Finished: $taskTitle. Take a calm breath.")
            .setContentIntent(contentIntent)
            .setOngoing(false)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setColor(Color.parseColor("#10B981"))
            .build()

        notificationManager.notify(NOTIFICATION_ID, notification)
        FocusTimerAppWidgetProvider.updateAllWidgets(context)
    }

    fun cancel() {
        FocusTimerStateHolder.isRunning = false
        notificationManager.cancel(NOTIFICATION_ID)
        FocusTimerAppWidgetProvider.updateAllWidgets(context)
    }
}
