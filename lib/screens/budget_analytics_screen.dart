import 'package:clarity/models/budget_models.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';

class BudgetAnalyticsScreen extends StatefulWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  State<BudgetAnalyticsScreen> createState() => _BudgetAnalyticsScreenState();
}

class _BudgetAnalyticsScreenState extends State<BudgetAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Month';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          return CustomScrollView(
            slivers: [
              // App Bar
              _buildSliverAppBar(context),

              // Period and Category Filters
              _buildFilterSection(context),

              // Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    tabs: const [
                      Tab(icon: Icon(Icons.bar_chart), text: 'Spending'),
                      Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
                      Tab(icon: Icon(Icons.compare_arrows), text: 'Compare'),
                    ],
                  ),
                ),
              ),

              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSpendingTab(context, budgetProvider),
                    _buildTrendsTab(context, budgetProvider),
                    _buildCompareTab(context, budgetProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Analytics',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Deep insights into your spending patterns',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                context,
                'Period',
                _selectedPeriod,
                ['Week', 'Month', 'Quarter', 'Year'],
                (value) => setState(() => _selectedPeriod = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFilterDropdown(
                context,
                'Category',
                _selectedCategory,
                [
                  'All',
                  'Food',
                  'Transport',
                  'Entertainment',
                  'Shopping',
                  'Bills',
                ],
                (value) => setState(() => _selectedCategory = value!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSpendingTab(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Spending Overview Card
          _buildSpendingOverviewCard(context, budgetProvider),

          const SizedBox(height: 16),

          // Category Breakdown
          _buildCategoryBreakdownCard(context, budgetProvider),

          const SizedBox(height: 16),

          // Monthly Spending Chart
          _buildMonthlySpendingChart(context, budgetProvider),

          const SizedBox(height: 16),

          // Top Expenses
          _buildTopExpensesCard(context, budgetProvider),
        ],
      ),
    );
  }

  Widget _buildSpendingOverviewCard(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final summary = budgetProvider.summary;
    if (summary == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Overview',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  context,
                  'Total Spent',
                  '\$${summary.totalExpenses.toStringAsFixed(2)}',
                  Icons.shopping_cart,
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  context,
                  'Avg Daily',
                  '\$${(summary.totalExpenses / 30).toStringAsFixed(2)}',
                  Icons.today,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  context,
                  'Categories',
                  '${summary.categoryCount}',
                  Icons.category,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  context,
                  'Transactions',
                  '${budgetProvider.transactions.length}',
                  Icons.receipt,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Pie Chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildCategoryPieChartSections(
                  context,
                  budgetProvider,
                ),
                centerSpaceRadius: 60,
                sectionsSpace: 2,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Category List
          _buildCategoryList(context, budgetProvider),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildCategoryPieChartSections(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final summary = budgetProvider.summary;
    if (summary == null || summary.categorySpending.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1.0,
          title: 'No Data',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    final categorySpending = summary.categorySpending;
    final total = categorySpending.fold(0.0, (sum, cat) => sum + cat.amount);
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return categorySpending.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final percentage = category.amount / total;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: category.amount,
        title: '${(percentage * 100).toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCategoryList(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final summary = budgetProvider.summary;
    if (summary == null || summary.categorySpending.isEmpty) {
      return const Center(child: Text('No category data available'));
    }

    final categorySpending = summary.categorySpending;
    final total = categorySpending.fold(0.0, (sum, cat) => sum + cat.amount);
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Column(
      children: categorySpending.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final percentage = (category.amount / total) * 100;
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.categoryName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${category.amount.toStringAsFixed(0)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlySpendingChart(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final trends = budgetProvider.getMonthlySpendingTrends();

    return trends.isEmpty
        ? const Center(child: Text('No spending data available for trends'))
        : LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < trends.length) {
                        return Text(
                          trends[value.toInt()]['monthName'],
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: trends.asMap().entries.map((entry) {
                    final index = entry.key;
                    final trend = entry.value;
                    return FlSpot(index.toDouble(), trend['spending']);
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildTopExpensesCard(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final topExpenses =
        budgetProvider.transactions
            .where((t) => t.type == TransactionType.expense)
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Expenses',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          if (topExpenses.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No expenses yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topExpenses.take(5).length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final expense = topExpenses[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          expense.title,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(BuildContext context, BudgetProvider budgetProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Spending Trend
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Monthly Spending Trend',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildMonthlySpendingChart(context, budgetProvider),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Category Trends
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Category Trends',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryTrendsList(context, budgetProvider),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Spending Insights
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insights,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Spending Insights',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSpendingInsights(context, budgetProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareTab(BuildContext context, BudgetProvider budgetProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Comparison
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Month Comparison',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMonthComparison(context, budgetProvider),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category Comparison
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Comparison',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryComparison(context, budgetProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTrendsList(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final summary = budgetProvider.summary;
    if (summary == null || summary.categorySpending.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No category data available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add transactions with categories to see trends',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Column(
      children: summary.categorySpending.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final color = colors[index % colors.length];
        final totalSpending = summary.categorySpending.fold(
          0.0,
          (sum, cat) => sum + cat.amount,
        );
        final percentage = (category.amount / totalSpending) * 100;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.categoryName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}% of total spending',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${category.amount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpendingInsights(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final trends = budgetProvider.getMonthlySpendingTrends();
    if (trends.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.insights_outlined,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No spending insights available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add more transactions to get insights',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Calculate insights
    final currentMonth = trends.last['spending'] as double;
    final previousMonth = trends.length > 1
        ? trends[trends.length - 2]['spending'] as double
        : 0.0;
    final averageSpending =
        trends.fold(0.0, (sum, trend) => sum + (trend['spending'] as double)) /
        trends.length;
    final highestSpending = trends.fold(
      0.0,
      (max, trend) => (trend['spending'] as double) > max
          ? (trend['spending'] as double)
          : max,
    );
    final lowestSpending = trends.fold(
      double.infinity,
      (min, trend) => (trend['spending'] as double < min)
          ? trend['spending'] as double
          : min,
    );

    final spendingChange = previousMonth > 0
        ? ((currentMonth - previousMonth) / previousMonth) * 100
        : 0.0;
    final isIncreasing = spendingChange > 0;
    final isDecreasing = spendingChange < 0;

    return Column(
      children: [
        // Spending Change Insight
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isIncreasing
                ? Colors.red.withOpacity(0.1)
                : isDecreasing
                ? Colors.green.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isIncreasing
                  ? Colors.red.withOpacity(0.3)
                  : isDecreasing
                  ? Colors.green.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isIncreasing
                    ? Icons.trending_up
                    : isDecreasing
                    ? Icons.trending_down
                    : Icons.trending_flat,
                color: isIncreasing
                    ? Colors.red
                    : isDecreasing
                    ? Colors.green
                    : Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIncreasing
                          ? 'Spending Increased'
                          : isDecreasing
                          ? 'Spending Decreased'
                          : 'Spending Stable',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${spendingChange.abs().toStringAsFixed(1)}% ${isIncreasing
                          ? 'increase'
                          : isDecreasing
                          ? 'decrease'
                          : 'change'} from last month',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Average Spending
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Monthly Spending',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${averageSpending.toStringAsFixed(0)} over ${trends.length} months',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Spending Range
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.show_chart, color: Colors.purple, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending Range',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Highest: \$${highestSpending.toStringAsFixed(0)} | Lowest: \$${lowestSpending.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthComparison(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final spendingData = budgetProvider.getMonthlySpendingData();

    return Column(
      children: [
        _buildComparisonItem(
          context,
          'This Month',
          spendingData['currentMonth'] ?? 0.0,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildComparisonItem(
          context,
          'Last Month',
          spendingData['lastMonth'] ?? 0.0,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildComparisonItem(
          context,
          'Average',
          spendingData['average'] ?? 0.0,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildComparisonItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryComparison(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final summary = budgetProvider.summary;
    if (summary == null || summary.categorySpending.isEmpty) {
      return const Center(
        child: Text('No category data available for comparison'),
      );
    }

    return Column(
      children: summary.categorySpending.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category.categoryName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '\$${category.amount.toStringAsFixed(0)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
