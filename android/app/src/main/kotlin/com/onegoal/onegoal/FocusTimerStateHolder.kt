package com.onegoal.onegoal

data class DailyTaskItem(
    val id: String,
    val title: String,
    val subtitle: String,
    val scheduledTime: String,
    val isCompleted: Boolean,
    val isCurrentFocus: Boolean
)

object FocusTimerStateHolder {
    var taskTitle: String = "Add your first focus step"
    var subtitle: String = "Break down your goal into calm micro-steps"
    var durationMinutes: Int = 25
    var totalSeconds: Int = 25 * 60
    var remainingSeconds: Int = 25 * 60
    var isRunning: Boolean = false
    var isCompleted: Boolean = false
    var targetEndTimeMillis: Long = 0L

    var dailyTasks: List<DailyTaskItem> = emptyList()

    val formattedTime: String
        get() {
            val mins = remainingSeconds / 60
            val secs = remainingSeconds % 60
            return String.format("%02d:%02d", mins, secs)
        }

    val remainingTaskCount: Int
        get() = dailyTasks.count { !it.isCompleted }

    val completedTaskCount: Int
        get() = dailyTasks.count { it.isCompleted }
}
