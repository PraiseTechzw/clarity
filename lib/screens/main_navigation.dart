import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/project_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/github_provider.dart';
import '../widgets/global_sync_overlay.dart';
import 'projects_dashboard.dart';
import 'analytics_dashboard.dart';
import 'client_management_screen.dart';
import 'notes_screen.dart';
import 'enhanced_budget_dashboard.dart';
import 'settings_screen.dart';
import 'github_integration_screen.dart';
import 'auth/login_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Widget> _screens = [
    const ProjectsDashboard(), // Index 0 - Projects
    const AnalyticsDashboard(), // Index 1 - Analytics
    const NotesScreen(), // Index 2 - Notes
    const EnhancedBudgetDashboard(), // Index 3 - Budget
    const ClientManagementScreen(), // Index 4 - Clients
    const SettingsScreen(), // Index 5 - Settings
  ];

  List<TabItem> _buildNavBarItems(BuildContext context) {
    return [
      TabItem(
        icon: FaIcon(
          FontAwesomeIcons.house,
          size: 22,
          color: _currentIndex == 0
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: 'Projects',
      ),
      TabItem(
        icon: FaIcon(
          FontAwesomeIcons.chartLine,
          size: 22,
          color: _currentIndex == 1
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: 'Analytics',
      ),
      TabItem(
        icon: FaIcon(
          FontAwesomeIcons.stickyNote,
          size: 22,
          color: _currentIndex == 2
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: 'Notes',
      ),
      TabItem(
        icon: FaIcon(
          FontAwesomeIcons.wallet,
          size: 22,
          color: _currentIndex == 3
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: 'Budget',
      ),
      TabItem(
        icon: FaIcon(
          FontAwesomeIcons.users,
          size: 22,
          color: _currentIndex == 4
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: 'Clients',
      ),
      TabItem(
        icon: FaIcon(
          FontAwesomeIcons.gear,
          size: 22,
          color: _currentIndex == 5
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: 'Settings',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();
      context.read<ProjectProvider>().loadClients();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            floatingActionButton: Consumer<GitHubProvider>(
              builder: (context, githubProvider, child) {
                // Only show GitHub FAB on Analytics tab when not authenticated
                if (!githubProvider.isAuthenticated && _currentIndex == 1) {
                  return FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GitHubIntegrationScreen(),
                        ),
                      );
                    },
                    icon: Image.asset(
                      'assets/github.png',
                      width: 20,
                      height: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: const Text('Connect GitHub'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            bottomNavigationBar: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.95),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ConvexAppBar(
                      backgroundColor: Colors.transparent,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      activeColor: Theme.of(context).colorScheme.primary,
                      style: TabStyle.react,
                      height: 65,
                      elevation: 0,
                      curve: Curves.easeInOut,
                      items: _buildNavBarItems(context),
                      initialActiveIndex: _currentIndex,
                      onTap: (index) {
                        _handleTabTap(index);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _handleTabTap(int index) {
    if (index != _currentIndex) {
      // Haptic feedback for better UX
      HapticFeedback.lightImpact();

      // Animate the navigation bar
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Update the current index
      setState(() {
        _currentIndex = index;
      });
    }
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
