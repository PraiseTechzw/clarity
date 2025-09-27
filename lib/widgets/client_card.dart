import 'package:flutter/material.dart';
import '../models/project.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final List<Project> projects;
  final VoidCallback? onTap;

  const ClientCard({
    super.key,
    required this.client,
    required this.projects,
    this.onTap,
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
    final activeProjects = projects.where((p) => !p.isOverdue).length;
    final overdueProjects = projects.where((p) => p.isOverdue).length;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      client.name.isNotEmpty
                          ? client.name[0].toUpperCase()
                          : 'C',
                      style: TextStyle(
                        color: colorScheme.primary,
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
                          client.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (client.company != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            client.company!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (client.email != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                client.email!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (overdueProjects > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        '$overdueProjects overdue',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Projects',
                      '${projects.length}',
                      Icons.folder,
                      colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Earnings',
                      '\$${totalEarnings.toStringAsFixed(0)}',
                      Icons.account_balance_wallet,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Outstanding',
                      '\$${totalOutstanding.toStringAsFixed(0)}',
                      Icons.pending,
                      totalOutstanding > 0 ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Project Status
              Row(
                children: [
                  if (activeProjects > 0) ...[
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '$activeProjects active',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (overdueProjects > 0) ...[
                    Icon(Icons.warning, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '$overdueProjects overdue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (client.phone != null)
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          client.phone!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
