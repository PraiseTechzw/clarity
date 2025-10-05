import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/budget_models.dart';
import '../widgets/enhanced_budget_widgets.dart';

class BudgetInsightsScreen extends StatefulWidget {
  const BudgetInsightsScreen({super.key});

  @override
  State<BudgetInsightsScreen> createState() => _BudgetInsightsScreenState();
}

class _BudgetInsightsScreenState extends State<BudgetInsightsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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

              // AI Insights Header
              _buildAIInsightsHeader(context),

              // Smart Insights
              _buildSmartInsightsSection(context, budgetProvider),

              // Budget Forecast
              _buildBudgetForecastSection(context, budgetProvider),

              // Spending Patterns
              _buildSpendingPatternsSection(context, budgetProvider),

              // Recommendations
              _buildRecommendationsSection(context, budgetProvider),

              // Goals Progress
              _buildGoalsProgressSection(context, budgetProvider),
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
                Colors.purple.withOpacity(0.1),
                Colors.blue.withOpacity(0.1),
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
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.purple, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'AI Insights',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Intelligent analysis of your spending habits',
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

  Widget _buildAIInsightsHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.withOpacity(0.1),
                Colors.blue.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purple.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI-Powered Analysis',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Our AI analyzes your spending patterns to provide personalized insights and recommendations.',
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
      ),
    );
  }

  Widget _buildSmartInsightsSection(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Insights',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Mock insights - replace with actual AI-generated insights
              SmartInsightCard(
                insight: BudgetInsight(
                  id: '1',
                  type: InsightType.warning,
                  title: 'High Food Spending',
                  description:
                      'You\'re spending 35% more on food this month compared to last month. Consider meal planning to reduce costs.',
                  actionText: 'View Food Budget',
                  createdAt: DateTime.now(),
                ),
              ),

              SmartInsightCard(
                insight: BudgetInsight(
                  id: '2',
                  type: InsightType.success,
                  title: 'Great Savings Progress',
                  description:
                      'You\'ve saved 15% more this month! Keep up the excellent work.',
                  actionText: 'View Savings Goals',
                  createdAt: DateTime.now(),
                ),
              ),

              SmartInsightCard(
                insight: BudgetInsight(
                  id: '3',
                  type: InsightType.tip,
                  title: 'Subscription Optimization',
                  description:
                      'You have 3 unused subscriptions costing \$45/month. Consider canceling them.',
                  actionText: 'Manage Subscriptions',
                  createdAt: DateTime.now(),
                ),
              ),

              SmartInsightCard(
                insight: BudgetInsight(
                  id: '4',
                  type: InsightType.info,
                  title: 'Spending Pattern Detected',
                  description:
                      'You tend to spend more on weekends. Set a weekend budget to control expenses.',
                  actionText: 'Set Weekend Budget',
                  createdAt: DateTime.now(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetForecastSection(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BudgetForecastCard(
            transactions: budgetProvider.transactions,
            monthlyIncome: budgetProvider.summary?.totalIncome ?? 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingPatternsSection(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
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
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Spending Patterns',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildPatternItem(
                  context,
                  'Peak Spending Day',
                  'Friday',
                  'You spend 40% more on Fridays',
                  Icons.calendar_today,
                  Colors.orange,
                ),

                const SizedBox(height: 16),

                _buildPatternItem(
                  context,
                  'Most Expensive Category',
                  'Entertainment',
                  'Averaging \$200/month',
                  Icons.movie,
                  Colors.purple,
                ),

                const SizedBox(height: 16),

                _buildPatternItem(
                  context,
                  'Best Saving Day',
                  'Tuesday',
                  'You save 25% more on Tuesdays',
                  Icons.savings,
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatternItem(
    BuildContext context,
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withOpacity(0.1),
                  Colors.teal.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'AI Recommendations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildRecommendationItem(
                  context,
                  'Set up automatic savings',
                  'Transfer 10% of your income to savings automatically',
                  Icons.savings,
                  Colors.green,
                ),

                const SizedBox(height: 12),

                _buildRecommendationItem(
                  context,
                  'Create a grocery budget',
                  'Limit grocery spending to \$300/month to save \$50',
                  Icons.shopping_cart,
                  Colors.blue,
                ),

                const SizedBox(height: 12),

                _buildRecommendationItem(
                  context,
                  'Review subscriptions',
                  'Cancel unused subscriptions to save \$45/month',
                  Icons.subscriptions,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Handle recommendation action
            },
            icon: Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsProgressSection(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
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
                Row(
                  children: [
                    Icon(Icons.flag, color: Colors.purple, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Goals Progress',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildGoalProgressItem(
                  context,
                  'Emergency Fund',
                  0.75,
                  '\$3,750 / \$5,000',
                  'Save \$1,250 more',
                  Colors.green,
                ),

                const SizedBox(height: 16),

                _buildGoalProgressItem(
                  context,
                  'Vacation Fund',
                  0.40,
                  '\$800 / \$2,000',
                  'Save \$1,200 more',
                  Colors.blue,
                ),

                const SizedBox(height: 16),

                _buildGoalProgressItem(
                  context,
                  'New Laptop',
                  0.20,
                  '\$400 / \$2,000',
                  'Save \$1,600 more',
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalProgressItem(
    BuildContext context,
    String title,
    double progress,
    String amount,
    String remaining,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              amount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          remaining,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
