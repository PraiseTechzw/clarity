import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'new_project_screen.dart';
import 'project_details_screen.dart';

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
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadProjects();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredProjects = _getFilteredProjects(provider.projects);

          if (filteredProjects.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadProjects(),
            child: Column(
              children: [
                if (_hasActiveFilters()) _buildActiveFiltersChip(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProjectCard(
                          project: project,
                          onTap: () => _navigateToProjectDetails(project),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToNewProject,
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No projects yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first project to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToNewProject,
            icon: const Icon(Icons.add),
            label: const Text('Create Project'),
          ),
        ],
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

  void _navigateToProjectDetails(Project project) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(project: project),
      ),
    );
  }
}
