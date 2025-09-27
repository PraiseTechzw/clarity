import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import 'project_details_screen.dart';
import '../models/project.dart';

class SuggestionsScreen extends StatelessWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProjectProvider>().loadProjects();
            },
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final overdueProjects = provider.overdueProjects;
          final highPriorityProjects = provider.highPriorityProjects;
          final projectsWithOutstandingPayments =
              provider.projectsWithOutstandingPayments;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Priority Tasks
                if (highPriorityProjects.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'High Priority Projects',
                    Icons.priority_high,
                  ),
                  const SizedBox(height: 8),
                  ...highPriorityProjects.map(
                    (project) => _buildSuggestionCard(
                      context,
                      project,
                      'High Priority',
                      Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Overdue Tasks
                if (overdueProjects.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'Overdue Projects',
                    Icons.warning,
                  ),
                  const SizedBox(height: 8),
                  ...overdueProjects.map(
                    (project) => _buildSuggestionCard(
                      context,
                      project,
                      'Overdue',
                      Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Outstanding Payments
                if (projectsWithOutstandingPayments.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'Outstanding Payments',
                    Icons.payment,
                  ),
                  const SizedBox(height: 8),
                  ...projectsWithOutstandingPayments.map(
                    (project) => _buildSuggestionCard(
                      context,
                      project,
                      'Payment Due',
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // All Good Message
                if (overdueProjects.isEmpty &&
                    highPriorityProjects.isEmpty &&
                    projectsWithOutstandingPayments.isEmpty)
                  _buildAllGoodMessage(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    Project project,
    String type,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.lightbulb, color: color, size: 20),
        ),
        title: Text(project.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.clientName),
            const SizedBox(height: 4),
            Text(
              type,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(project: project),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllGoodMessage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'All Good!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No urgent tasks or overdue items',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
