import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/budget_models.dart' as budget_models;

class BudgetDatabaseHelper {
  static final BudgetDatabaseHelper _instance =
      BudgetDatabaseHelper._internal();
  factory BudgetDatabaseHelper() => _instance;
  BudgetDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'budget_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        type TEXT NOT NULL,
        budget_limit REAL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        recurring_id TEXT,
        metadata TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        total_amount REAL NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        period TEXT NOT NULL,
        category_budgets TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Savings goals table
    await db.execute('''
      CREATE TABLE savings_goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0,
        target_date INTEGER NOT NULL,
        completed_date INTEGER,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Recurring transactions table
    await db.execute('''
      CREATE TABLE recurring_transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        recurrence_type TEXT NOT NULL,
        recurrence_interval INTEGER NOT NULL DEFAULT 1,
        start_date INTEGER NOT NULL,
        end_date INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Budget insights table
    await db.execute('''
      CREATE TABLE budget_insights (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        value REAL,
        unit TEXT,
        metadata TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_transactions_date ON transactions (date)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_category ON transactions (category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_type ON transactions (type)',
    );
    await db.execute('CREATE INDEX idx_categories_type ON categories (type)');
    await db.execute('CREATE INDEX idx_budgets_active ON budgets (is_active)');
    await db.execute(
      'CREATE INDEX idx_savings_goals_active ON savings_goals (is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_recurring_transactions_active ON recurring_transactions (is_active)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  // Category operations
  Future<void> insertCategory(budget_models.Category category) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('categories', {
      ...category.toJson(),
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<List<budget_models.Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'name ASC',
    );

    return List.generate(
      maps.length,
      (i) => budget_models.Category.fromJson(maps[i]),
    );
  }

  Future<budget_models.Category?> getCategory(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return budget_models.Category.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateCategory(budget_models.Category category) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'categories',
      {...category.toJson(), 'updated_at': now},
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Transaction operations
  Future<void> insertTransaction(budget_models.Transaction transaction) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('transactions', {
      ...transaction.toJson(),
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<List<budget_models.Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );

    return List.generate(
      maps.length,
      (i) => budget_models.Transaction.fromJson(maps[i]),
    );
  }

  Future<List<budget_models.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );

    return List.generate(
      maps.length,
      (i) => budget_models.Transaction.fromJson(maps[i]),
    );
  }

  Future<List<budget_models.Transaction>> getTransactionsByCategory(
    String categoryId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );

    return List.generate(
      maps.length,
      (i) => budget_models.Transaction.fromJson(maps[i]),
    );
  }

  Future<budget_models.Transaction?> getTransaction(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return budget_models.Transaction.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateTransaction(budget_models.Transaction transaction) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'transactions',
      {...transaction.toJson(), 'updated_at': now},
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Budget operations
  Future<void> insertBudget(budget_models.Budget budget) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('budgets', {
      ...budget.toJson(),
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<List<budget_models.Budget>> getBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      orderBy: 'created_at DESC',
    );

    return List.generate(
      maps.length,
      (i) => budget_models.Budget.fromJson(maps[i]),
    );
  }

  Future<budget_models.Budget?> getBudget(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return budget_models.Budget.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateBudget(budget_models.Budget budget) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'budgets',
      {...budget.toJson(), 'updated_at': now},
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // Savings goals operations
  Future<void> insertSavingsGoal(budget_models.SavingsGoal goal) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('savings_goals', {
      ...goal.toJson(),
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<List<budget_models.SavingsGoal>> getSavingsGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      orderBy: 'created_at DESC',
    );

    return List.generate(
      maps.length,
      (i) => budget_models.SavingsGoal.fromJson(maps[i]),
    );
  }

  Future<budget_models.SavingsGoal?> getSavingsGoal(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return budget_models.SavingsGoal.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateSavingsGoal(budget_models.SavingsGoal goal) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'savings_goals',
      {...goal.toJson(), 'updated_at': now},
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteSavingsGoal(String id) async {
    final db = await database;
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  // Recurring transactions operations
  Future<void> insertRecurringTransaction(
    budget_models.RecurringTransaction transaction,
  ) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('recurring_transactions', {
      ...transaction.toJson(),
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<List<budget_models.RecurringTransaction>>
  getRecurringTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      orderBy: 'created_at DESC',
    );

    return List.generate(
      maps.length,
      (i) => budget_models.RecurringTransaction.fromJson(maps[i]),
    );
  }

  Future<budget_models.RecurringTransaction?> getRecurringTransaction(
    String id,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return budget_models.RecurringTransaction.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateRecurringTransaction(
    budget_models.RecurringTransaction transaction,
  ) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'recurring_transactions',
      {...transaction.toJson(), 'updated_at': now},
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteRecurringTransaction(String id) async {
    final db = await database;
    await db.delete('recurring_transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Budget insights operations
  Future<void> insertBudgetInsight(budget_models.BudgetInsight insight) async {
    final db = await database;
    await db.insert('budget_insights', insight.toJson());
  }

  Future<List<budget_models.BudgetInsight>> getBudgetInsights() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budget_insights',
      orderBy: 'created_at DESC',
    );

    return List.generate(
      maps.length,
      (i) => budget_models.BudgetInsight.fromJson(maps[i]),
    );
  }

  Future<void> deleteBudgetInsight(String id) async {
    final db = await database;
    await db.delete('budget_insights', where: 'id = ?', whereArgs: [id]);
  }

  // Analytics queries
  Future<Map<String, double>> getCategorySpending(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT c.id, c.name, COALESCE(SUM(t.amount), 0) as total
      FROM categories c
      LEFT JOIN transactions t ON c.id = t.category_id 
        AND t.type = 'expense' 
        AND t.date >= ? 
        AND t.date <= ?
      WHERE c.type = 'expense' AND c.is_active = 1
      GROUP BY c.id, c.name
      ORDER BY total DESC
    ''',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );

    final Map<String, double> spending = {};
    for (final row in result) {
      spending[row['name']] = (row['total'] as num).toDouble();
    }

    return spending;
  }

  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM transactions
      WHERE type = 'income' AND date >= ? AND date <= ?
    ''',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );

    return (result.first['total'] as num).toDouble();
  }

  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM transactions
      WHERE type = 'expense' AND date >= ? AND date <= ?
    ''',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );

    return (result.first['total'] as num).toDouble();
  }

  Future<double> getTotalSavings(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM transactions
      WHERE type = 'savings' AND date >= ? AND date <= ?
    ''',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );

    return (result.first['total'] as num).toDouble();
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
