import 'package:flutter/material.dart';
import '../models/project.dart';

class PaymentSummaryCard extends StatelessWidget {
  final Project project;

  const PaymentSummaryCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Budget Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Budget',
                    '\$${project.budget.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Paid',
                    '\$${project.totalPaid.toStringAsFixed(2)}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Outstanding Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Outstanding',
                    '\$${project.outstandingBalance.toStringAsFixed(2)}',
                    Icons.pending,
                    project.outstandingBalance > 0
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Progress',
                    '${(project.totalPaid / project.budget * 100).toStringAsFixed(0)}%',
                    Icons.trending_up,
                    _getProgressColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Progress',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${project.totalPaid.toStringAsFixed(0)} / ${project.budget.toStringAsFixed(0)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: project.totalPaid / project.budget,
                  backgroundColor: colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getPaymentStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getPaymentStatusColor().withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPaymentStatusIcon(),
                    color: _getPaymentStatusColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getPaymentStatusText(),
                    style: TextStyle(
                      color: _getPaymentStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
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
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    final progress = project.totalPaid / project.budget;
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _getPaymentStatusText() {
    switch (project.paymentStatus) {
      case PaymentStatus.paid:
        return 'Fully Paid';
      case PaymentStatus.partiallyPaid:
        return 'Partially Paid';
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

  IconData _getPaymentStatusIcon() {
    switch (project.paymentStatus) {
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.partiallyPaid:
        return Icons.pending;
      case PaymentStatus.outstanding:
        return Icons.warning;
    }
  }
}
