import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

// Transaction model for income and expenses
class Transaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? recurringId; // For recurring transactions
  final Map<String, dynamic>? metadata;

  Transaction({
    String? id,
    required this.title,
    this.description = '',
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.recurringId,
    this.metadata,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'amount': amount,
    'type': type.toString().split('.').last,
    'categoryId': categoryId,
    'date': date.toIso8601String(),
    'recurringId': recurringId,
    'metadata': metadata,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    amount: (json['amount'] as num).toDouble(),
    type: TransactionType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'],
    ),
    categoryId: json['categoryId'],
    date: DateTime.parse(json['date']),
    recurringId: json['recurringId'],
    metadata: json['metadata'] != null
        ? Map<String, dynamic>.from(json['metadata'])
        : null,
  );

  Transaction copyWith({
    String? title,
    String? description,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? recurringId,
    Map<String, dynamic>? metadata,
  }) => Transaction(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    categoryId: categoryId ?? this.categoryId,
    date: date ?? this.date,
    recurringId: recurringId ?? this.recurringId,
    metadata: metadata ?? this.metadata,
  );
}

enum TransactionType { income, expense, transfer, savings }

// Category model for organizing transactions
class Category {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final TransactionType type;
  final double? budgetLimit;
  final bool isActive;

  // Additional properties for enhanced UI
  final int iconCodePoint;
  final String iconFontFamily;
  final int colorValue;

  Category({
    String? id,
    required this.name,
    this.description = '',
    required this.icon,
    required this.color,
    required this.type,
    this.budgetLimit,
    this.isActive = true,
    int? iconCodePoint,
    String? iconFontFamily,
    int? colorValue,
  }) : id = id ?? const Uuid().v4(),
       iconCodePoint = iconCodePoint ?? Icons.category.codePoint,
       iconFontFamily = iconFontFamily ?? 'MaterialIcons',
       colorValue = colorValue ?? Colors.blue.value;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'color': color,
    'type': type.toString().split('.').last,
    'budgetLimit': budgetLimit,
    'isActive': isActive,
    'iconCodePoint': iconCodePoint,
    'iconFontFamily': iconFontFamily,
    'colorValue': colorValue,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    icon: json['icon'],
    color: json['color'],
    type: TransactionType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'],
    ),
    budgetLimit: json['budgetLimit']?.toDouble(),
    isActive: json['isActive'] ?? true,
    iconCodePoint: json['iconCodePoint'] ?? Icons.category.codePoint,
    iconFontFamily: json['iconFontFamily'] ?? 'MaterialIcons',
    colorValue: json['colorValue'] ?? Colors.blue.value,
  );

  Category copyWith({
    String? name,
    String? description,
    String? icon,
    String? color,
    TransactionType? type,
    double? budgetLimit,
    bool? isActive,
  }) => Category(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    type: type ?? this.type,
    budgetLimit: budgetLimit ?? this.budgetLimit,
    isActive: isActive ?? this.isActive,
  );
}

// Budget model for monthly/yearly budget planning
class Budget {
  final String id;
  final String name;
  final String description;
  final double totalAmount;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPeriod period;
  final Map<String, double> categoryBudgets; // categoryId -> amount
  final bool isActive;

  Budget({
    String? id,
    required this.name,
    this.description = '',
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    required this.period,
    this.categoryBudgets = const {},
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'totalAmount': totalAmount,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'period': period.toString().split('.').last,
    'categoryBudgets': categoryBudgets,
    'isActive': isActive,
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    totalAmount: (json['totalAmount'] as num).toDouble(),
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    period: BudgetPeriod.values.firstWhere(
      (e) => e.toString().split('.').last == json['period'],
    ),
    categoryBudgets: Map<String, double>.from(
      json['categoryBudgets']?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
    ),
    isActive: json['isActive'] ?? true,
  );

  Budget copyWith({
    String? name,
    String? description,
    double? totalAmount,
    DateTime? startDate,
    DateTime? endDate,
    BudgetPeriod? period,
    Map<String, double>? categoryBudgets,
    bool? isActive,
  }) => Budget(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    totalAmount: totalAmount ?? this.totalAmount,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    period: period ?? this.period,
    categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    isActive: isActive ?? this.isActive,
  );
}

enum BudgetPeriod { monthly, quarterly, yearly, custom }

// Savings goal model
class SavingsGoal {
  final String id;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime? completedDate;
  final String icon;
  final String color;
  final bool isActive;

  // Additional properties for enhanced UI
  final int iconCodePoint;
  final String iconFontFamily;
  final int colorValue;

