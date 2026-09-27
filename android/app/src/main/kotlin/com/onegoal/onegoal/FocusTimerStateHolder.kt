package com.onegoal.onegoal

import android.content.Context
import android.content.SharedPreferences

data class DailyTaskItem(
    val id: String,
    val title: String,
    val subtitle: String,
    val scheduledTime: String,
    val isCompleted: Boolean,
    val isCurrentFocus: Boolean
)

object FocusTimerStateHolder {
    private const val PREFS_NAME = "onegoal_focus_state"
    private const val KEY_TASK_TITLE = "task_title"
    private const val KEY_SUBTITLE = "subtitle"
    private const val KEY_DURATION_MINUTES = "duration_minutes"
    private const val KEY_TOTAL_SECONDS = "total_seconds"
    private const val KEY_REMAINING_SECONDS = "remaining_seconds"
    private const val KEY_IS_RUNNING = "is_running"
    private const val KEY_IS_COMPLETED = "is_completed"
    private const val KEY_TARGET_END_TIME = "target_end_time"

    var taskTitle: String = "Add your first focus step"
    var subtitle: String = "Break down your goal into calm micro-steps"
    var durationMinutes: Int = 25
    var totalSeconds: Int = 25 * 60
    var remainingSeconds: Int = 25 * 60
    var isRunning: Boolean = false
    var isCompleted: Boolean = false
    var targetEndTimeMillis: Long = 0L

    var dailyTasks: List<DailyTaskItem> = emptyList()

    fun getEffectiveRemainingSeconds(): Int {
        if (isRunning && targetEndTimeMillis > 0L) {
            val now = System.currentTimeMillis()
            val diff = ((targetEndTimeMillis - now) / 1000L).toInt()
            return diff.coerceAtLeast(0)
        }
        return remainingSeconds
    }

    val formattedTime: String
        get() {
            val eff = getEffectiveRemainingSeconds()
            val hours = eff / 3600
            val mins = (eff % 3600) / 60
            val secs = eff % 60
            return if (hours > 0) {
                String.format("%02d:%02d:%02d", hours, mins, secs)
            } else {
                String.format("%02d:%02d", mins, secs)
            }
        }

    val remainingTaskCount: Int
        get() = dailyTasks.count { !it.isCompleted }

    val completedTaskCount: Int
        get() = dailyTasks.count { it.isCompleted }

    fun saveToPreferences(context: Context) {
        val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().apply {
            putString(KEY_TASK_TITLE, taskTitle)
            putString(KEY_SUBTITLE, subtitle)
            putInt(KEY_DURATION_MINUTES, durationMinutes)
            putInt(KEY_TOTAL_SECONDS, totalSeconds)
            putInt(KEY_REMAINING_SECONDS, getEffectiveRemainingSeconds())
            putBoolean(KEY_IS_RUNNING, isRunning)
            putBoolean(KEY_IS_COMPLETED, isCompleted)
            putLong(KEY_TARGET_END_TIME, targetEndTimeMillis)
            apply()
        }
    }

    fun loadFromPreferences(context: Context) {
        val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (!prefs.contains(KEY_TASK_TITLE)) return

        taskTitle = prefs.getString(KEY_TASK_TITLE, taskTitle) ?: taskTitle
        subtitle = prefs.getString(KEY_SUBTITLE, subtitle) ?: subtitle
        durationMinutes = prefs.getInt(KEY_DURATION_MINUTES, durationMinutes)
        totalSeconds = prefs.getInt(KEY_TOTAL_SECONDS, totalSeconds)
        val savedRemaining = prefs.getInt(KEY_REMAINING_SECONDS, remainingSeconds)
        isRunning = prefs.getBoolean(KEY_IS_RUNNING, false)
        isCompleted = prefs.getBoolean(KEY_IS_COMPLETED, false)
        targetEndTimeMillis = prefs.getLong(KEY_TARGET_END_TIME, 0L)

        if (isRunning && targetEndTimeMillis > 0L) {
            val now = System.currentTimeMillis()
            val remaining = ((targetEndTimeMillis - now) / 1000L).toInt()
            if (remaining <= 0) {
                remainingSeconds = 0
                isRunning = false
                isCompleted = true
            } else {
                remainingSeconds = remaining
            }
        } else {
            remainingSeconds = savedRemaining
        }
    }
}
