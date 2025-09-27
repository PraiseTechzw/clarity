import 'package:flutter/material.dart';
import '../models/project.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: task.isCompleted
            ? colorScheme.surfaceVariant.withOpacity(0.3)
            : null,
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (task.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: task.isOverdue && !task.isCompleted
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getDueDateText(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: task.isOverdue && !task.isCompleted
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontWeight: task.isOverdue && !task.isCompleted
                          ? FontWeight.w500
                          : null,
                    ),
                  ),
                ],
              ),
            ],
            if (task.isCompleted && task.completedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Completed ${_formatDate(task.completedAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.isOverdue && !task.isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'OVERDUE',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDueDateText() {
    if (task.dueDate == null) return '';

    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return '${difference.abs()} days overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $difference days';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
