import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.clientName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPriorityChip(),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: project.progressPercentage / 100,
                          backgroundColor: colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            project.priorityColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${project.progressPercentage.toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${project.budget.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        _getPaymentStatusText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getPaymentStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: project.isOverdue
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getDeadlineText(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: project.isOverdue
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontWeight: project.isOverdue ? FontWeight.w500 : null,
                    ),
                  ),
                  const Spacer(),
                  if (project.notes != null && project.notes!.isNotEmpty)
                    Icon(
                      Icons.note,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: project.priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: project.priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        project.priority.name.toUpperCase(),
        style: TextStyle(
          color: project.priorityColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPaymentStatusText() {
    switch (project.paymentStatus) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.partiallyPaid:
        return 'Partial';
      case PaymentStatus.outstanding:
        return 'Outstanding';
    }
  }

  Color _getPaymentStatusColor() {
    switch (project.paymentStatus) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.partiallyPaid:
        return Colors.orange;
      case PaymentStatus.outstanding:
        return Colors.red;
    }
  }

  String _getDeadlineText() {
    final days = project.daysUntilDeadline;
    if (project.isOverdue) {
      return '${days.abs()} days overdue';
    } else if (days == 0) {
      return 'Due today';
    } else if (days == 1) {
      return 'Due tomorrow';
    } else {
      return '$days days left';
    }
  }
}
