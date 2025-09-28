import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/sync_provider.dart';
import 'sync_animation_widget.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  colorScheme.surface,
                  colorScheme.surface.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with project name and priority
                  _buildHeader(theme, colorScheme),
                  const SizedBox(height: 16),

                  // Progress section
                  _buildProgressSection(theme, colorScheme),
                  const SizedBox(height: 16),

                  // Budget and payment status
                  _buildBudgetSection(theme, colorScheme),
                  const SizedBox(height: 16),

                  // Deadline and additional info
                  _buildFooterSection(theme, colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        // Project icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: project.priorityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.folder_outlined,
            color: project.priorityColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // Project name and client
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project.clientName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Priority chip and sync status
        Row(
          children: [
            Consumer<SyncProvider>(
              builder: (context, syncProvider, child) {
                return SyncStatusIndicator(
                  isSyncing: syncProvider.isSyncing,
                  status: syncProvider.syncStatus,
                  isOnline: syncProvider.isOnline,
                  isSignedIn: syncProvider.isSignedIn,
                );
              },
            ),
            const SizedBox(width: 8),
            _buildPriorityChip(),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${project.progressPercentage.toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: project.priorityColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: colorScheme.surfaceVariant,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: project.progressPercentage / 100,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(project.priorityColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSection(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        // Budget amount
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  '\$${NumberFormat('#,###').format(project.budget.toInt())}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Payment status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getPaymentStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getPaymentStatusColor().withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _getPaymentStatusText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getPaymentStatusColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSection(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        // Deadline
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: project.isOverdue
                      ? colorScheme.errorContainer.withOpacity(0.3)
                      : colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.schedule,
                  size: 14,
                  color: project.isOverdue
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getDeadlineText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: project.isOverdue
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                    fontWeight: project.isOverdue
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Additional indicators
        Row(
          children: [
            if (project.notes != null && project.notes!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.note_outlined,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Overdue indicator
            if (project.isOverdue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'OVERDUE',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: project.priorityColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: project.priorityColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: project.priorityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            project.priority.name.toUpperCase(),
            style: TextStyle(
              color: project.priorityColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
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
