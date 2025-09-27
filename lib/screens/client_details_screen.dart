import 'package:flutter/material.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';
import 'project_details_screen.dart';

class ClientDetailsScreen extends StatelessWidget {
  final Client client;
  final List<Project> projects;

  const ClientDetailsScreen({
    super.key,
    required this.client,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalEarnings = projects.fold(
      0.0,
      (sum, project) => sum + project.totalPaid,
    );
    final totalOutstanding = projects.fold(
      0.0,
      (sum, project) => sum + project.outstandingBalance,
    );

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withOpacity(0.1),
                        colorScheme.surface,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: colorScheme.primary
                                    .withOpacity(0.1),
                                child: Text(
                                  client.name.isNotEmpty
                                      ? client.name[0].toUpperCase()
                                      : 'C',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      client.name,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (client.company != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        client.company!,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Contact Info
                          if (client.email != null || client.phone != null) ...[
                            Row(
                              children: [
                                if (client.email != null) ...[
                                  Icon(
                                    Icons.email,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    client.email!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                if (client.phone != null) ...[
                                  Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    client.phone!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Stats
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'Projects',
                                  '${projects.length}',
                                  Icons.folder,
                                  colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'Earnings',
                                  '\$${totalEarnings.toStringAsFixed(0)}',
                                  Icons.account_balance_wallet,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'Outstanding',
                                  '\$${totalOutstanding.toStringAsFixed(0)}',
                                  Icons.pending,
                                  totalOutstanding > 0
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: projects.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProjectCard(
                      project: project,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProjectDetailsScreen(project: project),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            'No Projects Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This client doesn\'t have any projects yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
