import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as notifications;
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/project.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final notifications.FlutterLocalNotificationsPlugin _notifications =
      notifications.FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const notifications.AndroidInitializationSettings androidSettings =
        notifications.AndroidInitializationSettings('@mipmap/ic_launcher');
    const notifications.DarwinInitializationSettings iosSettings =
        notifications.DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const notifications.InitializationSettings settings =
        notifications.InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );

    await _notifications.initialize(settings);
    _isInitialized = true;
  }

  Future<void> scheduleProjectDeadlineReminder(Project project) async {
    await initialize();

    final daysUntilDeadline = project.daysUntilDeadline;

    // Schedule reminder 3 days before deadline
    if (daysUntilDeadline > 3) {
      final reminderDate = project.deadline.subtract(const Duration(days: 3));
      await _scheduleNotification(
        id: project.id.hashCode,
        title: 'Project Deadline Reminder',
        body:
            '${project.name} is due in 3 days (${project.deadline.day}/${project.deadline.month}/${project.deadline.year})',
        scheduledDate: reminderDate,
      );
    }

    // Schedule reminder 1 day before deadline
    if (daysUntilDeadline > 1) {
      final reminderDate = project.deadline.subtract(const Duration(days: 1));
      await _scheduleNotification(
        id: project.id.hashCode + 1,
        title: 'Project Deadline Tomorrow',
        body: '${project.name} is due tomorrow!',
        scheduledDate: reminderDate,
      );
    }

    // Schedule reminder on deadline day
    if (daysUntilDeadline >= 0) {
      final reminderDate = DateTime(
        project.deadline.year,
        project.deadline.month,
        project.deadline.day,
        9,
        0,
      );
      await _scheduleNotification(
        id: project.id.hashCode + 2,
        title: 'Project Due Today',
        body: '${project.name} is due today!',
        scheduledDate: reminderDate,
      );
    }
  }

  Future<void> scheduleTaskReminder(Task task, String projectName) async {
    await initialize();

    if (task.dueDate == null) return;

    final daysUntilDue = task.dueDate!.difference(DateTime.now()).inDays;

    // Schedule reminder 1 day before due date
    if (daysUntilDue > 1) {
      final reminderDate = task.dueDate!.subtract(const Duration(days: 1));
      await _scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Due Soon',
        body: '${task.title} in ${projectName} is due tomorrow',
        scheduledDate: reminderDate,
      );
    }

    // Schedule reminder on due date
    if (daysUntilDue >= 0) {
      final reminderDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
        9,
        0,
      );
      await _scheduleNotification(
        id: task.id.hashCode + 1,
        title: 'Task Due Today',
        body: '${task.title} in ${projectName} is due today!',
        scheduledDate: reminderDate,
      );
    }
  }

  Future<void> schedulePaymentReminder(Project project) async {
    await initialize();

    if (project.outstandingBalance <= 0) return;

    // Schedule reminder 7 days after project completion (if overdue)
    if (project.isOverdue) {
      final reminderDate = DateTime.now().add(const Duration(days: 1));
      await _scheduleNotification(
        id: project.id.hashCode + 100,
        title: 'Payment Overdue',
        body:
            '${project.name} has an outstanding balance of \$${project.outstandingBalance.toStringAsFixed(2)}',
        scheduledDate: reminderDate,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final notifications.AndroidNotificationDetails androidDetails =
        notifications.AndroidNotificationDetails(
          'clarity_reminders',
          'Clarity Reminders',
          channelDescription: 'Notifications for project deadlines and tasks',
          importance: notifications.Importance.high,
          priority: notifications.Priority.high,
        );

    const notifications.DarwinNotificationDetails iosDetails =
        notifications.DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    final notifications.NotificationDetails details =
        notifications.NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode:
          notifications.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          notifications.UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await initialize();

    const notifications.AndroidNotificationDetails androidDetails =
        notifications.AndroidNotificationDetails(
          'clarity_instant',
          'Clarity Notifications',
          channelDescription: 'Instant notifications from Clarity',
          importance: notifications.Importance.high,
          priority: notifications.Priority.high,
        );

    const notifications.DarwinNotificationDetails iosDetails =
        notifications.DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const notifications.NotificationDetails details =
        notifications.NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }
}
