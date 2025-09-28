import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  // Getters
  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();

      // Request permissions
      await _requestPermissions();

      // Get FCM token
      await _getFCMToken();

      _isInitialized = true;

      if (kDebugMode) {
        print('NotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NotificationService: $e');
      }
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification taps when app is terminated
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request FCM permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('FCM Permission status: ${settings.authorizationStatus}');
    }

    // Request local notification permissions
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();

      if (kDebugMode) {
        print('FCM Token: $_fcmToken');
      }

      // Save token to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', _fcmToken ?? '');

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        prefs.setString('fcm_token', newToken);
        if (kDebugMode) {
          print('FCM Token refreshed: $newToken');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
    }

    // Show local notification for foreground messages
    _showLocalNotification(
      id: message.hashCode,
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? 'You have a new notification',
      payload: message.data.toString(),
    );
  }

  /// Handle notification taps
  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped: ${message.messageId}');
    }

    // Handle navigation based on message data
    _handleNotificationNavigation(message.data);
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Implement navigation logic based on notification data
    // This will be handled by the main app
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'clarity_notifications',
          'Clarity Notifications',
          channelDescription: 'Notifications for Clarity app',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule a local notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'clarity_scheduled',
          'Scheduled Notifications',
          channelDescription: 'Scheduled notifications for Clarity app',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Unsubscribed from topic: $topic');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Local notification tapped: ${response.payload}');
    }

    // Handle navigation based on payload
    if (response.payload != null) {
      _handleNotificationNavigation({'payload': response.payload});
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Schedule project deadline reminder
  Future<void> scheduleProjectDeadlineReminder(dynamic project) async {
    if (project.deadline == null) return;

    final daysUntilDeadline = project.daysUntilDeadline;
    if (daysUntilDeadline <= 0) return;

    // Schedule reminder 1 day before deadline
    final reminderDate = project.deadline.subtract(const Duration(days: 1));
    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: project.hashCode,
        title: 'Project Deadline Reminder',
        body: '${project.name} is due tomorrow!',
        scheduledDate: reminderDate,
        payload: 'project_deadline:${project.id}',
      );
    }
  }

  /// Schedule payment reminder
  Future<void> schedulePaymentReminder(dynamic project) async {
    if (project.outstandingBalance <= 0) return;

    // Schedule reminder for next week
    final reminderDate = DateTime.now().add(const Duration(days: 7));
    await scheduleNotification(
      id: project.hashCode + 1000,
      title: 'Payment Reminder',
      body:
          '${project.name} has \$${project.outstandingBalance.toStringAsFixed(2)} outstanding',
      scheduledDate: reminderDate,
      payload: 'payment_reminder:${project.id}',
    );
  }

  /// Schedule task reminder
  Future<void> scheduleTaskReminder(dynamic task, String projectName) async {
    if (task.dueDate == null) return;

    final daysUntilDue = task.dueDate.difference(DateTime.now()).inDays;
    if (daysUntilDue <= 0) return;

    // Schedule reminder 1 day before due date
    final reminderDate = task.dueDate.subtract(const Duration(days: 1));
    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: task.hashCode,
        title: 'Task Reminder',
        body: '$task.title in $projectName is due tomorrow!',
        scheduledDate: reminderDate,
        payload: 'task_reminder:${task.id}',
      );
    }
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}
