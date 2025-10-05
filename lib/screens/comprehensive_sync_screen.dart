import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';
import '../providers/project_provider.dart';
import '../providers/auth_provider.dart';
import '../models/project.dart';
import '../screens/notes_screen.dart';

class ComprehensiveSyncScreen extends StatefulWidget {
  const ComprehensiveSyncScreen({super.key});

  @override
  State<ComprehensiveSyncScreen> createState() =>
      _ComprehensiveSyncScreenState();
}

class _ComprehensiveSyncScreenState extends State<ComprehensiveSyncScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshSyncStatus();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Consumer3<SyncProvider, ProjectProvider, AuthProvider>(
            builder:
                (context, syncProvider, projectProvider, authProvider, child) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sync Status Header
                        _buildSyncStatusHeader(syncProvider, authProvider),
                        const SizedBox(height: 24),

                        // Sync Actions
                        _buildSyncActions(syncProvider, projectProvider),
                        const SizedBox(height: 24),

                        // Sync Progress
                        if (syncProvider.isSyncing)
                          _buildSyncProgress(syncProvider),
                        if (syncProvider.isSyncing) const SizedBox(height: 24),

                        // Sync Summary
                        _buildSyncSummary(syncProvider),
                        const SizedBox(height: 24),

                        // Data Overview
                        _buildDataOverview(projectProvider),
                        const SizedBox(height: 24),

                        // Error Details
                        if (syncProvider.hasErrors)
                          _buildErrorDetails(syncProvider),
                        if (syncProvider.hasErrors) const SizedBox(height: 24),

                        // Advanced Options
                        _buildAdvancedOptions(syncProvider, projectProvider),
                      ],
                    ),
                  );
                },
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusHeader(
    SyncProvider syncProvider,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  authProvider.isAuthenticated
                      ? Icons.cloud_done
                      : Icons.cloud_off,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.isAuthenticated
                          ? 'Connected to Cloud'
                          : 'Not Connected',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      syncProvider.isOnline ? 'Online' : 'Offline',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            syncProvider.syncStatus,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          if (syncProvider.lastSyncTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last sync: ${_formatDateTime(syncProvider.lastSyncTime!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncActions(
    SyncProvider syncProvider,
    ProjectProvider projectProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sync Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    syncProvider.isSyncing ||
                        !syncProvider.isSignedIn ||
                        !syncProvider.isOnline
                    ? null
                    : () => _syncAllData(syncProvider, projectProvider),
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Sync All Data'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    syncProvider.isSyncing ||
                        !syncProvider.isSignedIn ||
                        !syncProvider.isOnline
                    ? null
                    : () => _downloadAllData(syncProvider),
                icon: const Icon(Icons.cloud_download),
                label: const Text('Download All'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: syncProvider.isSyncing || !syncProvider.isSignedIn
                    ? null
                    : () =>
                          _batchSyncWithProgress(syncProvider, projectProvider),
                icon: const Icon(Icons.sync),
                label: const Text('Batch Sync'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: syncProvider.isSyncing || !syncProvider.isSignedIn
                    ? null
                    : () => _clearCloudData(syncProvider),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Clear Cloud'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSyncProgress(SyncProvider syncProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sync,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sync Progress',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: syncProvider.syncProgress,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${syncProvider.completedItems}/${syncProvider.totalItems} items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${(syncProvider.syncProgress * 100).toInt()}%',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSummary(SyncProvider syncProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sync Summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem(
                'Total Items',
                syncProvider.totalItems.toString(),
                Icons.inventory,
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              _buildSummaryItem(
                'Completed',
                syncProvider.completedItems.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildSummaryItem(
                'Failed',
                syncProvider.failedItems.toString(),
                Icons.error,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataOverview(ProjectProvider projectProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local Data Overview',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDataItem(
                'Projects',
                projectProvider.projects.length.toString(),
                Icons.folder,
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              _buildDataItem(
                'Clients',
                projectProvider.clients.length.toString(),
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildDataItem(
                'Notes',
                '4', // This would come from notes provider
                Icons.note,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDetails(SyncProvider syncProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sync Errors',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...syncProvider.syncErrors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $error',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (syncProvider.canRetry)
                ElevatedButton.icon(
                  onPressed: () => _retryFailedSync(syncProvider),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => syncProvider.clearSyncErrors(),
                child: const Text('Clear Errors'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions(
    SyncProvider syncProvider,
    ProjectProvider projectProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Options',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Sync Settings'),
            subtitle: const Text('Configure sync behavior'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to sync settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Sync History'),
            subtitle: const Text('View sync logs and history'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to sync history
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Storage Usage'),
            subtitle: const Text('View cloud storage usage'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to storage usage
            },
          ),
        ],
      ),
    );
  }

  void _refreshSyncStatus() {
    // Refresh sync status
    setState(() {});
  }

  Future<void> _syncAllData(
    SyncProvider syncProvider,
    ProjectProvider projectProvider,
  ) async {
    // Get all data for sync
    final projects = projectProvider.projects;
    final clients = projectProvider.clients;
    final quickNotes = <QuickNote>[]; // This would come from notes provider
    final projectNotes =
        <String, List<Note>>{}; // This would come from project notes

    await syncProvider.syncAllData(
      projects: projects,
      clients: clients,
      quickNotes: quickNotes,
      projectNotes: projectNotes,
    );
  }

  Future<void> _downloadAllData(SyncProvider syncProvider) async {
    final data = await syncProvider.downloadAllDataEnhanced();
    if (data.isNotEmpty) {
      // Handle downloaded data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data downloaded successfully')),
      );
    }
  }

  Future<void> _batchSyncWithProgress(
    SyncProvider syncProvider,
    ProjectProvider projectProvider,
  ) async {
    final projects = projectProvider.projects;
    final clients = projectProvider.clients;
    final quickNotes = <QuickNote>[]; // This would come from notes provider
    final projectNotes =
        <String, List<Note>>{}; // This would come from project notes

    await syncProvider.batchSyncWithProgress(
      projects: projects,
      clients: clients,
      quickNotes: quickNotes,
      projectNotes: projectNotes,
    );
  }

  Future<void> _clearCloudData(SyncProvider syncProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cloud Data'),
        content: const Text(
          'Are you sure you want to clear all data from the cloud? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await syncProvider.clearAllCloudData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cloud data cleared')));
    }
  }

  Future<void> _retryFailedSync(SyncProvider syncProvider) async {
    // This would retry failed sync operations
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Retrying failed sync operations...')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
