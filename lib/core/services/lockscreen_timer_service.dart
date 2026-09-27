import 'dart:io';

import 'package:flutter/services.dart';

typedef LockscreenActionCallback = void Function(String action);

class LockscreenTimerService {
  static const MethodChannel _channel = MethodChannel(
    'com.onegoal.onegoal/focus_timer',
  );

  static final LockscreenTimerService _instance =
      LockscreenTimerService._internal();

  factory LockscreenTimerService() => _instance;

  LockscreenTimerService._internal() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  final List<LockscreenActionCallback> _listeners = [];

  void addListener(LockscreenActionCallback callback) {
    _listeners.add(callback);
  }

  void removeListener(LockscreenActionCallback callback) {
    _listeners.remove(callback);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onLockscreenAction') {
      final action = call.arguments as String?;
      if (action != null) {
        for (final listener in [..._listeners]) {
          listener(action);
        }
      }
    }
  }

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final res = await _channel.invokeMethod<bool>('requestPermission');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> startTimer({
    required String taskTitle,
    required String subtitle,
    required int remainingSeconds,
    required int totalSeconds,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('startTimer', {
        'taskTitle': taskTitle,
        'subtitle': subtitle,
        'remainingSeconds': remainingSeconds,
        'totalSeconds': totalSeconds,
      });
    } catch (_) {}
  }

  Future<void> pauseTimer({
    required String taskTitle,
    required String subtitle,
    required int remainingSeconds,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('pauseTimer', {
        'taskTitle': taskTitle,
        'subtitle': subtitle,
        'remainingSeconds': remainingSeconds,
      });
    } catch (_) {}
  }

  Future<void> resumeTimer({
    required String taskTitle,
    required String subtitle,
    required int remainingSeconds,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('resumeTimer', {
        'taskTitle': taskTitle,
        'subtitle': subtitle,
        'remainingSeconds': remainingSeconds,
      });
    } catch (_) {}
  }

  Future<void> stopTimer() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('stopTimer');
    } catch (_) {}
  }

  Future<void> updateActiveTask({
    required String taskTitle,
    required String subtitle,
    required int durationMinutes,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('updateTask', {
        'taskTitle': taskTitle,
        'subtitle': subtitle,
        'durationMinutes': durationMinutes,
      });
    } catch (_) {}
  }

  Future<void> syncDailyTasks(List<dynamic> tasks) async {
    if (!Platform.isAndroid) return;
    try {
      final taskMaps = tasks.map((t) {
        return {
          'id': t.id,
          'title': t.title,
          'subtitle': t.subtitle,
          'scheduledTime': t.scheduledTime,
          'isCompleted': t.isCompleted,
          'isCurrentFocus': t.isCurrentFocus,
          'durationMinutes': t.durationMinutes,
        };
      }).toList();

      await _channel.invokeMethod('syncDailyTasks', {'tasks': taskMaps});
    } catch (_) {}
  }
}
