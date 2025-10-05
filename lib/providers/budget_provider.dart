import 'package:flutter/material.dart';
import '../models/budget_models.dart';
import '../services/budget_database_helper.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetDatabaseHelper _databaseHelper = BudgetDatabaseHelper();

  // State variables
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  List<Budget> _budgets = [];
  List<SavingsGoal> _savingsGoals = [];
  List<RecurringTransaction> _recurringTransactions = [];
  List<BudgetInsight> _insights = [];
  BudgetSummary? _summary;

  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Category> get categories => _categories;
  List<Budget> get budgets => _budgets;
  List<SavingsGoal> get savingsGoals => _savingsGoals;
  List<RecurringTransaction> get recurringTransactions =>
      _recurringTransactions;
  List<BudgetInsight> get insights => _insights;
  BudgetSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  // Initialize provider
  Future<void> initialize() async {
    await _loadInitialData();
  }

  // Load all initial data
  Future<void> _loadInitialData() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadCategories(),
        _loadTransactions(),
        _loadBudgets(),
        _loadSavingsGoals(),
        _loadRecurringTransactions(),
      ]);

      // Generate initial insights
      await _generateInsights();

      // Calculate summary
      await _calculateSummary();

      _error = null;
    } catch (e) {
      _error = 'Failed to load budget data: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Category management
  Future<void> _loadCategories() async {
    try {
      _categories = await _databaseHelper.getCategories();
      notifyListeners();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _databaseHelper.insertCategory(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _databaseHelper.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _databaseHelper.deleteCategory(categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
    }
  }

  // Transaction management
  Future<void> _loadTransactions() async {
    try {
      _transactions = await _databaseHelper.getTransactions();
      notifyListeners();
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _databaseHelper.insertTransaction(transaction);
      _transactions.add(transaction);
      await _generateInsights();
      await _calculateSummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add transaction: $e';
      notifyListeners();
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _databaseHelper.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        await _generateInsights();
        await _calculateSummary();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update transaction: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _databaseHelper.deleteTransaction(transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      await _generateInsights();
      await _calculateSummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete transaction: $e';
      notifyListeners();
    }
  }

  // Budget management
  Future<void> _loadBudgets() async {
    try {
      _budgets = await _databaseHelper.getBudgets();
      notifyListeners();
    } catch (e) {
      print('Error loading budgets: $e');
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await _databaseHelper.insertBudget(budget);
      _budgets.add(budget);
      await _generateInsights();
      await _calculateSummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add budget: $e';
      notifyListeners();
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _databaseHelper.updateBudget(budget);
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        await _generateInsights();
        await _calculateSummary();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update budget: $e';
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      await _databaseHelper.deleteBudget(budgetId);
      _budgets.removeWhere((b) => b.id == budgetId);
      await _generateInsights();
      await _calculateSummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete budget: $e';
      notifyListeners();
    }
  }

  // Savings goals management
  Future<void> _loadSavingsGoals() async {
    try {
      _savingsGoals = await _databaseHelper.getSavingsGoals();
      notifyListeners();
    } catch (e) {
      print('Error loading savings goals: $e');
    }
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    try {
      await _databaseHelper.insertSavingsGoal(goal);
      _savingsGoals.add(goal);
      await _generateInsights();
      await _calculateSummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add savings goal: $e';
      notifyListeners();
    }
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    try {
      await _databaseHelper.updateSavingsGoal(goal);
      final index = _savingsGoals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _savingsGoals[index] = goal;
        await _generateInsights();
        await _calculateSummary();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update savings goal: $e';
      notifyListeners();
    }
  }

  Future<void> deleteSavingsGoal(String goalId) async {
    try {
      await _databaseHelper.deleteSavingsGoal(goalId);
      _savingsGoals.removeWhere((g) => g.id == goalId);
      await _generateInsights();
      await _calculateSummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete savings goal: $e';
      notifyListeners();
    }
  }

  // Recurring transactions management
  Future<void> _loadRecurringTransactions() async {
    try {
      _recurringTransactions = await _databaseHelper.getRecurringTransactions();
      notifyListeners();
    } catch (e) {
      print('Error loading recurring transactions: $e');
    }
  }

  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    try {
      await _databaseHelper.insertRecurringTransaction(transaction);
      _recurringTransactions.add(transaction);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add recurring transaction: $e';
      notifyListeners();
    }
  }

  Future<void> updateRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    try {
      await _databaseHelper.updateRecurringTransaction(transaction);
      final index = _recurringTransactions.indexWhere(
        (t) => t.id == transaction.id,
      );
      if (index != -1) {
        _recurringTransactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update recurring transaction: $e';
      notifyListeners();
    }
  }

  Future<void> deleteRecurringTransaction(String transactionId) async {
    try {
      await _databaseHelper.deleteRecurringTransaction(transactionId);
      _recurringTransactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete recurring transaction: $e';
      notifyListeners();
    }
  }

  // Generate intelligent insights
  Future<void> _generateInsights() async {
    try {
      _insights.clear();

      // Analyze spending patterns
      await _analyzeSpendingPatterns();

      // Check budget utilization
      await _analyzeBudgetUtilization();

      // Analyze savings progress
      await _analyzeSavingsProgress();

      // Generate recommendations
      await _generateRecommendations();

      notifyListeners();
    } catch (e) {
      print('Error generating insights: $e');
    }
  }

  Future<void> _analyzeSpendingPatterns() async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final thisMonth = DateTime(now.year, now.month, 1);

    final lastMonthExpenses = _transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.isAfter(lastMonth) &&
              t.date.isBefore(thisMonth),
        )
        .fold<double>(0, (sum, t) => sum + t.amount);

    final thisMonthExpenses = _transactions
        .where(
          (t) => t.type == TransactionType.expense && t.date.isAfter(thisMonth),
        )
        .fold<double>(0, (sum, t) => sum + t.amount);

    if (thisMonthExpenses > lastMonthExpenses * 1.2) {
      _insights.add(
        BudgetInsight(
          title: 'Spending Alert',
          description:
              'Your spending this month is ${((thisMonthExpenses / lastMonthExpenses - 1) * 100).toStringAsFixed(1)}% higher than last month.',
          type: InsightType.spendingAlert,
          value: thisMonthExpenses - lastMonthExpenses,
          unit: 'currency',
        ),
      );
    }
  }

  Future<void> _analyzeBudgetUtilization() async {
    final currentBudget = _getCurrentBudget();
    if (currentBudget == null) return;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final monthExpenses = _transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.isAfter(monthStart) &&
              t.date.isBefore(monthEnd),
        )
        .fold<double>(0, (sum, t) => sum + t.amount);

    final utilization = monthExpenses / currentBudget.totalAmount;

    if (utilization > 0.9) {
      _insights.add(
        BudgetInsight(
          title: 'Budget Warning',
          description:
              'You\'ve used ${(utilization * 100).toStringAsFixed(1)}% of your monthly budget.',
          type: InsightType.budgetExceeded,
          value: utilization,
          unit: 'percentage',
        ),
      );
    }
  }

  Future<void> _analyzeSavingsProgress() async {
    for (final goal in _savingsGoals.where((g) => g.isActive)) {
      if (goal.progress >= 0.5 && goal.progress < 1.0) {
        _insights.add(
          BudgetInsight(
            title: 'Savings Milestone',
            description:
                'You\'re ${(goal.progress * 100).toStringAsFixed(1)}% towards your "${goal.name}" goal!',
            type: InsightType.savingsMilestone,
            value: goal.progress,
            unit: 'percentage',
          ),
        );
      }
    }
  }

  Future<void> _generateRecommendations() async {
    // Analyze top spending categories
    final categorySpending = <String, double>{};
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    for (final transaction in _transactions.where(
      (t) => t.type == TransactionType.expense && t.date.isAfter(monthStart),
    )) {
      categorySpending[transaction.categoryId] =
          (categorySpending[transaction.categoryId] ?? 0) + transaction.amount;
    }

    if (categorySpending.isNotEmpty) {
      final topCategory = categorySpending.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      final category = _categories.firstWhere(
        (c) => c.id == topCategory.key,
        orElse: () => Category(
          name: 'Unknown',
          icon: '❓',
          color: '#000000',
          type: TransactionType.expense,
        ),
      );

      _insights.add(
        BudgetInsight(
          title: 'Spending Analysis',
          description:
              'Your highest spending category is "${category.name}" with ${topCategory.value.toStringAsFixed(2)} this month.',
          type: InsightType.categoryAnalysis,
          value: topCategory.value,
          unit: 'currency',
        ),
      );
    }
  }

  // Calculate budget summary
  Future<void> _calculateSummary() async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);

      final monthTransactions = _transactions.where(
        (t) => t.date.isAfter(monthStart) && t.date.isBefore(monthEnd),
      );

      final totalIncome = monthTransactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final totalExpenses = monthTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final totalSavings = monthTransactions
          .where((t) => t.type == TransactionType.savings)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final currentBudget = _getCurrentBudget();
      final monthlyBudget = currentBudget?.totalAmount ?? 0.0;
      final budgetUsed = totalExpenses;
      final budgetRemaining = monthlyBudget - budgetUsed;

      // Calculate category spending
      final categorySpending = <CategorySpending>[];
      final categoryTotals = <String, double>{};

      for (final transaction in monthTransactions.where(
        (t) => t.type == TransactionType.expense,
      )) {
        categoryTotals[transaction.categoryId] =
            (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;
      }

      for (final entry in categoryTotals.entries) {
        final category = _categories.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => Category(
            name: 'Unknown',
            icon: '❓',
            color: '#000000',
            type: TransactionType.expense,
          ),
        );

        final budget = currentBudget?.categoryBudgets[entry.key] ?? 0.0;
        final percentage = totalExpenses > 0
            ? (entry.value / totalExpenses) * 100
            : 0.0;

        categorySpending.add(
          CategorySpending(
            categoryId: entry.key,
            categoryName: category.name,
            amount: entry.value,
            budget: budget,
            percentage: percentage,
          ),
        );
      }

      _summary = BudgetSummary(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        totalSavings: totalSavings,
        netWorth: totalIncome - totalExpenses + totalSavings,
        monthlyBudget: monthlyBudget,
        budgetUsed: budgetUsed,
        budgetRemaining: budgetRemaining,
        categorySpending: categorySpending,
        insights: _insights,
      );

      notifyListeners();
    } catch (e) {
      print('Error calculating summary: $e');
    }
  }

  Budget? _getCurrentBudget() {
    final now = DateTime.now();
    return _budgets.firstWhere(
      (b) => b.isActive && b.startDate.isBefore(now) && b.endDate.isAfter(now),
      orElse: () => Budget(
        name: 'No Budget',
        totalAmount: 0,
        startDate: now,
        endDate: now,
        period: BudgetPeriod.monthly,
      ),
    );
  }

  // Filter transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get transactions by category
  List<Transaction> getTransactionsByCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get categories by type
  List<Category> getCategoriesByType(TransactionType type) {
    return _categories.where((c) => c.type == type && c.isActive).toList();
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    await _loadInitialData();
  }
}
