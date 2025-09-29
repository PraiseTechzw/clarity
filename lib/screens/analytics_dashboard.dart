import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/project_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/auth_provider.dart';
import '../services/network_service.dart';
import 'suggestions_screen.dart';

enum TimePeriod { last7Days, last30Days, last90Days, lastYear, allTime }

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard>
    with TickerProviderStateMixin {
  TimePeriod _selectedPeriod = TimePeriod.last30Days;
  bool _showComparison = false;
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
    _animationController.forward();
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
      appBar: _buildEnhancedAppBar(context),
      body:
          Consumer4<
            ProjectProvider,
            SyncProvider,
            AuthProvider,
            NetworkService
          >(
            builder:
                (
                  context,
                  projectProvider,
                  syncProvider,
                  authProvider,
                  networkService,
                  child,
                ) {
                  if (projectProvider.isLoading) {
                    return _buildLoadingState(context);
                  }

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await projectProvider.loadProjects();
                        _animationController.reset();
                        _animationController.forward();
                      },
                      child: CustomScrollView(
                        slivers: [
                          // Header with period selector
                          SliverToBoxAdapter(
                            child: _buildHeaderSection(
                              context,
                              projectProvider,
                            ),
                          ),

                          // Key Metrics Cards
                          SliverToBoxAdapter(
                            child: _buildKeyMetricsSection(
                              context,
                              projectProvider,
                            ),
                          ),

                          // Performance Indicators
                          SliverToBoxAdapter(
                            child: _buildPerformanceIndicators(
                              context,
                              projectProvider,
                            ),
                          ),

                          // Charts Section
                          SliverToBoxAdapter(
                            child: _buildChartsSection(
                              context,
                              projectProvider,
                            ),
                          ),

                          // Client Analysis
                          SliverToBoxAdapter(
                            child: _buildClientAnalysisSection(
                              context,
                              projectProvider,
                            ),
                          ),

                          // Project Timeline
                          SliverToBoxAdapter(
                            child: _buildProjectTimelineSection(
                              context,
                              projectProvider,
                            ),
                          ),

                          // Export and Actions
                          SliverToBoxAdapter(
                            child: _buildActionsSection(
                              context,
                              projectProvider,
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        ],
                      ),
                    ),
                  );
                },
          ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.analytics,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Analytics Dashboard',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.lightbulb_outline,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => _navigateToSuggestions(context),
        ),
        IconButton(
          icon: Icon(
            Icons.share,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => _exportAnalytics(context),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Export Data'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Analytics Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading analytics...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, ProjectProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Analytics',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comprehensive insights into your project performance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Time Period Selector
          Row(
            children: [
              Text(
                'Time Period: ',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: TimePeriod.values.map((period) {
                      final isSelected = _selectedPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getPeriodLabel(period)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPeriod = period;
                            });
                          },
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          checkmarkColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Comparison Toggle
          Row(
            children: [
              Switch(
                value: _showComparison,
                onChanged: (value) {
                  setState(() {
                    _showComparison = value;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Show period comparison',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsSection(
    BuildContext context,
    ProjectProvider provider,
  ) {
    final metrics = _calculateKeyMetrics(provider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Metrics',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildMetricCard(
                context,
                'Total Revenue',
                '\$${metrics['totalRevenue'].toStringAsFixed(0)}',
                Icons.account_balance_wallet,
                Theme.of(context).colorScheme.primary,
                metrics['revenueGrowth'],
              ),
              _buildMetricCard(
                context,
                'Active Projects',
                '${metrics['activeProjects']}',
                Icons.folder_open,
                Theme.of(context).colorScheme.secondary,
                metrics['projectGrowth'],
              ),
              _buildMetricCard(
                context,
                'Completion Rate',
                '${metrics['completionRate'].toStringAsFixed(1)}%',
                Icons.check_circle,
                Theme.of(context).colorScheme.tertiary,
                metrics['completionGrowth'],
              ),
              _buildMetricCard(
                context,
                'Avg. Project Value',
                '\$${metrics['avgProjectValue'].toStringAsFixed(0)}',
                Icons.trending_up,
                Theme.of(context).colorScheme.error,
                metrics['valueGrowth'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicators(
    BuildContext context,
    ProjectProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Indicators',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildIndicatorCard(
                  context,
                  'On-Time Delivery',
                  '${_calculateOnTimeDelivery(provider).toStringAsFixed(1)}%',
                  Icons.schedule,
                  _calculateOnTimeDelivery(provider) >= 80
                      ? Colors.green
                      : _calculateOnTimeDelivery(provider) >= 60
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildIndicatorCard(
                  context,
                  'Client Satisfaction',
                  '${_calculateClientSatisfaction(provider).toStringAsFixed(1)}%',
                  Icons.star,
                  _calculateClientSatisfaction(provider) >= 4.0
                      ? Colors.green
                      : _calculateClientSatisfaction(provider) >= 3.0
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildIndicatorCard(
                  context,
                  'Budget Adherence',
                  '${_calculateBudgetAdherence(provider).toStringAsFixed(1)}%',
                  Icons.account_balance,
                  _calculateBudgetAdherence(provider) >= 90
                      ? Colors.green
                      : _calculateBudgetAdherence(provider) >= 75
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildIndicatorCard(
                  context,
                  'Resource Utilization',
                  '${_calculateResourceUtilization(provider).toStringAsFixed(1)}%',
                  Icons.people,
                  _calculateResourceUtilization(provider) >= 80
                      ? Colors.green
                      : _calculateResourceUtilization(provider) >= 60
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, ProjectProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charts & Insights',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Revenue Trend Chart
          _buildChartCard(
            context,
            'Revenue Trend',
            _buildRevenueTrendChart(context, provider),
            Icons.trending_up,
          ),

          const SizedBox(height: 16),

          // Project Status Distribution
          _buildChartCard(
            context,
            'Project Status Distribution',
            _buildProjectStatusChart(context, provider),
            Icons.pie_chart,
          ),

          const SizedBox(height: 16),

          // Monthly Performance
          _buildChartCard(
            context,
            'Monthly Performance',
            _buildMonthlyPerformanceChart(context, provider),
            Icons.bar_chart,
          ),

          const SizedBox(height: 16),

          // Task Completion Timeline
          _buildChartCard(
            context,
            'Task Completion Timeline',
            _buildTaskCompletionTimeline(context, provider),
            Icons.timeline,
          ),
        ],
      ),
    );
  }

  Widget _buildClientAnalysisSection(
    BuildContext context,
    ProjectProvider provider,
  ) {
    final clientData = _analyzeClientData(provider);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Client Analysis',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Top Clients
          _buildTopClientsCard(context, clientData),

          const SizedBox(height: 16),

          // Client Revenue Chart
          _buildChartCard(
            context,
            'Client Revenue Distribution',
            _buildClientRevenueChart(context, provider),
            Icons.people,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTimelineSection(
    BuildContext context,
    ProjectProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Timeline',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTimelineCard(context, provider),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, ProjectProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportAnalytics(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Export Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareAnalytics(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    double? growth,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                if (growth != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: growth >= 0
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: growth >= 0
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          growth >= 0 ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: growth >= 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${growth.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: growth >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 24,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    String title,
    Widget chart,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildTopClientsCard(
    BuildContext context,
    List<Map<String, dynamic>> topClients,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Top Clients',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...topClients
                .take(5)
                .map(
                  (client) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          child: Text(
                            client['name'][0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client['name'],
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${client['projects']} projects',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${client['revenue'].toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, ProjectProvider provider) {
    final timelineData = _getProjectTimeline(provider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Recent Project Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...timelineData
                .take(5)
                .map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getEventColor(event['type']),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'],
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                event['description'],
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDateTime(event['date']),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  // Chart implementations
  Widget _buildRevenueTrendChart(
    BuildContext context,
    ProjectProvider provider,
  ) {
    final data = _getRevenueTrendData(provider);

    if (data.isEmpty) {
      return _buildEmptyChart(context, 'No revenue data available');
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatDate(data[value.toInt()]['date']),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  (entry.value['revenue'] as num).toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectStatusChart(
    BuildContext context,
    ProjectProvider provider,
  ) {
    final statusData = _getProjectStatusData(provider);

    if (statusData.isEmpty) {
      return _buildEmptyChart(context, 'No project data available');
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: statusData.map((data) {
            return PieChartSectionData(
              color: data['color'],
              value: (data['value'] as num).toDouble(),
              title: '${data['label']}\n${data['value']}',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildMonthlyPerformanceChart(
    BuildContext context,
    ProjectProvider provider,
  ) {
    final monthlyData = _getMonthlyPerformanceData(provider);

    if (monthlyData.isEmpty) {
      return _buildEmptyChart(context, 'No monthly data available');
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              monthlyData
                  .map((e) => (e['value'] as num).toDouble())
                  .reduce((a, b) => a > b ? a : b) +
              1000,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    monthlyData[value.toInt()]['month'],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: monthlyData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: (entry.value['value'] as num).toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTaskCompletionTimeline(
    BuildContext context,
    ProjectProvider provider,
  ) {
    final timelineData = _getTaskCompletionTimeline(provider);

    if (timelineData.isEmpty) {
      return _buildEmptyChart(context, 'No task data available');
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    timelineData[value.toInt()]['date'],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: timelineData.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  (entry.value['completion'] as num).toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientRevenueChart(
    BuildContext context,
    ProjectProvider provider,
  ) {
    final clientData = _getClientRevenueData(provider);

    if (clientData.isEmpty) {
      return _buildEmptyChart(context, 'No client data available');
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              clientData
                  .map((e) => (e['revenue'] as num).toDouble())
                  .reduce((a, b) => a > b ? a : b) +
              1000,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    clientData[value.toInt()]['name'],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: clientData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: (entry.value['revenue'] as num).toDouble(),
                  color: Colors.blue,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context, String message) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.last7Days:
        return '7 Days';
      case TimePeriod.last30Days:
        return '30 Days';
      case TimePeriod.last90Days:
        return '90 Days';
      case TimePeriod.lastYear:
        return '1 Year';
      case TimePeriod.allTime:
        return 'All Time';
    }
  }

  Map<String, dynamic> _calculateKeyMetrics(ProjectProvider provider) {
    final projects = provider.projects;

    double totalRevenue = 0;
    int activeProjects = 0;
    double totalCompletion = 0;
    double totalValue = 0;

    for (final project in projects) {
      totalRevenue += project.totalPaid;
      totalValue += project.budget;

      if (project.progressPercentage > 0 && project.progressPercentage < 100) {
        activeProjects++;
      }

      totalCompletion += project.progressPercentage;
    }

    final avgProjectValue = projects.isNotEmpty
        ? totalValue / projects.length
        : 0;
    final completionRate = projects.isNotEmpty
        ? totalCompletion / projects.length
        : 0;

    return {
      'totalRevenue': totalRevenue,
      'activeProjects': activeProjects,
      'completionRate': completionRate,
      'avgProjectValue': avgProjectValue,
      'revenueGrowth': 12.5, // Mock data - would calculate from historical data
      'projectGrowth': 8.3,
      'completionGrowth': 5.2,
      'valueGrowth': 15.7,
    };
  }

  double _calculateOnTimeDelivery(ProjectProvider provider) {
    final projects = provider.projects
        .where((p) => p.progressPercentage >= 100)
        .toList();
    if (projects.isEmpty) return 0;

    final onTimeProjects = projects.where((p) {
      return p.deadline.isBefore(DateTime.now()) ||
          p.deadline.isAtSameMomentAs(DateTime.now());
    }).length;

    return (onTimeProjects / projects.length) * 100;
  }

  double _calculateClientSatisfaction(ProjectProvider provider) {
    // Mock calculation - would use actual client feedback data
    return 4.2;
  }

  double _calculateBudgetAdherence(ProjectProvider provider) {
    final projects = provider.projects;
    if (projects.isEmpty) return 0;

    double totalAdherence = 0;
    for (final project in projects) {
      if (project.budget > 0) {
        final adherence = (project.totalPaid / project.budget) * 100;
        totalAdherence += adherence.clamp(0, 100);
      }
    }

    return totalAdherence / projects.length;
  }

  double _calculateResourceUtilization(ProjectProvider provider) {
    // Mock calculation - would use actual resource tracking data
    return 75.5;
  }

  List<Map<String, dynamic>> _analyzeClientData(ProjectProvider provider) {
    final clientMap = <String, Map<String, dynamic>>{};

    for (final project in provider.projects) {
      final clientName = project.clientName;
      if (clientMap.containsKey(clientName)) {
        clientMap[clientName]!['revenue'] += project.totalPaid;
        clientMap[clientName]!['projects'] += 1;
      } else {
        clientMap[clientName] = {
          'name': clientName,
          'revenue': project.totalPaid,
          'projects': 1,
        };
      }
    }

    final clients = clientMap.values.toList();
    clients.sort((a, b) => b['revenue'].compareTo(a['revenue']));

    return clients;
  }

  List<Map<String, dynamic>> _getProjectTimeline(ProjectProvider provider) {
    final events = <Map<String, dynamic>>[];

    for (final project in provider.projects) {
      events.add({
        'title': 'Project Created',
        'description': project.name,
        'date': project.createdAt,
        'type': 'created',
      });

      if (project.progressPercentage >= 100) {
        events.add({
          'title': 'Project Completed',
          'description': project.name,
          'date': project.deadline,
          'type': 'completed',
        });
      }
    }

    events.sort((a, b) => b['date'].compareTo(a['date']));
    return events;
  }

  List<Map<String, dynamic>> _getRevenueTrendData(ProjectProvider provider) {
    final projects = provider.projects;
    if (projects.isEmpty) return [];

    // Group projects by creation date and calculate daily revenue
    final Map<String, double> dailyRevenue = {};

    for (final project in projects) {
      final dateKey = _formatDate(project.createdAt);
      dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + project.totalPaid;
    }

    // Convert to list and sort by date
    final List<Map<String, dynamic>> revenueData = [];
    final sortedDates = dailyRevenue.keys.toList()..sort();

    for (final dateKey in sortedDates) {
      revenueData.add({
        'date': _parseDate(dateKey),
        'revenue': dailyRevenue[dateKey]!,
      });
    }

    // If no data, return empty list
    if (revenueData.isEmpty) return [];

    // Take last 7 days or all available data
    return revenueData.length > 7
        ? revenueData.sublist(revenueData.length - 7)
        : revenueData;
  }

  List<Map<String, dynamic>> _getProjectStatusData(ProjectProvider provider) {
    final completed = provider.projects
        .where((p) => p.progressPercentage >= 100)
        .length;
    final inProgress = provider.projects
        .where((p) => p.progressPercentage > 0 && p.progressPercentage < 100)
        .length;
    final notStarted = provider.projects
        .where((p) => p.progressPercentage == 0)
        .length;
    final overdue = provider.overdueProjects.length;

    return [
      {'label': 'Completed', 'value': completed, 'color': Colors.green},
      {'label': 'In Progress', 'value': inProgress, 'color': Colors.blue},
      {'label': 'Not Started', 'value': notStarted, 'color': Colors.grey},
      {'label': 'Overdue', 'value': overdue, 'color': Colors.red},
    ];
  }

  List<Map<String, dynamic>> _getMonthlyPerformanceData(
    ProjectProvider provider,
  ) {
    final projects = provider.projects;
    if (projects.isEmpty) return [];

    // Group projects by month and calculate monthly revenue
    final Map<String, double> monthlyRevenue = {};

    for (final project in projects) {
      final monthKey =
          '${project.createdAt.year}-${project.createdAt.month.toString().padLeft(2, '0')}';
      monthlyRevenue[monthKey] =
          (monthlyRevenue[monthKey] ?? 0) + project.totalPaid;
    }

    // Convert to list and sort by month
    final List<Map<String, dynamic>> monthlyData = [];
    final sortedMonths = monthlyRevenue.keys.toList()..sort();

    for (final monthKey in sortedMonths) {
      final date = DateTime.parse('$monthKey-01');
      monthlyData.add({
        'month': _getMonthAbbreviation(date.month),
        'value': monthlyRevenue[monthKey]!,
      });
    }

    // Take last 6 months or all available data
    return monthlyData.length > 6
        ? monthlyData.sublist(monthlyData.length - 6)
        : monthlyData;
  }

  List<Map<String, dynamic>> _getTaskCompletionTimeline(
    ProjectProvider provider,
  ) {
    final projects = provider.projects;
    if (projects.isEmpty) return [];

    // Group projects by week and calculate average completion
    final Map<String, List<double>> weeklyCompletion = {};

    for (final project in projects) {
      final weekKey = _getWeekKey(project.createdAt);
      if (!weeklyCompletion.containsKey(weekKey)) {
        weeklyCompletion[weekKey] = [];
      }
      weeklyCompletion[weekKey]!.add(project.progressPercentage);
    }

    // Convert to list and sort by week
    final List<Map<String, dynamic>> timelineData = [];
    final sortedWeeks = weeklyCompletion.keys.toList()..sort();

    for (final weekKey in sortedWeeks) {
      final completions = weeklyCompletion[weekKey]!;
      final avgCompletion =
          completions.reduce((a, b) => a + b) / completions.length;

      timelineData.add({'date': weekKey, 'completion': avgCompletion});
    }

    // Take last 6 weeks or all available data
    return timelineData.length > 6
        ? timelineData.sublist(timelineData.length - 6)
        : timelineData;
  }

  List<Map<String, dynamic>> _getClientRevenueData(ProjectProvider provider) {
    final clientData = _analyzeClientData(provider);
    return clientData.take(5).toList();
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'created':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  DateTime _parseDate(String dateString) {
    final parts = dateString.split('/');
    final month = int.parse(parts[0]);
    final day = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, month, day);
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getWeekKey(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return 'Week ${startOfWeek.day}/${startOfWeek.month}';
  }

  void _navigateToSuggestions(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SuggestionsScreen()));
  }

  void _exportAnalytics(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting analytics data...')),
    );
  }

  void _shareAnalytics(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sharing analytics...')));
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'export':
        _exportAnalytics(context);
        break;
      case 'settings':
        // Navigate to analytics settings
        break;
    }
  }
}
