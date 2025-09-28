import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  bool _projectRemindersEnabled = true;
  bool _deadlineAlertsEnabled = true;
  bool _paymentRemindersEnabled = true;
  String? _fcmToken;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get projectRemindersEnabled => _projectRemindersEnabled;
  bool get deadlineAlertsEnabled => _deadlineAlertsEnabled;
  bool get paymentRemindersEnabled => _paymentRemindersEnabled;
  String? get fcmToken => _fcmToken;

  NotificationProvider() {
    _loadSettings();
    _initializeNotifications();
  }

  /// Initialize notifications
  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
      _isInitialized = true;
      _fcmToken = _notificationService.fcmToken;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
    }
  }

  /// Load notification settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _projectRemindersEnabled =
        prefs.getBool('project_reminders_enabled') ?? true;
    _deadlineAlertsEnabled = prefs.getBool('deadline_alerts_enabled') ?? true;
    _paymentRemindersEnabled =
        prefs.getBool('payment_reminders_enabled') ?? true;
    notifyListeners();
  }

  /// Save notification settings
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('project_reminders_enabled', _projectRemindersEnabled);
    await prefs.setBool('deadline_alerts_enabled', _deadlineAlertsEnabled);
    await prefs.setBool('payment_reminders_enabled', _paymentRemindersEnabled);
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  /// Toggle project reminders
  Future<void> toggleProjectReminders(bool enabled) async {
    _projectRemindersEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  /// Toggle deadline alerts
  Future<void> toggleDeadlineAlerts(bool enabled) async {
    _deadlineAlertsEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  /// Toggle payment reminders
  Future<void> togglePaymentReminders(bool enabled) async {
    _paymentRemindersEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  /// Show project reminder
  Future<void> showProjectReminder({
    required String projectName,
    required String message,
    DateTime? scheduledDate,
  }) async {
    if (!_notificationsEnabled || !_projectRemindersEnabled) return;

    if (scheduledDate != null) {
      await _notificationService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Project Reminder: $projectName',
        body: message,
        scheduledDate: scheduledDate,
        payload: 'project_reminder:$projectName',
      );
    } else {
      await _notificationService.showNotification(
        title: 'Project Reminder: $projectName',
        body: message,
        payload: 'project_reminder:$projectName',
      );
    }
  }

  /// Show deadline alert
  Future<void> showDeadlineAlert({
    required String projectName,
    required String taskName,
    required DateTime deadline,
  }) async {
    if (!_notificationsEnabled || !_deadlineAlertsEnabled) return;

    final now = DateTime.now();
    final timeUntilDeadline = deadline.difference(now);

    String message;
    if (timeUntilDeadline.inDays > 0) {
      message = 'Deadline in ${timeUntilDeadline.inDays} days';
    } else if (timeUntilDeadline.inHours > 0) {
      message = 'Deadline in ${timeUntilDeadline.inHours} hours';
    } else {
      message = 'Deadline is overdue!';
    }

    await _notificationService.showNotification(
      title: 'Deadline Alert: $projectName',
      body: '$taskName - $message',
      payload: 'deadline_alert:$projectName:$taskName',
    );
  }

  /// Show payment reminder
  Future<void> showPaymentReminder({
    required String clientName,
    required String projectName,
    required double amount,
    DateTime? dueDate,
  }) async {
    if (!_notificationsEnabled || !_paymentRemindersEnabled) return;

    String message = 'Payment of \$${amount.toStringAsFixed(2)} is due';
    if (dueDate != null) {
      final now = DateTime.now();
      final timeUntilDue = dueDate.difference(now);
      if (timeUntilDue.inDays > 0) {
        message += ' in ${timeUntilDue.inDays} days';
      } else if (timeUntilDue.inHours > 0) {
        message += ' in ${timeUntilDue.inHours} hours';
      } else {
        message += ' (overdue)';
      }
    }

    await _notificationService.showNotification(
      title: 'Payment Reminder: $clientName',
      body: '$projectName - $message',
      payload: 'payment_reminder:$clientName:$projectName',
    );
  }

  /// Show general notification
  Future<void> showGeneralNotification({
    required String title,
    required String message,
    String? payload,
  }) async {
    if (!_notificationsEnabled) return;

    await _notificationService.showNotification(
      title: title,
      body: message,
      payload: payload,
    );
  }

  /// Schedule recurring reminder
  Future<void> scheduleRecurringReminder({
    required String title,
    required String message,
    required int hour,
    required int minute,
    List<int> days = const [1, 2, 3, 4, 5], // Monday to Friday
  }) async {
    if (!_notificationsEnabled) return;

    for (int day in days) {
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      ).add(Duration(days: (day - now.weekday) % 7));

      await _notificationService.scheduleNotification(
        id: day * 1000 + hour * 60 + minute,
        title: title,
        body: message,
        scheduledDate: scheduledDate,
        payload: 'recurring_reminder:$day',
      );
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  /// Subscribe to project updates
  Future<void> subscribeToProjectUpdates(String projectId) async {
    await _notificationService.subscribeToTopic('project_$projectId');
  }

  /// Unsubscribe from project updates
  Future<void> unsubscribeFromProjectUpdates(String projectId) async {
    await _notificationService.unsubscribeFromTopic('project_$projectId');
  }

  /// Subscribe to general updates
  Future<void> subscribeToGeneralUpdates() async {
    await _notificationService.subscribeToTopic('general_updates');
  }

  /// Unsubscribe from general updates
  Future<void> unsubscribeFromGeneralUpdates() async {
    await _notificationService.unsubscribeFromTopic('general_updates');
  }

  /// Get pending notifications
  Future<List<dynamic>> getPendingNotifications() async {
    return await _notificationService.getPendingNotifications();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _notificationService.areNotificationsEnabled();
  }
}
