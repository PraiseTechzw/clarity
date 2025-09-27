import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _projectDeadlines = true;
  bool _paymentReminders = true;
  bool _taskReminders = true;
  bool _clientUpdates = false;
  bool _systemUpdates = true;
  bool _marketingEmails = false;
  
  String _reminderTime = '09:00';
  bool _weekendNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Notifications
            _buildSectionCard(
              title: 'Project Notifications',
              icon: Icons.folder,
              color: Colors.blue,
              children: [
                _buildSwitchTile(
                  'Project Deadlines',
                  'Get notified when project deadlines are approaching',
                  _projectDeadlines,
                  (value) => setState(() => _projectDeadlines = value),
                ),
                _buildSwitchTile(
                  'Payment Reminders',
                  'Remind clients about outstanding payments',
                  _paymentReminders,
                  (value) => setState(() => _paymentReminders = value),
                ),
                _buildSwitchTile(
                  'Task Reminders',
                  'Get notified about upcoming tasks',
                  _taskReminders,
                  (value) => setState(() => _taskReminders = value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Communication
            _buildSectionCard(
              title: 'Communication',
              icon: Icons.message,
              color: Colors.green,
              children: [
                _buildSwitchTile(
                  'Client Updates',
                  'Notifications about client activities',
                  _clientUpdates,
                  (value) => setState(() => _clientUpdates = value),
                ),
                _buildSwitchTile(
                  'System Updates',
                  'Important app updates and maintenance',
                  _systemUpdates,
                  (value) => setState(() => _systemUpdates = value),
                ),
                _buildSwitchTile(
                  'Marketing Emails',
                  'Product updates and tips (optional)',
                  _marketingEmails,
                  (value) => setState(() => _marketingEmails = value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Timing Settings
            _buildSectionCard(
              title: 'Timing Settings',
              icon: Icons.schedule,
              color: Colors.orange,
              children: [
                _buildListTile(
                  'Daily Reminder Time',
                  'Choose when to receive daily notifications',
                  _reminderTime,
                  Icons.access_time,
                  () => _selectReminderTime(),
                ),
                _buildSwitchTile(
                  'Weekend Notifications',
                  'Receive notifications on weekends',
                  _weekendNotifications,
                  (value) => setState(() => _weekendNotifications = value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notification Types
            _buildSectionCard(
              title: 'Notification Types',
              icon: Icons.notifications,
              color: Colors.purple,
              children: [
                _buildNotificationTypeTile(
                  'Push Notifications',
                  'Show notifications on your device',
                  true,
                ),
                _buildNotificationTypeTile(
                  'Email Notifications',
                  'Send notifications via email',
                  true,
                ),
                _buildNotificationTypeTile(
                  'SMS Notifications',
                  'Send notifications via SMS',
                  false,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Test Notifications
            _buildTestSection(),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    String trailing,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trailing),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildNotificationTypeTile(
    String title,
    String subtitle,
    bool enabled,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: enabled,
        onChanged: (value) {
          // Handle notification type toggle
        },
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Test Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Send a test notification to make sure everything is working correctly.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sendTestNotification,
                    icon: const Icon(Icons.send),
                    label: const Text('Send Test'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendTestEmail,
                    icon: const Icon(Icons.email),
                    label: const Text('Test Email'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectReminderTime() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.parse('2024-01-01 $_reminderTime:00'),
      ),
    ).then((time) {
      if (time != null) {
        setState(() {
          _reminderTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  void _sendTestNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendTestEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test email sent!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
