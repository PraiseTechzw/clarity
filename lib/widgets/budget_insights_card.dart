import 'package:flutter/material.dart';
import '../models/budget_models.dart';

class BudgetInsightsCard extends StatelessWidget {
  final List<BudgetInsight> insights;

  const BudgetInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Insights & Recommendations',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),

            const SizedBox(height: 16),

            ...insights
                .take(3)
                .map((insight) => _buildInsightItem(context, insight)),

            if (insights.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    // Navigate to full insights screen
                  },
                  child: Text('View ${insights.length - 3} more insights'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, BudgetInsight insight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: _getInsightColor(insight.type),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                if (insight.value != null && insight.unit != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${insight.value!.toStringAsFixed(2)} ${insight.unit}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: _getInsightColor(insight.type),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.spendingAlert:
      case InsightType.budgetExceeded:
        return Colors.red;
      case InsightType.savingsMilestone:
      case InsightType.achievement:
        return Colors.green;
      case InsightType.spendingTrend:
      case InsightType.categoryAnalysis:
        return Colors.blue;
      case InsightType.recommendation:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
