package com.onegoal.onegoal

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class FocusTimerActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val manager = FocusTimerNotificationManager(context)

        when (intent.action) {
            FocusTimerNotificationManager.ACTION_PAUSE -> {
                manager.showPaused(
                    FocusTimerStateHolder.taskTitle,
                    FocusTimerStateHolder.subtitle,
                    FocusTimerStateHolder.remainingSeconds
                )
                MainActivity.sendFlutterEvent("onLockscreenAction", "pause")
            }

            FocusTimerNotificationManager.ACTION_RESUME -> {
                manager.showRunning(
                    FocusTimerStateHolder.taskTitle,
                    FocusTimerStateHolder.subtitle,
                    FocusTimerStateHolder.remainingSeconds
                )
                MainActivity.sendFlutterEvent("onLockscreenAction", "resume")
            }

            FocusTimerNotificationManager.ACTION_TOGGLE -> {
                if (FocusTimerStateHolder.isRunning) {
                    manager.showPaused(
                        FocusTimerStateHolder.taskTitle,
                        FocusTimerStateHolder.subtitle,
                        FocusTimerStateHolder.remainingSeconds
                    )
                    MainActivity.sendFlutterEvent("onLockscreenAction", "pause")
                } else {
                    manager.showRunning(
                        FocusTimerStateHolder.taskTitle,
                        FocusTimerStateHolder.subtitle,
                        FocusTimerStateHolder.remainingSeconds
                    )
                    MainActivity.sendFlutterEvent("onLockscreenAction", "resume")
                }
            }

            FocusTimerNotificationManager.ACTION_COMPLETE -> {
                manager.showCompleted(FocusTimerStateHolder.taskTitle)
                MainActivity.sendFlutterEvent("onLockscreenAction", "complete")
            }
        }
    }
}
