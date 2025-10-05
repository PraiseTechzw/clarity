import 'package:clarity/screens/github_integration_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/project_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/github_provider.dart';
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

                          // Intelligent Insights Section
                          SliverToBoxAdapter(
                            child: Consumer<NotesProvider>(
                              builder: (context, notesProvider, child) {
                                final insights = _generateIntelligentInsights(
                                  projectProvider,
                                  notesProvider,
                                );

                                if (insights.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  margin: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.psychology,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Intelligent Insights',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ...insights.map(
                                        (insight) =>
                                            _buildInsightCard(context, insight),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // GitHub Analytics Section
                          SliverToBoxAdapter(
                            child: Consumer<GitHubProvider>(
                              builder: (context, githubProvider, child) {
                                if (!githubProvider.isAuthenticated) {
                                  return _buildGitHubConnectPrompt(context);
                                }

                                return _buildGitHubAnalyticsSection(
                                  context,
                                  githubProvider,
                                );
                              },
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

  Widget _buildInsightCard(BuildContext context, Map<String, dynamic> insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight['type'] == 'warning'
            ? Colors.orange.withOpacity(0.1)
            : insight['type'] == 'success'
            ? Colors.green.withOpacity(0.1)
            : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight['type'] == 'warning'
              ? Colors.orange.withOpacity(0.3)
              : insight['type'] == 'success'
              ? Colors.green.withOpacity(0.3)
              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            insight['icon'],
            color: insight['type'] == 'warning'
                ? Colors.orange
                : insight['type'] == 'success'
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'],
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: insight['type'] == 'warning'
                        ? Colors.orange.shade700
                        : insight['type'] == 'success'
                        ? Colors.green.shade700
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight['description'],
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

  List<Map<String, dynamic>> _generateIntelligentInsights(
    ProjectProvider projectProvider,
    NotesProvider notesProvider,
  ) {
    final insights = <Map<String, dynamic>>[];
    final projects = projectProvider.projects;
    final notes = notesProvider.notes;

    if (projects.isEmpty) {
      return insights;
    }

    // Analyze project performance
    final completedProjects = projects
        .where((p) => p.progressPercentage >= 100)
        .length;
    final totalProjects = projects.length;
    final completionRate = (completedProjects / totalProjects) * 100;

    if (completionRate < 50) {
      insights.add({
        'type': 'warning',
        'icon': Icons.trending_down,
        'title': 'Low Project Completion Rate',
        'description':
            'Only ${completionRate.toStringAsFixed(1)}% of projects are completed. Consider reviewing project timelines and resources.',
      });
    } else if (completionRate >= 80) {
      insights.add({
        'type': 'success',
        'icon': Icons.trending_up,
        'title': 'Excellent Project Completion',
        'description':
            '${completionRate.toStringAsFixed(1)}% completion rate shows strong project management.',
      });
    }

    // Analyze overdue projects
    final now = DateTime.now();
    final overdueProjects = projects
        .where((p) => p.deadline.isBefore(now) && p.progressPercentage < 100)
        .length;

    if (overdueProjects > 0) {
      insights.add({
        'type': 'warning',
        'icon': Icons.warning,
        'title': 'Overdue Projects Detected',
        'description':
            '$overdueProjects project(s) are past their deadline. Immediate attention required.',
      });
    }

    // Analyze revenue patterns
    final totalRevenue = projects.fold(0.0, (sum, p) => sum + p.totalPaid);
    final totalBudget = projects.fold(0.0, (sum, p) => sum + p.budget);
    final revenueRatio = totalBudget > 0
        ? (totalRevenue / totalBudget) * 100
        : 0;

    if (revenueRatio < 50) {
      insights.add({
        'type': 'warning',
        'icon': Icons.attach_money,
        'title': 'Low Revenue Collection',
        'description':
            'Only ${revenueRatio.toStringAsFixed(1)}% of budgeted revenue collected. Review payment schedules.',
      });
    } else if (revenueRatio >= 90) {
      insights.add({
        'type': 'success',
        'icon': Icons.monetization_on,
        'title': 'Strong Revenue Collection',
        'description':
            '${revenueRatio.toStringAsFixed(1)}% revenue collection shows excellent financial management.',
      });
    }

    // Analyze notes productivity
    if (notes.isNotEmpty) {
      final recentNotes = notes
          .where((n) => now.difference(n.createdAt).inDays <= 7)
          .length;

      if (recentNotes == 0) {
        insights.add({
          'type': 'info',
          'icon': Icons.note_add,
          'title': 'Low Note Activity',
          'description':
              'No notes created in the last 7 days. Consider documenting project progress and ideas.',
        });
      } else if (recentNotes >= 5) {
        insights.add({
          'type': 'success',
          'icon': Icons.notes,
          'title': 'Active Documentation',
          'description':
              '$recentNotes notes created this week. Great job staying organized!',
        });
      }
    }

    // Analyze project priority distribution
    final highPriorityProjects = projects
        .where((p) => p.priority == 'High')
        .length;
    if (highPriorityProjects > totalProjects * 0.6) {
      insights.add({
        'type': 'warning',
        'icon': Icons.priority_high,
        'title': 'Too Many High Priority Projects',
        'description':
            '${(highPriorityProjects / totalProjects * 100).toStringAsFixed(1)}% of projects are high priority. Consider rebalancing workload.',
      });
    }

    // Analyze client distribution
    final clients = projectProvider.clients;
    if (clients.length > 1) {
      final clientProjectCounts = <String, int>{};
      for (final project in projects) {
        final clientName = project.clientName;
        clientProjectCounts[clientName] =
            (clientProjectCounts[clientName] ?? 0) + 1;
      }

      final maxProjects = clientProjectCounts.values.reduce(
        (a, b) => a > b ? a : b,
      );
      if (maxProjects > totalProjects * 0.5) {
        insights.add({
          'type': 'info',
          'icon': Icons.business,
          'title': 'Client Concentration Risk',
          'description':
              'One client represents ${(maxProjects / totalProjects * 100).toStringAsFixed(1)}% of projects. Consider diversifying client base.',
        });
      }
    }

    return insights;
  }

  Widget _buildGitHubConnectPrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/github.png',
            width: 48,
            height: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Connect GitHub for Development Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Track your development progress, commits, and repository activity to get comprehensive project insights.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GitHubIntegrationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.link),
            label: const Text('Connect GitHub'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubAnalyticsSection(
    BuildContext context,
    GitHubProvider githubProvider,
  ) {
    final repositories = githubProvider.repositories;

    if (repositories.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Repositories Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect to GitHub and load your repositories to see comprehensive development analytics.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                githubProvider.loadRepositories();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Load Repositories'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with GitHub icon and title
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/github.png',
                    width: 28,
                    height: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GitHub Development Analytics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comprehensive insights into your development activity',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    githubProvider.loadRepositories();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Data',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Intelligent GitHub Insights
          _buildGitHubIntelligentInsights(context, githubProvider),
          const SizedBox(height: 20),

          // Repository Stats Grid
          _buildGitHubStatsGrid(context, repositories),
          const SizedBox(height: 20),

          // Development Activity Charts
          _buildGitHubActivityCharts(context, githubProvider),
          const SizedBox(height: 20),

          // Repository List with Advanced Features
          _buildGitHubRepositoryList(context, repositories),
        ],
      ),
    );
  }

  Widget _buildGitHubIntelligentInsights(
    BuildContext context,
    GitHubProvider githubProvider,
  ) {
    final intelligentInsights = githubProvider.getIntelligentInsights();
    final repositories = githubProvider.repositories;

    if (repositories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.1),
            Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Intelligent GitHub Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Overall Score Card
          _buildOverallScoreCard(context, intelligentInsights),
          const SizedBox(height: 16),

          // Insights
          if ((intelligentInsights['insights'] as List).isNotEmpty) ...[
            Text(
              'Development Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...(intelligentInsights['insights'] as List).map(
              (insight) => _buildGitHubInsightCard(context, {
                'type': 'info',
                'icon': Icons.lightbulb_outline,
                'title': 'Insight',
                'description': insight,
              }),
            ),
            const SizedBox(height: 16),
          ],

          // Recommendations
          if ((intelligentInsights['recommendations'] as List).isNotEmpty) ...[
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            ...(intelligentInsights['recommendations'] as List).map(
              (recommendation) => _buildGitHubInsightCard(context, {
                'type': 'success',
                'icon': Icons.trending_up,
                'title': 'Recommendation',
                'description': recommendation,
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard(
    BuildContext context,
    Map<String, dynamic> intelligentInsights,
  ) {
    final overallScore = intelligentInsights['overallScore'] as int;
    final metrics = intelligentInsights['metrics'] as Map<String, dynamic>;

    Color scoreColor;
    String scoreLabel;
    if (overallScore >= 80) {
      scoreColor = Colors.green;
      scoreLabel = 'Excellent';
    } else if (overallScore >= 60) {
      scoreColor = Colors.orange;
      scoreLabel = 'Good';
    } else if (overallScore >= 40) {
      scoreColor = Colors.amber;
      scoreLabel = 'Fair';
    } else {
      scoreColor = Colors.red;
      scoreLabel = 'Needs Improvement';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scoreColor.withValues(alpha: 0.1),
            scoreColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Development Score',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  scoreLabel,
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$overallScore',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                            fontSize: 48,
                          ),
                    ),
                    Text(
                      'out of 100',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricRow(
                      context,
                      'Repositories',
                      '${metrics['totalRepositories']}',
                    ),
                    _buildMetricRow(
                      context,
                      'Active Repos',
                      '${metrics['activeRepositories']}',
                    ),
                    _buildMetricRow(
                      context,
                      'Languages',
                      '${metrics['languagesUsed']}',
                    ),
                    _buildMetricRow(
                      context,
                      'Total Stars',
                      '${metrics['totalStars']}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubInsightCard(
    BuildContext context,
    Map<String, dynamic> insight,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight['type'] == 'warning'
            ? Colors.orange.withValues(alpha: 0.1)
            : insight['type'] == 'success'
            ? Colors.green.withValues(alpha: 0.1)
            : insight['type'] == 'info'
            ? Colors.blue.withValues(alpha: 0.1)
            : Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight['type'] == 'warning'
              ? Colors.orange.withValues(alpha: 0.3)
              : insight['type'] == 'success'
              ? Colors.green.withValues(alpha: 0.3)
              : insight['type'] == 'info'
              ? Colors.blue.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            insight['icon'],
            color: insight['type'] == 'warning'
                ? Colors.orange
                : insight['type'] == 'success'
                ? Colors.green
                : insight['type'] == 'info'
                ? Colors.blue
                : Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'],
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: insight['type'] == 'warning'
                        ? Colors.orange.shade700
                        : insight['type'] == 'success'
                        ? Colors.green.shade700
                        : insight['type'] == 'info'
                        ? Colors.blue.shade700
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight['description'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (insight['action'] != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: insight['action'],
                    icon: Icon(
                      insight['actionIcon'] ?? Icons.arrow_forward,
                      size: 16,
                    ),
                    label: Text(insight['actionText'] ?? 'Learn More'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  List<Map<String, dynamic>> _generateGitHubInsights(
    List<dynamic> repositories,
  ) {
    final insights = <Map<String, dynamic>>[];

    if (repositories.isEmpty) return insights;

    // Analyze repository activity
    final now = DateTime.now();
    final recentRepos = repositories.where((repo) {
      final updatedAt = DateTime.tryParse(repo.updatedAt ?? '');
      if (updatedAt == null) return false;
      return now.difference(updatedAt).inDays <= 30;
    }).length;

    if (recentRepos == 0) {
      insights.add({
        'type': 'warning',
        'icon': Icons.schedule,
        'title': 'Low Repository Activity',
        'description':
            'No repositories have been updated in the last 30 days. Consider reviewing your development workflow.',
        'action': () {},
        'actionIcon': Icons.refresh,
        'actionText': 'Refresh Data',
      });
    } else if (recentRepos >= repositories.length * 0.8) {
      insights.add({
        'type': 'success',
        'icon': Icons.trending_up,
        'title': 'High Development Activity',
        'description':
            '${recentRepos} out of ${repositories.length} repositories have been recently updated. Great job staying active!',
      });
    }

    // Analyze language diversity
    final languages = <String, int>{};
    for (final repo in repositories) {
      if (repo.language != null && repo.language!.isNotEmpty) {
        languages[repo.language!] = (languages[repo.language!] ?? 0) + 1;
      }
    }

    if (languages.length == 1) {
      insights.add({
        'type': 'info',
        'icon': Icons.code,
        'title': 'Single Language Focus',
        'description':
            'All repositories use ${languages.keys.first}. Consider diversifying your tech stack for broader opportunities.',
      });
    } else if (languages.length >= 5) {
      insights.add({
        'type': 'success',
        'icon': Icons.language,
        'title': 'Diverse Tech Stack',
        'description':
            'You\'re working with ${languages.length} different programming languages. This shows great versatility!',
      });
    }

    // Analyze repository size and complexity
    final totalStars = repositories.fold<int>(
      0,
      (sum, repo) => sum + ((repo.stars ?? 0) as num).toInt(),
    );
    final avgStars = repositories.isNotEmpty
        ? totalStars / repositories.length
        : 0.0;

    if (avgStars > 50) {
      insights.add({
        'type': 'success',
        'icon': Icons.star,
        'title': 'High-Quality Repositories',
        'description':
            'Your repositories average ${avgStars.toStringAsFixed(1)} stars, indicating high community interest.',
      });
    } else if (avgStars < 5) {
      insights.add({
        'type': 'info',
        'icon': Icons.visibility,
        'title': 'Growing Your Presence',
        'description':
            'Consider adding documentation, README files, and contributing to open source to increase repository visibility.',
        'action': () {},
        'actionIcon': Icons.edit_document,
        'actionText': 'Improve Documentation',
      });
    }

    // Analyze private vs public repositories
    final privateRepos = repositories
        .where((repo) => repo.isPrivate == true)
        .length;
    final publicRepos = repositories.length - privateRepos;

    if (publicRepos == 0) {
      insights.add({
        'type': 'info',
        'icon': Icons.public,
        'title': 'All Private Repositories',
        'description':
            'Consider open-sourcing some projects to showcase your work and contribute to the community.',
      });
    } else if (publicRepos >= repositories.length * 0.7) {
      insights.add({
        'type': 'success',
        'icon': Icons.share,
        'title': 'Open Source Advocate',
        'description':
            '${publicRepos} out of ${repositories.length} repositories are public. Great contribution to open source!',
      });
    }

    // Analyze repository descriptions
    final reposWithDescription = repositories.where((repo) {
      return repo.description != null && repo.description.isNotEmpty;
    }).length;

    if (reposWithDescription < repositories.length * 0.5) {
      insights.add({
        'type': 'warning',
        'icon': Icons.description,
        'title': 'Missing Repository Descriptions',
        'description':
            'Only ${reposWithDescription} out of ${repositories.length} repositories have descriptions. Add descriptions to improve discoverability.',
        'action': () {},
        'actionIcon': Icons.edit,
        'actionText': 'Add Descriptions',
      });
    }

    return insights;
  }

  Widget _buildGitHubStatsGrid(
    BuildContext context,
    List<dynamic> repositories,
  ) {
    final totalStars = repositories.fold<int>(
      0,
      (sum, repo) => sum + ((repo.stars ?? 0) as num).toInt(),
    );
    final totalForks = repositories.fold<int>(
      0,
      (sum, repo) => sum + ((repo.forks ?? 0) as num).toInt(),
    );
    final totalIssues = repositories.fold<int>(
      0,
      (sum, repo) => sum + ((repo.openIssuesCount ?? 0) as num).toInt(),
    );
    final languages = <String, int>{};

    for (final repo in repositories) {
      if (repo.language != null && repo.language!.isNotEmpty) {
        languages[repo.language!] = (languages[repo.language!] ?? 0) + 1;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repository Statistics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildGitHubStatCard(
              context,
              'Repositories',
              repositories.length.toString(),
              Icons.folder,
              Theme.of(context).colorScheme.primary,
              'Total repositories',
            ),
            _buildGitHubStatCard(
              context,
              'Total Stars',
              totalStars.toString(),
              Icons.star,
              Colors.amber,
              'Community recognition',
            ),
            _buildGitHubStatCard(
              context,
              'Total Forks',
              totalForks.toString(),
              Icons.fork_right,
              Colors.green,
              'Project forks',
            ),
            _buildGitHubStatCard(
              context,
              'Open Issues',
              totalIssues.toString(),
              Icons.bug_report,
              Colors.red,
              'Issues to resolve',
            ),
            _buildGitHubStatCard(
              context,
              'Languages',
              languages.length.toString(),
              Icons.code,
              Colors.purple,
              'Tech diversity',
            ),
            _buildGitHubStatCard(
              context,
              'Avg. Stars',
              (totalStars / repositories.length).toStringAsFixed(1),
              Icons.trending_up,
              Colors.blue,
              'Per repository',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGitHubStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubActivityCharts(
    BuildContext context,
    GitHubProvider githubProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Development Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildGitHubActivityCard(
                context,
                'Language Distribution',
                _buildLanguageDistributionChart(context, githubProvider),
                Icons.pie_chart,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGitHubActivityCard(
                context,
                'Repository Size',
                _buildRepositorySizeChart(context, githubProvider),
                Icons.storage,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGitHubActivityCard(
    BuildContext context,
    String title,
    Widget chart,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(height: 120, child: chart),
        ],
      ),
    );
  }

  Widget _buildLanguageDistributionChart(
    BuildContext context,
    GitHubProvider githubProvider,
  ) {
    final repositories = githubProvider.repositories;
    final languages = <String, int>{};

    for (final repo in repositories) {
      if (repo.language != null && repo.language!.isNotEmpty) {
        languages[repo.language!] = (languages[repo.language!] ?? 0) + 1;
      }
    }

    if (languages.isEmpty) {
      return Center(
        child: Text(
          'No language data',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final sortedLanguages = languages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return PieChart(
      PieChartData(
        sections: sortedLanguages.take(5).map((entry) {
          final colors = [
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.red,
          ];
          final index = sortedLanguages.indexOf(entry);
          return PieChartSectionData(
            color: colors[index % colors.length],
            value: entry.value.toDouble(),
            title: '${entry.key}\n${entry.value}',
            radius: 40,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        centerSpaceRadius: 20,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildRepositorySizeChart(
    BuildContext context,
    GitHubProvider githubProvider,
  ) {
    final repositories = githubProvider.repositories;

    if (repositories.isEmpty) {
      return Center(
        child: Text(
          'No repository data',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Group repositories by size (stars)
    final smallRepos = repositories.where((r) => (r.stars ?? 0) < 10).length;
    final mediumRepos = repositories.where((r) {
      final stars = r.stars ?? 0;
      return stars >= 10 && stars < 100;
    }).length;
    final largeRepos = repositories.where((r) => (r.stars ?? 0) >= 100).length;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            [
              smallRepos,
              mediumRepos,
              largeRepos,
            ].reduce((a, b) => a > b ? a : b).toDouble() +
            1,
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
                const labels = ['Small', 'Medium', 'Large'];
                return Text(
                  labels[value.toInt()],
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
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: smallRepos.toDouble(),
                color: Colors.blue,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: mediumRepos.toDouble(),
                color: Colors.green,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: largeRepos.toDouble(),
                color: Colors.orange,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubRepositoryList(
    BuildContext context,
    List<dynamic> repositories,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repository Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...repositories
            .take(5)
            .map((repo) => _buildRepositoryCard(context, repo)),
        if (repositories.length > 5) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to full repository list
              },
              child: Text(
                'View All ${repositories.length} Repositories',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRepositoryCard(BuildContext context, dynamic repo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              repo.isPrivate ? Icons.lock : Icons.public,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  repo.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (repo.description != null &&
                    repo.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    repo.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (repo.language != null && repo.language.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          repo.language,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      repo.stars.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.fork_right,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      repo.forks.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
