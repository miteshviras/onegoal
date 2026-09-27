package com.onegoal.onegoal

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class FocusTimerActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        FocusTimerStateHolder.loadFromPreferences(context)
        val manager = FocusTimerNotificationManager(context)

        when (intent.action) {
            FocusTimerNotificationManager.ACTION_PAUSE -> {
                val remaining = FocusTimerStateHolder.getEffectiveRemainingSeconds()
                FocusTimerStateHolder.remainingSeconds = remaining
                FocusTimerStateHolder.isRunning = false
                FocusTimerStateHolder.saveToPreferences(context)

                manager.showPaused(
                    FocusTimerStateHolder.taskTitle,
                    FocusTimerStateHolder.subtitle,
                    remaining
                )
                FocusTimerAppWidgetProvider.updateAllWidgets(context)
                MainActivity.sendFlutterEvent("onLockscreenAction", "pause:$remaining")
            }

            FocusTimerNotificationManager.ACTION_RESUME -> {
                val remaining = if (FocusTimerStateHolder.remainingSeconds > 0) {
                    FocusTimerStateHolder.remainingSeconds
                } else {
                    FocusTimerStateHolder.totalSeconds
                }
                FocusTimerStateHolder.remainingSeconds = remaining
                FocusTimerStateHolder.targetEndTimeMillis = System.currentTimeMillis() + (remaining * 1000L)
                FocusTimerStateHolder.isRunning = true
                FocusTimerStateHolder.isCompleted = false
                FocusTimerStateHolder.saveToPreferences(context)

                manager.showRunning(
                    FocusTimerStateHolder.taskTitle,
                    FocusTimerStateHolder.subtitle,
                    remaining
                )
                FocusTimerAppWidgetProvider.updateAllWidgets(context)
                MainActivity.sendFlutterEvent("onLockscreenAction", "resume:$remaining")
            }

            FocusTimerNotificationManager.ACTION_TOGGLE -> {
                val eff = FocusTimerStateHolder.getEffectiveRemainingSeconds()
                if (FocusTimerStateHolder.isRunning && eff > 0) {
                    FocusTimerStateHolder.remainingSeconds = eff
                    FocusTimerStateHolder.isRunning = false
                    FocusTimerStateHolder.saveToPreferences(context)

                    manager.showPaused(
                        FocusTimerStateHolder.taskTitle,
                        FocusTimerStateHolder.subtitle,
                        eff
                    )
                    FocusTimerAppWidgetProvider.updateAllWidgets(context)
                    MainActivity.sendFlutterEvent("onLockscreenAction", "pause:$eff")
                } else {
                    val remaining = if (FocusTimerStateHolder.remainingSeconds > 0) {
                        FocusTimerStateHolder.remainingSeconds
                    } else {
                        FocusTimerStateHolder.totalSeconds
                    }
                    FocusTimerStateHolder.remainingSeconds = remaining
                    FocusTimerStateHolder.targetEndTimeMillis = System.currentTimeMillis() + (remaining * 1000L)
                    FocusTimerStateHolder.isRunning = true
                    FocusTimerStateHolder.isCompleted = false
                    FocusTimerStateHolder.saveToPreferences(context)

                    manager.showRunning(
                        FocusTimerStateHolder.taskTitle,
                        FocusTimerStateHolder.subtitle,
                        remaining
                    )
                    FocusTimerAppWidgetProvider.updateAllWidgets(context)
                    MainActivity.sendFlutterEvent("onLockscreenAction", "resume:$remaining")
                }
            }

            FocusTimerNotificationManager.ACTION_COMPLETE -> {
                FocusTimerStateHolder.isRunning = false
                FocusTimerStateHolder.isCompleted = true
                FocusTimerStateHolder.remainingSeconds = 0
                FocusTimerStateHolder.saveToPreferences(context)

                manager.showCompleted(FocusTimerStateHolder.taskTitle)
                FocusTimerAppWidgetProvider.updateAllWidgets(context)
                MainActivity.sendFlutterEvent("onLockscreenAction", "complete")
            }
        }
    }
}
