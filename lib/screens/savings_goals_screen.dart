import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/budget_models.dart';
import 'add_savings_goal_screen.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final goals = budgetProvider.savingsGoals;

          if (goals.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _buildGoalCard(context, budgetProvider, goal);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddGoal(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings, size: 64, color: Colors.green.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No Savings Goals',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first savings goal to start tracking your progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddGoal(),
              icon: const Icon(Icons.add),
              label: const Text('Add Savings Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    BudgetProvider budgetProvider,
    SavingsGoal goal,
  ) {
    final progress = goal.progress;
    final daysRemaining = goal.daysRemaining;
    final isCompleted = goal.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(goal.colorValue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    IconData(
                      goal.iconCodePoint,
                      fontFamily: goal.iconFontFamily,
                    ),
                    color: Color(goal.colorValue),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (goal.description.isNotEmpty)
                        Text(
                          goal.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleMenuAction(value, goal, budgetProvider),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: goal.isActive ? 'deactivate' : 'activate',
                      child: Row(
                        children: [
                          Icon(
                            goal.isActive ? Icons.pause : Icons.play_arrow,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(goal.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isCompleted ? Colors.green : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : Color(goal.colorValue),
                    ),
                    minHeight: 8,
                  ),
                ),

                const SizedBox(height: 8),

                // Amount Information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${goal.currentAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'of \$${goal.targetAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Remaining Information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining: \$${goal.remainingAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (daysRemaining > 0)
                      Text(
                        '$daysRemaining days left',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: daysRemaining < 30
                              ? Colors.orange
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddMoneyDialog(goal, budgetProvider),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Money'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(goal.colorValue),
                      side: BorderSide(color: Color(goal.colorValue)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showWithdrawMoneyDialog(goal, budgetProvider),
                    icon: const Icon(Icons.remove, size: 16),
                    label: const Text('Withdraw'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(goal.colorValue),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            if (!goal.isActive)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pause, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Inactive',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
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

  void _handleMenuAction(
    String action,
    SavingsGoal goal,
    BudgetProvider budgetProvider,
  ) {
    switch (action) {
      case 'edit':
        _navigateToEditGoal(goal);
        break;
      case 'activate':
      case 'deactivate':
        _toggleGoalStatus(goal, budgetProvider);
        break;
      case 'delete':
        _showDeleteDialog(goal, budgetProvider);
        break;
    }
  }

  void _navigateToAddGoal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSavingsGoalScreen()),
    );
  }

  void _navigateToEditGoal(SavingsGoal goal) {
    // Navigate to edit goal screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSavingsGoalScreen(editingGoal: goal),
      ),
    );
  }

  void _toggleGoalStatus(
    SavingsGoal goal,
    BudgetProvider budgetProvider,
  ) async {
    try {
      final updatedGoal = SavingsGoal(
        id: goal.id,
        name: goal.name,
        description: goal.description,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        targetDate: goal.targetDate,
        completedDate: goal.completedDate,
        icon: goal.icon,
        color: goal.color,
        isActive: !goal.isActive,
        iconCodePoint: goal.iconCodePoint,
        iconFontFamily: goal.iconFontFamily,
        colorValue: goal.colorValue,
      );

      await budgetProvider.updateSavingsGoal(updatedGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Goal ${updatedGoal.isActive ? 'activated' : 'deactivated'} successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating goal: $e')));
      }
    }
  }

  void _showDeleteDialog(SavingsGoal goal, BudgetProvider budgetProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Savings Goal'),
        content: Text(
          'Are you sure you want to delete "${goal.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteGoal(goal, budgetProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteGoal(SavingsGoal goal, BudgetProvider budgetProvider) async {
    try {
      await budgetProvider.deleteSavingsGoal(goal.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Savings goal deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting goal: $e')));
      }
    }
  }

  void _showAddMoneyDialog(SavingsGoal goal, BudgetProvider budgetProvider) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money to Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add money to "${goal.name}"'),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid amount';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                final amount = double.parse(amountController.text);
                _addMoneyToGoal(goal, amount, budgetProvider);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawMoneyDialog(
    SavingsGoal goal,
    BudgetProvider budgetProvider,
  ) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Money from Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Withdraw money from "${goal.name}"'),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
                helperText:
                    'Available: \$${goal.currentAmount.toStringAsFixed(2)}',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid amount';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                if (double.parse(value) > goal.currentAmount) {
                  return 'Amount cannot exceed current balance';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                final amount = double.parse(amountController.text);
                _withdrawMoneyFromGoal(goal, amount, budgetProvider);
                Navigator.pop(context);
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  void _addMoneyToGoal(
    SavingsGoal goal,
    double amount,
    BudgetProvider budgetProvider,
  ) async {
    try {
      final updatedGoal = SavingsGoal(
        id: goal.id,
        name: goal.name,
        description: goal.description,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount + amount,
        targetDate: goal.targetDate,
        completedDate: goal.completedDate,
        icon: goal.icon,
        color: goal.color,
        isActive: goal.isActive,
        iconCodePoint: goal.iconCodePoint,
        iconFontFamily: goal.iconFontFamily,
        colorValue: goal.colorValue,
      );

      await budgetProvider.updateSavingsGoal(updatedGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added \$${amount.toStringAsFixed(2)} to goal'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding money: $e')));
      }
    }
  }

  void _withdrawMoneyFromGoal(
    SavingsGoal goal,
    double amount,
    BudgetProvider budgetProvider,
  ) async {
    try {
      final updatedGoal = SavingsGoal(
        id: goal.id,
        name: goal.name,
        description: goal.description,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount - amount,
        targetDate: goal.targetDate,
        completedDate: goal.completedDate,
        icon: goal.icon,
        color: goal.color,
        isActive: goal.isActive,
        iconCodePoint: goal.iconCodePoint,
        iconFontFamily: goal.iconFontFamily,
        colorValue: goal.colorValue,
      );

      await budgetProvider.updateSavingsGoal(updatedGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrew \$${amount.toStringAsFixed(2)} from goal'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error withdrawing money: $e')));
      }
    }
  }
}
