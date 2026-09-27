package com.onegoal.onegoal

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class FocusTimerAppWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidgetView(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, FocusTimerAppWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            for (widgetId in allWidgetIds) {
                updateWidgetView(context, appWidgetManager, widgetId)
            }
        }

        private fun updateWidgetView(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_focus_timer)

            // 1. Text & Titles
            views.setTextViewText(R.id.widget_task_title, FocusTimerStateHolder.taskTitle)
            views.setTextViewText(R.id.widget_task_subtitle, FocusTimerStateHolder.subtitle)
            views.setTextViewText(
                R.id.widget_timer_text,
                "⏱ ${FocusTimerStateHolder.formattedTime}"
            )

            // 2. Dynamic button and status
            if (FocusTimerStateHolder.isRunning) {
                views.setTextViewText(R.id.widget_badge, "In Focus")
                views.setTextViewText(
                    R.id.widget_btn_text,
                    "Pause Focus (${FocusTimerStateHolder.formattedTime})"
                )
                views.setImageViewResource(R.id.widget_btn_icon, R.drawable.ic_btn_pause)
            } else if (FocusTimerStateHolder.remainingSeconds < FocusTimerStateHolder.totalSeconds && FocusTimerStateHolder.remainingSeconds > 0) {
                views.setTextViewText(R.id.widget_badge, "Paused")
                views.setTextViewText(R.id.widget_btn_text, "Resume Focus")
                views.setImageViewResource(R.id.widget_btn_icon, R.drawable.ic_btn_play)
            } else {
                views.setTextViewText(R.id.widget_badge, "Ready")
                views.setTextViewText(
                    R.id.widget_btn_text,
                    "Begin ${FocusTimerStateHolder.durationMinutes}-Min Focus"
                )
                views.setImageViewResource(R.id.widget_btn_icon, R.drawable.ic_btn_play)
            }

            // 3. Action Pending Intents
            val toggleIntent = PendingIntent.getBroadcast(
                context,
                10,
                Intent(context, FocusTimerActionReceiver::class.java).apply {
                    action = FocusTimerNotificationManager.ACTION_TOGGLE
                },
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_btn_action, toggleIntent)

            val completeIntent = PendingIntent.getBroadcast(
                context,
                11,
                Intent(context, FocusTimerActionReceiver::class.java).apply {
                    action = FocusTimerNotificationManager.ACTION_COMPLETE
                },
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_btn_complete, completeIntent)

            // Open app on card click
            val launchIntent = PendingIntent.getActivity(
                context,
                0,
                Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                },
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, launchIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
