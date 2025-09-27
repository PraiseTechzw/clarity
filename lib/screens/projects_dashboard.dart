import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'new_project_screen.dart';
import 'project_details_screen.dart';
import 'notifications_screen.dart';

class ProjectsDashboard extends StatefulWidget {
  const ProjectsDashboard({super.key});

  @override
  State<ProjectsDashboard> createState() => _ProjectsDashboardState();
}

class _ProjectsDashboardState extends State<ProjectsDashboard> {
  String _searchQuery = '';
  Priority? _selectedPriority;
  PaymentStatus? _selectedPaymentStatus;
  String? _selectedClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          final filteredProjects = _getFilteredProjects(provider.projects);

          return RefreshIndicator(
            onRefresh: () => provider.loadProjects(),
            child: CustomScrollView(
              slivers: [
                // Quick Stats Section
                _buildQuickStatsSection(provider),

                // Search and Filter Section
                _buildSearchAndFilterSection(),

                // Projects List
                if (filteredProjects.isEmpty)
                  _buildEmptyState()
                else
                  _buildProjectsList(filteredProjects),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.dashboard,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Projects Dashboard'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: _navigateToNotifications,
          tooltip: 'Notifications',
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterBottomSheet,
          tooltip: 'Filter Projects',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading projects...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProjectProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    provider.clearError();
                    provider.loadProjects();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _navigateToNewProject,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Project'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection(ProjectProvider provider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Project Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Projects',
                    provider.projects.length.toString(),
                    Icons.folder,
                    Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    provider.projects
                        .where((p) => !p.isOverdue)
                        .length
                        .toString(),
                    Icons.play_circle,
                    Colors.green.shade300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Overdue',
                    provider.overdueProjects.length.toString(),
                    Icons.warning,
                    Colors.orange.shade300,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'High Priority',
                    provider.highPriorityProjects.length.toString(),
                    Icons.priority_high,
                    Colors.red.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Active Filters
            if (_hasActiveFilters()) _buildActiveFiltersChip(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList(List<Project> projects) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final project = projects[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProjectCard(
              project: project,
              onTap: () => _navigateToProjectDetails(project),
            ),
          );
        }, childCount: projects.length),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      heroTag: "new_project_fab",
      onPressed: _navigateToNewProject,
      icon: const Icon(Icons.add),
      label: const Text('New Project'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_open_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No projects found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _hasActiveFilters()
                      ? 'Try adjusting your filters or search terms'
                      : 'Create your first project to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (_hasActiveFilters())
                      OutlinedButton.icon(
                        onPressed: _clearAllFilters,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear Filters'),
                      ),
                    ElevatedButton.icon(
                      onPressed: _navigateToNewProject,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Project'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedPriority != null)
            Chip(
              label: Text('Priority: ${_selectedPriority!.name}'),
              onDeleted: () => setState(() => _selectedPriority = null),
            ),
          if (_selectedPaymentStatus != null)
            Chip(
              label: Text('Payment: ${_selectedPaymentStatus!.name}'),
              onDeleted: () => setState(() => _selectedPaymentStatus = null),
            ),
          if (_selectedClient != null)
            Chip(
              label: Text('Client: $_selectedClient'),
              onDeleted: () => setState(() => _selectedClient = null),
            ),
        ],
      ),
    );
  }

  List<Project> _getFilteredProjects(List<Project> projects) {
    return projects.where((project) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!project.name.toLowerCase().contains(query) &&
            !project.clientName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Priority filter
      if (_selectedPriority != null && project.priority != _selectedPriority) {
        return false;
      }

      // Payment status filter
      if (_selectedPaymentStatus != null &&
          project.paymentStatus != _selectedPaymentStatus) {
        return false;
      }

      // Client filter
      if (_selectedClient != null && project.clientName != _selectedClient) {
        return false;
      }

      return true;
    }).toList();
  }

  bool _hasActiveFilters() {
    return _selectedPriority != null ||
        _selectedPaymentStatus != null ||
        _selectedClient != null;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        selectedPriority: _selectedPriority,
        selectedPaymentStatus: _selectedPaymentStatus,
        selectedClient: _selectedClient,
        onFiltersChanged: (priority, paymentStatus, client) {
          setState(() {
            _selectedPriority = priority;
            _selectedPaymentStatus = paymentStatus;
            _selectedClient = client;
          });
        },
      ),
    );
  }

  void _navigateToNewProject() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NewProjectScreen()));
  }

  void _navigateToNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedPriority = null;
      _selectedPaymentStatus = null;
      _selectedClient = null;
    });
  }

  void _navigateToProjectDetails(Project project) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(project: project),
      ),
    );
  }
}
