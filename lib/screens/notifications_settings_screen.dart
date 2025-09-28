import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        centerTitle: true,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General Notifications
                _buildSectionCard(
                  context,
                  title: 'General Notifications',
                  children: [
                    _buildSwitchTile(
                      context,
                      title: 'Enable Notifications',
                      subtitle: 'Receive notifications from Clarity',
                      value: notificationProvider.notificationsEnabled,
                      onChanged: notificationProvider.toggleNotifications,
                    ),
                    if (notificationProvider.notificationsEnabled) ...[
                      const Divider(),
                      _buildInfoTile(
                        context,
                        title: 'FCM Token',
                        subtitle:
                            notificationProvider.fcmToken ?? 'Not available',
                        icon: Icons.token,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Project Notifications
                _buildSectionCard(
                  context,
                  title: 'Project Notifications',
                  children: [
                    _buildSwitchTile(
                      context,
                      title: 'Project Reminders',
                      subtitle: 'Get reminded about project updates',
                      value: notificationProvider.projectRemindersEnabled,
                      onChanged: notificationProvider.toggleProjectReminders,
                    ),
                    _buildSwitchTile(
                      context,
                      title: 'Deadline Alerts',
                      subtitle: 'Get notified about upcoming deadlines',
                      value: notificationProvider.deadlineAlertsEnabled,
                      onChanged: notificationProvider.toggleDeadlineAlerts,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Payment Notifications
                _buildSectionCard(
                  context,
                  title: 'Payment Notifications',
                  children: [
                    _buildSwitchTile(
                      context,
                      title: 'Payment Reminders',
                      subtitle: 'Get reminded about pending payments',
                      value: notificationProvider.paymentRemindersEnabled,
                      onChanged: notificationProvider.togglePaymentReminders,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Test Notifications
                _buildSectionCard(
                  context,
                  title: 'Test Notifications',
                  children: [
                    _buildActionTile(
                      context,
                      title: 'Test General Notification',
                      subtitle: 'Send a test notification',
                      icon: Icons.notifications,
                      onTap: () =>
                          _testGeneralNotification(notificationProvider),
                    ),
                    _buildActionTile(
                      context,
                      title: 'Test Project Reminder',
                      subtitle: 'Send a test project reminder',
                      icon: Icons.work,
                      onTap: () => _testProjectReminder(notificationProvider),
                    ),
                    _buildActionTile(
                      context,
                      title: 'Test Deadline Alert',
                      subtitle: 'Send a test deadline alert',
                      icon: Icons.schedule,
                      onTap: () => _testDeadlineAlert(notificationProvider),
                    ),
                    _buildActionTile(
                      context,
                      title: 'Test Payment Reminder',
                      subtitle: 'Send a test payment reminder',
                      icon: Icons.payment,
                      onTap: () => _testPaymentReminder(notificationProvider),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notification Management
                _buildSectionCard(
                  context,
                  title: 'Notification Management',
                  children: [
                    _buildActionTile(
                      context,
                      title: 'Clear All Notifications',
                      subtitle: 'Remove all pending notifications',
                      icon: Icons.clear_all,
                      onTap: () => _clearAllNotifications(notificationProvider),
                    ),
                    _buildActionTile(
                      context,
                      title: 'View Pending Notifications',
                      subtitle: 'See scheduled notifications',
                      icon: Icons.schedule,
                      onTap: () =>
                          _viewPendingNotifications(notificationProvider),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _testGeneralNotification(NotificationProvider provider) {
    provider.showGeneralNotification(
      title: 'Test Notification',
      message: 'This is a test notification from Clarity!',
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Test notification sent!')));
  }

  void _testProjectReminder(NotificationProvider provider) {
    provider.showProjectReminder(
      projectName: 'Test Project',
      message: 'This is a test project reminder!',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test project reminder sent!')),
    );
  }

  void _testDeadlineAlert(NotificationProvider provider) {
    provider.showDeadlineAlert(
      projectName: 'Test Project',
      taskName: 'Test Task',
      deadline: DateTime.now().add(const Duration(hours: 2)),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Test deadline alert sent!')));
  }

  void _testPaymentReminder(NotificationProvider provider) {
    provider.showPaymentReminder(
      clientName: 'Test Client',
      projectName: 'Test Project',
      amount: 1500.00,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test payment reminder sent!')),
    );
  }

  void _clearAllNotifications(NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all pending notifications?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.cancelAllNotifications();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cleared!')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _viewPendingNotifications(NotificationProvider provider) async {
    final pending = await provider.getPendingNotifications();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pending Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final notification = pending[index];
              return ListTile(
                title: Text(notification.title ?? 'No title'),
                subtitle: Text(notification.body ?? 'No body'),
                trailing: Text('ID: ${notification.id}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
