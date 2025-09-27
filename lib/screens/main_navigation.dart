import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import 'projects_dashboard.dart';
import 'suggestions_screen.dart';
import 'analytics_dashboard.dart';
import 'client_management_screen.dart';
import 'notifications_screen.dart';
import 'notes_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProjectsDashboard(),
    const SuggestionsScreen(),
    const AnalyticsDashboard(),
    const ClientManagementScreen(),
    const NotificationsScreen(),
    const NotesScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Projects',
    ),
    const NavigationDestination(
      icon: Icon(Icons.lightbulb_outline),
      selectedIcon: Icon(Icons.lightbulb),
      label: 'Suggestions',
    ),
    const NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: 'Analytics',
    ),
    const NavigationDestination(
      icon: Icon(Icons.people_outlined),
      selectedIcon: Icon(Icons.people),
      label: 'Clients',
    ),
    const NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: 'Notifications',
    ),
    const NavigationDestination(
      icon: Icon(Icons.note_outlined),
      selectedIcon: Icon(Icons.note),
      label: 'Notes',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }
}
