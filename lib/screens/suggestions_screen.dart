import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/auth_provider.dart';
import '../models/project.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedTimeFilter = 'All';
  final List<String> _timeFilters = ['All', 'Today', 'This Week', 'This Month'];

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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
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
      appBar: AppBar(
        title: const Text('Smart Suggestions'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedTimeFilter = value;
              });
            },
            itemBuilder: (context) => _timeFilters.map((filter) {
              return PopupMenuItem<String>(
                value: filter,
                child: Row(
                  children: [
                    Icon(
                      _selectedTimeFilter == filter
                          ? Icons.check
                          : Icons.radio_button_unchecked,
                      color: _selectedTimeFilter == filter
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(filter),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProjectProvider>().loadProjects();
              _animationController.reset();
              _animationController.forward();
            },
          ),
        ],
      ),
      body: Consumer3<ProjectProvider, SyncProvider, AuthProvider>(
        builder: (context, projectProvider, syncProvider, authProvider, child) {
          if (projectProvider.isLoading) {
            return _buildLoadingState();
          }

          final suggestions = _generateIntelligentSuggestions(
            projectProvider,
            syncProvider,
            authProvider,
          );

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Smart Insights Header
                    _buildSmartInsightsHeader(context, suggestions),
                    const SizedBox(height: 24),

                    // AI-Powered Recommendations
                    _buildAIRecommendations(context, suggestions),
                    const SizedBox(height: 24),

                    // Priority Matrix
                    _buildPriorityMatrix(context, suggestions),
                    const SizedBox(height: 24),

                    // Time-based Suggestions
                    _buildTimeBasedSuggestions(context, suggestions),
                    const SizedBox(height: 24),

                    // Performance Insights
                    _buildPerformanceInsights(context, suggestions),
                    const SizedBox(height: 24),

                    // Action Items
                    _buildActionItems(context, suggestions),
                    const SizedBox(height: 24),

                    // All Good Message
                    if (suggestions.isEmpty) _buildAllGoodMessage(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _generateIntelligentSuggestions(
    ProjectProvider projectProvider,
    SyncProvider syncProvider,
    AuthProvider authProvider,
  ) {
    final now = DateTime.now();
    final projects = projectProvider.projects;

    // Filter projects based on time filter
    List<Project> filteredProjects = projects;
    switch (_selectedTimeFilter) {
      case 'Today':
        filteredProjects = projects
            .where((p) => _isSameDay(p.deadline, now))
            .toList();
        break;
      case 'This Week':
        filteredProjects = projects
            .where((p) => _isThisWeek(p.deadline, now))
            .toList();
        break;
      case 'This Month':
        filteredProjects = projects
            .where((p) => _isThisMonth(p.deadline, now))
            .toList();
        break;
    }

    final overdueProjects = filteredProjects
        .where((p) => p.deadline.isBefore(now) && p.progressPercentage < 100)
        .toList();

    final highPriorityProjects = filteredProjects
        .where((p) => p.priority == Priority.high && p.progressPercentage < 100)
        .toList();

    final projectsWithOutstandingPayments = filteredProjects
        .where((p) => p.budget > 0 && p.totalPaid < p.budget)
        .toList();

    final upcomingDeadlines = filteredProjects
        .where(
          (p) =>
              p.deadline.isAfter(now) &&
              p.deadline.difference(now).inDays <= 7 &&
              p.progressPercentage < 100,
        )
        .toList();

    final lowProgressProjects = filteredProjects
        .where(
          (p) =>
              p.progressPercentage < 30 &&
              p.deadline.difference(now).inDays <= 14,
        )
        .toList();

    final highValueProjects = filteredProjects
        .where((p) => p.budget > 10000 && p.progressPercentage < 100)
        .toList();

    final recentProjects = filteredProjects
        .where(
          (p) => p.createdAt.isAfter(now.subtract(const Duration(days: 7))),
        )
        .toList();

    return {
      'overdueProjects': overdueProjects,
      'highPriorityProjects': highPriorityProjects,
      'projectsWithOutstandingPayments': projectsWithOutstandingPayments,
      'upcomingDeadlines': upcomingDeadlines,
      'lowProgressProjects': lowProgressProjects,
      'highValueProjects': highValueProjects,
      'recentProjects': recentProjects,
      'totalProjects': filteredProjects.length,
      'completedProjects': filteredProjects
          .where((p) => p.progressPercentage >= 100)
          .length,
      'totalRevenue': filteredProjects.fold(0.0, (sum, p) => sum + p.budget),
      'paidRevenue': filteredProjects.fold(0.0, (sum, p) => sum + p.totalPaid),
      'isOnline': syncProvider.isOnline,
      'isAuthenticated': authProvider.isAuthenticated,
    };
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isThisWeek(DateTime date, DateTime now) {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  bool _isThisMonth(DateTime date, DateTime now) {
    return date.year == now.year && date.month == now.month;
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing your projects...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsightsHeader(
    BuildContext context,
    Map<String, dynamic> suggestions,
  ) {
    final totalProjects = suggestions['totalProjects'] as int;
    final completedProjects = suggestions['completedProjects'] as int;
    final completionRate = totalProjects > 0
        ? (completedProjects / totalProjects * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Insights',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                    ),
                    Text(
                      'AI-powered recommendations for your projects',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInsightMetric(
                context,
                'Completion Rate',
                '$completionRate%',
                Icons.check_circle,
                completionRate >= 80
                    ? Colors.green
                    : completionRate >= 60
                    ? Colors.orange
                    : Colors.red,
              ),
              const SizedBox(width: 16),
              _buildInsightMetric(
                context,
                'Active Projects',
                '${totalProjects - completedProjects}',
                Icons.work,
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              _buildInsightMetric(
                context,
                'Time Filter',
                _selectedTimeFilter,
                Icons.schedule,
                Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIRecommendations(
    BuildContext context,
    Map<String, dynamic> suggestions,
  ) {
    final recommendations = _generateAIRecommendations(suggestions);

    if (recommendations.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      context,
      'AI Recommendations',
      Icons.auto_awesome,
      Colors.purple,
      recommendations
          .map((rec) => _buildRecommendationItem(context, rec))
          .toList(),
    );
  }

  Widget _buildPriorityMatrix(
    BuildContext context,
    Map<String, dynamic> suggestions,
  ) {
    final overdueProjects = suggestions['overdueProjects'] as List<Project>;
    final highPriorityProjects =
        suggestions['highPriorityProjects'] as List<Project>;
    final upcomingDeadlines = suggestions['upcomingDeadlines'] as List<Project>;

    return _buildSectionCard(
      context,
      'Priority Matrix',
      Icons.priority_high,
      Colors.red,
      [
        if (overdueProjects.isNotEmpty) ...[
          _buildPriorityItem(
            context,
            'Overdue Projects',
            overdueProjects.length,
            Colors.red,
            Icons.warning,
          ),
          const SizedBox(height: 8),
        ],
        if (highPriorityProjects.isNotEmpty) ...[
          _buildPriorityItem(
            context,
            'High Priority',
            highPriorityProjects.length,
            Colors.orange,
            Icons.priority_high,
          ),
          const SizedBox(height: 8),
        ],
        if (upcomingDeadlines.isNotEmpty) ...[
          _buildPriorityItem(
            context,
            'Upcoming Deadlines',
            upcomingDeadlines.length,
            Colors.blue,
            Icons.schedule,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildTimeBasedSuggestions(
    BuildContext context,
    Map<String, dynamic> suggestions,
  ) {
    final lowProgressProjects =
        suggestions['lowProgressProjects'] as List<Project>;
    final highValueProjects = suggestions['highValueProjects'] as List<Project>;

    return _buildSectionCard(
      context,
      'Time-Based Insights',
      Icons.timeline,
      Colors.blue,
      [
        if (lowProgressProjects.isNotEmpty) ...[
          _buildTimeItem(
            context,
            'Low Progress Projects',
            lowProgressProjects.length,
            'Consider breaking down tasks',
          ),
          const SizedBox(height: 8),
        ],
        if (highValueProjects.isNotEmpty) ...[
          _buildTimeItem(
            context,
            'High Value Projects',
            highValueProjects.length,
            'Focus on revenue generation',
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildPerformanceInsights(
    BuildContext context,
    Map<String, dynamic> suggestions,
  ) {
    final totalRevenue = suggestions['totalRevenue'] as double;
    final paidRevenue = suggestions['paidRevenue'] as double;
    final paymentRate = totalRevenue > 0
        ? (paidRevenue / totalRevenue * 100).round()
        : 0;

    return _buildSectionCard(
      context,
      'Performance Insights',
      Icons.analytics,
      Colors.green,
      [
        _buildPerformanceItem(
          context,
          'Payment Collection',
          '$paymentRate%',
          paymentRate >= 80 ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildPerformanceItem(
          context,
          'Total Revenue',
          '\$${totalRevenue.toStringAsFixed(0)}',
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildPerformanceItem(
          context,
          'Outstanding',
          '\$${(totalRevenue - paidRevenue).toStringAsFixed(0)}',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildActionItems(
    BuildContext context,
    Map<String, dynamic> suggestions,
  ) {
    final actionItems = _generateActionItems(suggestions);

    if (actionItems.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      context,
      'Recommended Actions',
      Icons.task_alt,
      Colors.orange,
      actionItems.map((item) => _buildActionItem(context, item)).toList(),
    );
  }

  List<Map<String, dynamic>> _generateAIRecommendations(
    Map<String, dynamic> suggestions,
  ) {
    final recommendations = <Map<String, dynamic>>[];

    if ((suggestions['overdueProjects'] as List).isNotEmpty) {
      recommendations.add({
        'title': 'Address Overdue Projects',
        'description':
            'You have ${(suggestions['overdueProjects'] as List).length} overdue projects. Consider renegotiating deadlines or prioritizing critical tasks.',
        'priority': 'High',
        'action': 'Review overdue projects',
        'icon': Icons.warning,
        'color': Colors.red,
      });
    }

    if ((suggestions['lowProgressProjects'] as List).isNotEmpty) {
      recommendations.add({
        'title': 'Boost Project Progress',
        'description':
            'Some projects have low progress despite approaching deadlines. Consider task breakdown or resource allocation.',
        'priority': 'Medium',
        'action': 'Analyze project progress',
        'icon': Icons.trending_up,
        'color': Colors.orange,
      });
    }

    if ((suggestions['projectsWithOutstandingPayments'] as List).isNotEmpty) {
      recommendations.add({
        'title': 'Follow Up on Payments',
        'description':
            'You have outstanding payments that could improve your cash flow.',
        'priority': 'High',
        'action': 'Send payment reminders',
        'icon': Icons.payment,
        'color': Colors.green,
      });
    }

    return recommendations;
  }

  List<Map<String, dynamic>> _generateActionItems(
    Map<String, dynamic> suggestions,
  ) {
    final actions = <Map<String, dynamic>>[];

    if ((suggestions['upcomingDeadlines'] as List).isNotEmpty) {
      actions.add({
        'title': 'Prepare for Upcoming Deadlines',
        'description': 'Review and prepare for projects due in the next 7 days',
        'icon': Icons.schedule,
        'color': Colors.blue,
      });
    }

    if ((suggestions['recentProjects'] as List).isNotEmpty) {
      actions.add({
        'title': 'Update Recent Projects',
        'description': 'Update progress on recently created projects',
        'icon': Icons.update,
        'color': Colors.purple,
      });
    }

    return actions;
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
    BuildContext context,
    Map<String, dynamic> recommendation,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (recommendation['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (recommendation['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                recommendation['icon'] as IconData,
                color: recommendation['color'] as Color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                recommendation['title'] as String,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: recommendation['color'] as Color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: recommendation['color'] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  recommendation['priority'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            recommendation['description'] as String,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityItem(
    BuildContext context,
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeItem(
    BuildContext context,
    String title,
    int count,
    String suggestion,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                suggestion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, Map<String, dynamic> action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            action['icon'] as IconData,
            color: action['color'] as Color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action['title'] as String,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  action['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildAllGoodMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, size: 60, color: Colors.green),
          ),
          const SizedBox(height: 24),
          Text(
            'Excellent Work!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No urgent tasks or overdue items detected',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Keep up the great work! 🎉',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
