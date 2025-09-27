import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/project_provider.dart';
import 'suggestions_screen.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () => _navigateToSuggestions(context),
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<ProjectProvider>().loadProjects();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Earnings',
                          '\$${provider.totalEarnings.toStringAsFixed(0)}',
                          Icons.account_balance_wallet,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Outstanding',
                          '\$${provider.totalOutstanding.toStringAsFixed(0)}',
                          Icons.pending,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Projects',
                          '${provider.projects.length}',
                          Icons.folder,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Overdue',
                          '${provider.overdueProjects.length}',
                          Icons.warning,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Charts Section
                  Text(
                    'Charts & Insights',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Earnings by Client Pie Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Earnings by Client',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _buildEarningsByClientChart(
                              context,
                              provider,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Project Status Overview
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project Status Overview',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _buildProjectStatusChart(context, provider),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Monthly Earnings Trend
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Earnings Trend',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _buildMonthlyEarningsChart(
                              context,
                              provider,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Task Completion Rate
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task Completion Rate',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _buildTaskCompletionChart(context, provider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToSuggestions(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SuggestionsScreen()));
  }

  Widget _buildEarningsByClientChart(
    BuildContext context,
    ProjectProvider provider,
  ) {
    final clientEarnings = <String, double>{};

    for (final project in provider.projects) {
      final clientName = project.clientName;
      clientEarnings[clientName] =
          (clientEarnings[clientName] ?? 0) + project.totalPaid;
    }

    if (clientEarnings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No earnings data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    final pieChartData = clientEarnings.entries.map((entry) {
      final index = clientEarnings.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '${entry.key}\n\$${entry.value.toStringAsFixed(0)}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: pieChartData,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildProjectStatusChart(
    BuildContext context,
    ProjectProvider provider,
  ) {
    final completedProjects = provider.projects
        .where((p) => p.progressPercentage >= 100)
        .length;
    final inProgressProjects = provider.projects
        .where((p) => p.progressPercentage > 0 && p.progressPercentage < 100)
        .length;
    final notStartedProjects = provider.projects
        .where((p) => p.progressPercentage == 0)
        .length;
    final overdueProjects = provider.overdueProjects.length;

    if (provider.projects.isEmpty) {
      return Center(
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
              'No project data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            [
              completedProjects,
              inProgressProjects,
              notStartedProjects,
              overdueProjects,
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
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(fontSize: 12);
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Completed';
                    break;
                  case 1:
                    text = 'In Progress';
                    break;
                  case 2:
                    text = 'Not Started';
                    break;
                  case 3:
                    text = 'Overdue';
                    break;
                  default:
                    text = '';
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
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
                toY: completedProjects.toDouble(),
                color: Colors.green,
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
                toY: inProgressProjects.toDouble(),
                color: Colors.blue,
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
                toY: notStartedProjects.toDouble(),
                color: Colors.grey,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: overdueProjects.toDouble(),
                color: Colors.red,
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

  Widget _buildMonthlyEarningsChart(
    BuildContext context,
    ProjectProvider provider,
  ) {
    final now = DateTime.now();
    final monthlyEarnings = <int, double>{};

    // Initialize last 6 months
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlyEarnings[month.month] = 0.0;
    }

    // Calculate earnings by month
    for (final project in provider.projects) {
      for (final payment in project.payments) {
        final paymentMonth = payment.date.month;
        if (monthlyEarnings.containsKey(paymentMonth)) {
          monthlyEarnings[paymentMonth] =
              monthlyEarnings[paymentMonth]! + payment.amount;
        }
      }
    }

    // Calculate max earnings for scaling (currently not used but available for future enhancements)
    // final maxEarnings = monthlyEarnings.values.isEmpty
    //     ? 1.0
    //     : monthlyEarnings.values.reduce((a, b) => a > b ? a : b);

    return LineChart(
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
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(fontSize: 12);
                final monthNames = [
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
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(monthNames[value.toInt() - 1], style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: monthlyEarnings.entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCompletionChart(
    BuildContext context,
    ProjectProvider provider,
  ) {
    int totalTasks = 0;
    int completedTasks = 0;

    for (final project in provider.projects) {
      for (final phase in project.phases) {
        totalTasks += phase.tasks.length;
        completedTasks += phase.tasks.where((task) => task.isCompleted).length;
      }
    }

    if (totalTasks == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No tasks available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final completionRate = (completedTasks / totalTasks) * 100;

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: completedTasks.toDouble(),
                  title: 'Completed\n$completedTasks',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.grey,
                  value: (totalTasks - completedTasks).toDouble(),
                  title: 'Pending\n${totalTasks - completedTasks}',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Overall Completion Rate: ${completionRate.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: completionRate >= 80
                ? Colors.green
                : completionRate >= 60
                ? Colors.orange
                : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
