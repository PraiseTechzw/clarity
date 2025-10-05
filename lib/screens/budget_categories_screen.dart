import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/budget_models.dart';
import 'add_category_screen.dart';

class BudgetCategoriesScreen extends StatefulWidget {
  const BudgetCategoriesScreen({super.key});

  @override
  State<BudgetCategoriesScreen> createState() => _BudgetCategoriesScreenState();
}

class _BudgetCategoriesScreenState extends State<BudgetCategoriesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Categories'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
            Tab(text: 'Savings'),
            Tab(text: 'Transfer'),
          ],
        ),
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(budgetProvider, TransactionType.income),
              _buildCategoryList(budgetProvider, TransactionType.expense),
              _buildCategoryList(budgetProvider, TransactionType.savings),
              _buildCategoryList(budgetProvider, TransactionType.transfer),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddCategory(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Widget _buildCategoryList(
    BudgetProvider budgetProvider,
    TransactionType type,
  ) {
    final categories = budgetProvider.categories
        .where((cat) => cat.type == type)
        .toList();

    if (categories.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, budgetProvider, category);
      },
    );
  }

  Widget _buildEmptyState(TransactionType type) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTypeIcon(type),
              size: 64,
              color: _getTypeColor(type).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_getTypeLabel(type)} Categories',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first ${_getTypeLabel(type).toLowerCase()} category to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddCategory(),
              icon: const Icon(Icons.add),
              label: Text('Add ${_getTypeLabel(type)} Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getTypeColor(type),
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

  Widget _buildCategoryCard(
    BuildContext context,
    BudgetProvider budgetProvider,
    Category category,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(category.colorValue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            IconData(
              category.iconCodePoint,
              fontFamily: category.iconFontFamily,
            ),
            color: Color(category.colorValue),
            size: 24,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.description.isNotEmpty)
              Text(
                category.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            if (category.budgetLimit != null) ...[
              const SizedBox(height: 4),
              Text(
                'Budget: \$${category.budgetLimit!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!category.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Inactive',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleMenuAction(value, category, budgetProvider),
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
                  value: category.isActive ? 'deactivate' : 'activate',
                  child: Row(
                    children: [
                      Icon(
                        category.isActive ? Icons.pause : Icons.play_arrow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(category.isActive ? 'Deactivate' : 'Activate'),
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
      ),
    );
  }

  void _handleMenuAction(
    String action,
    Category category,
    BudgetProvider budgetProvider,
  ) {
    switch (action) {
      case 'edit':
        _navigateToEditCategory(category);
        break;
      case 'activate':
      case 'deactivate':
        _toggleCategoryStatus(category, budgetProvider);
        break;
      case 'delete':
        _showDeleteDialog(category, budgetProvider);
        break;
    }
  }

  void _navigateToAddCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCategoryScreen()),
    );
  }

  void _navigateToEditCategory(Category category) {
    // Navigate to edit category screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCategoryScreen(editingCategory: category),
      ),
    );
  }

  void _toggleCategoryStatus(
    Category category,
    BudgetProvider budgetProvider,
  ) async {
    try {
      final updatedCategory = Category(
        id: category.id,
        name: category.name,
        description: category.description,
        icon: category.icon,
        color: category.color,
        type: category.type,
        budgetLimit: category.budgetLimit,
        isActive: !category.isActive,
        iconCodePoint: category.iconCodePoint,
        iconFontFamily: category.iconFontFamily,
        colorValue: category.colorValue,
      );

      await budgetProvider.updateCategory(updatedCategory);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Category ${updatedCategory.isActive ? 'activated' : 'deactivated'} successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating category: $e')));
      }
    }
  }

  void _showDeleteDialog(Category category, BudgetProvider budgetProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category, budgetProvider);
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

  void _deleteCategory(Category category, BudgetProvider budgetProvider) async {
    try {
      await budgetProvider.deleteCategory(category.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting category: $e')));
      }
    }
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.savings:
        return Colors.purple;
      case TransactionType.transfer:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.trending_up;
      case TransactionType.expense:
        return Icons.trending_down;
      case TransactionType.savings:
        return Icons.savings;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.savings:
        return 'Savings';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }
}
