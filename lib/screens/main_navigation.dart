import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/project_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/global_sync_overlay.dart';
import 'projects_dashboard.dart';
import 'analytics_dashboard.dart';
import 'client_management_screen.dart';
import 'notes_screen.dart';
import 'settings_screen.dart';
import 'auth/login_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProjectsDashboard(), // Index 0 - Projects
    const AnalyticsDashboard(), // Index 1 - Analytics
    const ClientManagementScreen(), // Index 2 - Clients
    const NotesScreen(), // Index 3 - Notes
    const SettingsScreen(), // Index 4 - Settings
  ];

  final List<TabItem> _navBarItems = [
    TabItem(
      icon: const FaIcon(FontAwesomeIcons.house, size: 20),
      title: 'Projects',
    ),
    TabItem(
      icon: const FaIcon(FontAwesomeIcons.chartLine, size: 20),
      title: 'Analytics',
    ),
    TabItem(
      icon: const FaIcon(FontAwesomeIcons.users, size: 20),
      title: 'Clients',
    ),
    TabItem(
      icon: const FaIcon(FontAwesomeIcons.stickyNote, size: 20),
      title: 'Notes',
    ),
    TabItem(
      icon: const FaIcon(FontAwesomeIcons.gear, size: 20),
      title: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();
      context.read<ProjectProvider>().loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return GlobalSyncOverlay(
          child: Scaffold(
            body: Column(
              children: [
                // Show auth status bar for unauthenticated users
                if (!authProvider.isAuthenticated) _buildAuthStatusBar(),
                const SyncStatusBar(),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: _screens),
                ),
              ],
            ),
            bottomNavigationBar: ConvexAppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              activeColor: Theme.of(context).colorScheme.primary,
              style: TabStyle.fixed,
              height: 60,
              items: _navBarItems,
              initialActiveIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You\'re using Clarity offline. Sign in to sync your data across devices.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Text(
              'Sign In',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
