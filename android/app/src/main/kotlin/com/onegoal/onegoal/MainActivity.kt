package com.onegoal.onegoal

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "com.onegoal.onegoal/focus_timer"
        const val PERMISSION_REQUEST_CODE = 2001
        var methodChannel: MethodChannel? = null

        fun sendFlutterEvent(method: String, argument: Any?) {
            methodChannel?.invokeMethod(method, argument)
        }
    }

    private var notificationManager: FocusTimerNotificationManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        notificationManager = FocusTimerNotificationManager(this)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel?.setMethodCallHandler { call, result ->
            val mgr = notificationManager ?: FocusTimerNotificationManager(this)

            when (call.method) {
                "requestPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        val granted = ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.POST_NOTIFICATIONS
                        ) == PackageManager.PERMISSION_GRANTED

                        if (!granted) {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                PERMISSION_REQUEST_CODE
                            )
                            result.success(false)
                        } else {
                            result.success(true)
                        }
                    } else {
                        result.success(true)
                    }
                }

                "startTimer" -> {
                    val taskTitle = call.argument<String>("taskTitle") ?: "Active Focus Task"
                    val subtitle = call.argument<String>("subtitle") ?: ""
                    val remainingSeconds = call.argument<Int>("remainingSeconds") ?: (25 * 60)
                    val totalSeconds = call.argument<Int>("totalSeconds") ?: remainingSeconds

                    FocusTimerStateHolder.totalSeconds = totalSeconds
                    mgr.showRunning(taskTitle, subtitle, remainingSeconds)
                    result.success(true)
                }

                "pauseTimer" -> {
                    val taskTitle = call.argument<String>("taskTitle") ?: FocusTimerStateHolder.taskTitle
                    val subtitle = call.argument<String>("subtitle") ?: FocusTimerStateHolder.subtitle
                    val remainingSeconds = call.argument<Int>("remainingSeconds") ?: FocusTimerStateHolder.remainingSeconds

                    mgr.showPaused(taskTitle, subtitle, remainingSeconds)
                    result.success(true)
                }

                "resumeTimer" -> {
                    val taskTitle = call.argument<String>("taskTitle") ?: FocusTimerStateHolder.taskTitle
                    val subtitle = call.argument<String>("subtitle") ?: FocusTimerStateHolder.subtitle
                    val remainingSeconds = call.argument<Int>("remainingSeconds") ?: FocusTimerStateHolder.remainingSeconds

                    mgr.showRunning(taskTitle, subtitle, remainingSeconds)
                    result.success(true)
                }

                "stopTimer" -> {
                    mgr.cancel()
                    result.success(true)
                }

                "updateTask" -> {
                    val taskTitle = call.argument<String>("taskTitle") ?: "Add your first focus step"
                    val subtitle = call.argument<String>("subtitle") ?: ""
                    val durationMinutes = call.argument<Int>("durationMinutes") ?: 25

                    FocusTimerStateHolder.taskTitle = taskTitle
                    FocusTimerStateHolder.subtitle = subtitle
                    FocusTimerStateHolder.durationMinutes = durationMinutes
                    FocusTimerStateHolder.totalSeconds = durationMinutes * 60
                    FocusTimerStateHolder.remainingSeconds = durationMinutes * 60
                    FocusTimerAppWidgetProvider.updateAllWidgets(this)
                    result.success(true)
                }

                "syncDailyTasks" -> {
                    val tasksRaw = call.argument<List<Map<String, Any>>>("tasks") ?: emptyList()
                    val items = tasksRaw.map { m ->
                        DailyTaskItem(
                            id = (m["id"] as? String) ?: "",
                            title = (m["title"] as? String) ?: "",
                            subtitle = (m["subtitle"] as? String) ?: "",
                            scheduledTime = (m["scheduledTime"] as? String) ?: (m["scheduled_time"] as? String) ?: "",
                            isCompleted = (m["isCompleted"] as? Boolean) ?: (m["is_completed"] as? Boolean) ?: false,
                            isCurrentFocus = (m["isCurrentFocus"] as? Boolean) ?: (m["is_current_focus"] as? Boolean) ?: false
                        )
                    }
                    FocusTimerStateHolder.dailyTasks = items
                    FocusTimerAppWidgetProvider.updateAllWidgets(this)

                    if (FocusTimerStateHolder.isRunning) {
                        val remaining = ((FocusTimerStateHolder.targetEndTimeMillis - System.currentTimeMillis()) / 1000).toInt().coerceAtLeast(0)
                        mgr.showRunning(FocusTimerStateHolder.taskTitle, FocusTimerStateHolder.subtitle, remaining)
                    } else if (FocusTimerStateHolder.remainingSeconds > 0 && FocusTimerStateHolder.isRunning) {
                        mgr.showPaused(FocusTimerStateHolder.taskTitle, FocusTimerStateHolder.subtitle, FocusTimerStateHolder.remainingSeconds)
                    } else if (items.isNotEmpty()) {
                        mgr.showDailyFlowOnly()
                    }
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        methodChannel = null
        super.onDestroy()
    }
}
