import 'package:flutter/material.dart';
import '../models/budget_models.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetSummary summary;

  const BudgetSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: summary.isOverBudget
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    summary.isOverBudget ? 'Over Budget' : 'On Track',
                    style: TextStyle(
                      color: summary.isOverBudget ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Net Worth
            _buildSummaryRow(
              'Net Worth',
              '\$${summary.netWorth.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              summary.netWorth >= 0 ? Colors.green : Colors.red,
            ),

            const SizedBox(height: 16),

            // Budget Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Budget',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '\$${summary.budgetUsed.toStringAsFixed(2)} / \$${summary.monthlyBudget.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: summary.budgetUtilization,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    summary.isOverBudget ? Colors.red : Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(summary.budgetUtilization * 100).toStringAsFixed(1)}% used',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Income vs Expenses
            Row(
              children: [
                Expanded(
                  child: _buildSummaryRow(
                    'Income',
                    '\$${summary.totalIncome.toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryRow(
                    'Expenses',
                    '\$${summary.totalExpenses.toStringAsFixed(2)}',
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Savings
            _buildSummaryRow(
              'Savings',
              '\$${summary.totalSavings.toStringAsFixed(2)}',
              Icons.savings,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