  SavingsGoal({
    String? id,
    required this.name,
    this.description = '',
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    this.completedDate,
    required this.icon,
    required this.color,
    this.isActive = true,
    int? iconCodePoint,
    String? iconFontFamily,
    int? colorValue,
  }) : id = id ?? const Uuid().v4(),
       iconCodePoint = iconCodePoint ?? Icons.savings.codePoint,
       iconFontFamily = iconFontFamily ?? 'MaterialIcons',
       colorValue = colorValue ?? Colors.green.value;

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => currentAmount >= targetAmount;
  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
    'completedDate': completedDate?.toIso8601String(),
    'icon': icon,
    'color': color,
    'isActive': isActive,
    'iconCodePoint': iconCodePoint,
    'iconFontFamily': iconFontFamily,
    'colorValue': colorValue,
  };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    targetAmount: (json['targetAmount'] as num).toDouble(),
    currentAmount: (json['currentAmount'] as num).toDouble(),
    targetDate: DateTime.parse(json['targetDate']),
    completedDate: json['completedDate'] != null
        ? DateTime.parse(json['completedDate'])
        : null,
    icon: json['icon'],
    color: json['color'],
    isActive: json['isActive'] ?? true,
    iconCodePoint: json['iconCodePoint'] ?? Icons.savings.codePoint,
    iconFontFamily: json['iconFontFamily'] ?? 'MaterialIcons',
    colorValue: json['colorValue'] ?? Colors.green.value,
  );

  SavingsGoal copyWith({
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? completedDate,
    String? icon,
    String? color,
    bool? isActive,
  }) => SavingsGoal(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    targetAmount: targetAmount ?? this.targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    targetDate: targetDate ?? this.targetDate,
    completedDate: completedDate ?? this.completedDate,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    isActive: isActive ?? this.isActive,
  );
}

// Recurring transaction model
class RecurringTransaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final RecurrenceType recurrenceType;
  final int recurrenceInterval; // e.g., every 2 weeks
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  RecurringTransaction({
    String? id,
    required this.title,
    this.description = '',
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.recurrenceType,
    this.recurrenceInterval = 1,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'amount': amount,
    'type': type.toString().split('.').last,
    'categoryId': categoryId,
    'recurrenceType': recurrenceType.toString().split('.').last,
    'recurrenceInterval': recurrenceInterval,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isActive': isActive,
  };

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) =>
      RecurringTransaction(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
        ),
        categoryId: json['categoryId'],
        recurrenceType: RecurrenceType.values.firstWhere(
          (e) => e.toString().split('.').last == json['recurrenceType'],
        ),
        recurrenceInterval: json['recurrenceInterval'] ?? 1,
        startDate: DateTime.parse(json['startDate']),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'])
            : null,
        isActive: json['isActive'] ?? true,
      );
}

enum RecurrenceType { daily, weekly, monthly, quarterly, yearly }

// Budget insights and analytics
class BudgetInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final double? value;
  final String? unit;
  final String? actionText;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  BudgetInsight({
    String? id,
    required this.title,
    required this.description,
    required this.type,
    this.value,
    this.unit,
    this.actionText,
    DateTime? createdAt,
    this.metadata,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.toString().split('.').last,
    'value': value,
    'unit': unit,
    'actionText': actionText,
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };

  factory BudgetInsight.fromJson(Map<String, dynamic> json) => BudgetInsight(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    type: InsightType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'],
    ),
    value: json['value']?.toDouble(),
    unit: json['unit'],
    actionText: json['actionText'],
    createdAt: DateTime.parse(json['createdAt']),
    metadata: json['metadata'] != null
        ? Map<String, dynamic>.from(json['metadata'])
        : null,
  );
}

enum InsightType {
  warning,
  success,
  info,
  tip,
  spendingAlert,
  budgetExceeded,
  savingsMilestone,
  spendingTrend,
  categoryAnalysis,
  recommendation,
  achievement,
}

// Budget summary for dashboard
class BudgetSummary {
  final double totalIncome;
  final double totalExpenses;
  final double totalSavings;
  final double netWorth;
  final double monthlyBudget;
  final double budgetUsed;
  final double budgetRemaining;
  final List<CategorySpending> categorySpending;
  final List<BudgetInsight> insights;

  // Additional properties for enhanced UI
  double get totalBudget => monthlyBudget;
  double get budgetUtilization =>
      monthlyBudget > 0 ? budgetUsed / monthlyBudget : 0.0;
  int get categoryCount => categorySpending.length;

  BudgetSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSavings,
    required this.netWorth,
    required this.monthlyBudget,
    required this.budgetUsed,
    required this.budgetRemaining,
    required this.categorySpending,
    required this.insights,
  });

  bool get isOverBudget => budgetUsed > monthlyBudget;
}

class CategorySpending {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double budget;
  final double percentage;

  CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.budget,
    required this.percentage,
  });
}
