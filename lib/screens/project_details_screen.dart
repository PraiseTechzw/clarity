import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../widgets/project_header.dart';
import 'phases_tasks_screen.dart';
import 'payment_tracking_screen.dart';
import 'project_notes_screen.dart';
import 'edit_project_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Project _currentProject;

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: ProjectHeader(project: _currentProject),
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: _handleMenuAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit Project'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy),
                          SizedBox(width: 8),
                          Text('Duplicate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.assignment), text: 'Phases & Tasks'),
                    Tab(icon: Icon(Icons.payment), text: 'Payments'),
                    Tab(icon: Icon(Icons.note), text: 'Notes'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            PhasesTasksScreen(project: _currentProject),
            PaymentTrackingScreen(project: _currentProject),
            ProjectNotesScreen(project: _currentProject),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editProject();
        break;
      case 'duplicate':
        _duplicateProject();
        break;
      case 'delete':
        _deleteProject();
        break;
    }
  }

  void _editProject() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProjectScreen(
          project: _currentProject,
          onProjectUpdated: (updatedProject) {
            setState(() {
              _currentProject = updatedProject;
            });
            context.read<ProjectProvider>().updateProject(updatedProject);
          },
        ),
      ),
    );
  }

  void _duplicateProject() {
    // TODO: Implement duplicate project functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Duplicate project functionality coming soon!'),
      ),
    );
  }

  void _deleteProject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${_currentProject.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProjectProvider>().deleteProject(_currentProject.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
