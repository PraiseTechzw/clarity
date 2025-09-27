import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              if (!value) {
                _notificationService.cancelAllNotifications();
              }
            },
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final upcomingDeadlines = _getUpcomingDeadlines(provider.projects);
          final overdueProjects = provider.overdueProjects;
          final outstandingPayments = provider.projectsWithOutstandingPayments;
          final upcomingTasks = _getUpcomingTasks(provider.projects);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Notification Settings
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notification Settings'),
                  subtitle: Text(
                    _notificationsEnabled
                        ? 'Notifications are enabled'
                        : 'Notifications are disabled',
                  ),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      if (!value) {
                        _notificationService.cancelAllNotifications();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Overdue Projects
              if (overdueProjects.isNotEmpty) ...[
                _buildSectionHeader(
                  'Overdue Projects',
                  Icons.warning,
                  Colors.red,
                ),
                const SizedBox(height: 8),
                ...overdueProjects.map(
                  (project) => _buildNotificationCard(
                    context,
                    'Project Overdue',
                    '${project.name} was due ${project.daysUntilDeadline.abs()} days ago',
                    Icons.warning,
                    Colors.red,
                    () => _scheduleProjectReminders(project),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Outstanding Payments
              if (outstandingPayments.isNotEmpty) ...[
                _buildSectionHeader(
                  'Outstanding Payments',
                  Icons.payment,
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                ...outstandingPayments.map(
                  (project) => _buildNotificationCard(
                    context,
                    'Payment Outstanding',
                    '${project.name} has \$${project.outstandingBalance.toStringAsFixed(2)} outstanding',
                    Icons.payment,
                    Colors.orange,
                    () => _schedulePaymentReminders(project),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Upcoming Deadlines
              if (upcomingDeadlines.isNotEmpty) ...[
                _buildSectionHeader(
                  'Upcoming Deadlines',
                  Icons.schedule,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                ...upcomingDeadlines.map(
                  (project) => _buildNotificationCard(
                    context,
                    'Deadline Approaching',
                    '${project.name} is due in ${project.daysUntilDeadline} days',
                    Icons.schedule,
                    Colors.blue,
                    () => _scheduleProjectReminders(project),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Upcoming Tasks
              if (upcomingTasks.isNotEmpty) ...[
                _buildSectionHeader(
                  'Upcoming Tasks',
                  Icons.task,
                  Colors.purple,
                ),
                const SizedBox(height: 8),
                ...upcomingTasks.map(
                  (task) => _buildNotificationCard(
                    context,
                    'Task Due Soon',
                    '${task.title} is due ${_getTaskDueText(task)}',
                    Icons.task,
                    Colors.purple,
                    () => _scheduleTaskReminders(task),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // All Good Message
              if (overdueProjects.isEmpty &&
                  outstandingPayments.isEmpty &&
                  upcomingDeadlines.isEmpty &&
                  upcomingTasks.isEmpty)
                _buildAllGoodMessage(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onSchedule,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: _notificationsEnabled
            ? IconButton(
                icon: const Icon(Icons.notifications_active),
                onPressed: onSchedule,
                tooltip: 'Schedule Reminder',
              )
            : const Icon(Icons.notifications_off, color: Colors.grey),
      ),
    );
  }

  Widget _buildAllGoodMessage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'All Caught Up!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No urgent notifications at the moment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Project> _getUpcomingDeadlines(List<Project> projects) {
    return projects
        .where(
          (project) =>
              project.daysUntilDeadline > 0 && project.daysUntilDeadline <= 7,
        )
        .toList()
      ..sort((a, b) => a.daysUntilDeadline.compareTo(b.daysUntilDeadline));
  }

  List<Task> _getUpcomingTasks(List<Project> projects) {
    final tasks = <Task>[];
    for (final project in projects) {
      for (final phase in project.phases) {
        for (final task in phase.tasks) {
          if (task.dueDate != null &&
              !task.isCompleted &&
              task.dueDate!.difference(DateTime.now()).inDays <= 7) {
            tasks.add(task);
          }
        }
      }
    }
    tasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return tasks;
  }

  String _getTaskDueText(Task task) {
    final days = task.dueDate!.difference(DateTime.now()).inDays;
    if (days == 0) return 'today';
    if (days == 1) return 'tomorrow';
    return 'in $days days';
  }

  void _scheduleProjectReminders(Project project) {
    if (!_notificationsEnabled) return;

    _notificationService.scheduleProjectDeadlineReminder(project);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminders scheduled for this project')),
    );
  }

  void _schedulePaymentReminders(Project project) {
    if (!_notificationsEnabled) return;

    _notificationService.schedulePaymentReminder(project);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Payment reminder scheduled')));
  }

  void _scheduleTaskReminders(Task task) {
    if (!_notificationsEnabled) return;

    // Find the project this task belongs to
    final provider = context.read<ProjectProvider>();
    for (final project in provider.projects) {
      for (final phase in project.phases) {
        if (phase.tasks.any((t) => t.id == task.id)) {
          _notificationService.scheduleTaskReminder(task, project.name);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task reminder scheduled')),
          );
          return;
        }
      }
    }
  }
}
