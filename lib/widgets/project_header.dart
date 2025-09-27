import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectHeader extends StatelessWidget {
  final Project project;

  const ProjectHeader({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            project.priorityColor.withOpacity(0.1),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
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
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.clientName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPriorityChip(),
                ],
              ),
              const SizedBox(height: 16),
              
              // Progress Section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${project.progressPercentage.toStringAsFixed(0)}%',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: project.priorityColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: project.progressPercentage / 100,
                          backgroundColor: colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            project.priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Budget',
                      '\$${project.budget.toStringAsFixed(0)}',
                      Icons.account_balance_wallet,
                      colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Paid',
                      '\$${project.totalPaid.toStringAsFixed(0)}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Outstanding',
                      '\$${project.outstandingBalance.toStringAsFixed(0)}',
                      Icons.pending,
                      project.outstandingBalance > 0 ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Deadline and Payment Status
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getPaymentStatusColor().withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getPaymentStatusText(),
                      style: TextStyle(
                        color: _getPaymentStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: project.priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: project.priorityColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        project.priority.name.toUpperCase(),
        style: TextStyle(
          color: project.priorityColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
}
