import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/sync_animation_widget.dart';

class CloudSyncScreen extends StatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  State<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends State<CloudSyncScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync'),
        centerTitle: true,
        actions: [
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              return IconButton(
                icon: Icon(
                  syncProvider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: syncProvider.isOnline ? Colors.green : Colors.red,
                ),
                onPressed: () {
                  // Toggle online status for testing
                  syncProvider.setOnlineStatus(!syncProvider.isOnline);
                },
                tooltip: syncProvider.isOnline ? 'Online' : 'Offline',
              );
            },
          ),
        ],
      ),
      body: Consumer2<SyncProvider, ProjectProvider>(
        builder: (context, syncProvider, projectProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sync Status Card
                _buildStatusCard(context, syncProvider),

                const SizedBox(height: 16),

                // Sync Actions
                _buildSyncActionsCard(context, syncProvider, projectProvider),

                const SizedBox(height: 16),

                // Sync Results
                if (syncProvider.syncResults.isNotEmpty)
                  _buildSyncResultsCard(context, syncProvider),

                const SizedBox(height: 16),

                // Cloud Data Management
                _buildCloudDataCard(context, syncProvider, projectProvider),

                const SizedBox(height: 16),

                // Sync Summary
                _buildSyncSummaryCard(context, syncProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, SyncProvider syncProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  syncProvider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: syncProvider.isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sync Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              context,
              'Status',
              syncProvider.syncStatus,
              syncProvider.isSyncing ? Colors.orange : Colors.green,
            ),
            _buildStatusRow(
              context,
              'Last Sync',
              syncProvider.lastSyncTime != null
                  ? _formatDateTime(syncProvider.lastSyncTime!)
                  : 'Never',
              Colors.blue,
            ),
            _buildStatusRow(
              context,
              'Authentication',
              syncProvider.isSignedIn ? 'Signed In' : 'Not Signed In',
              syncProvider.isSignedIn ? Colors.green : Colors.red,
            ),
            _buildStatusRow(
              context,
              'Connection',
              syncProvider.isOnline ? 'Online' : 'Offline',
              syncProvider.isOnline ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncActionsCard(
    BuildContext context,
    SyncProvider syncProvider,
    ProjectProvider projectProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Actions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              'Sync All Data',
              'Upload all local data to cloud',
              syncProvider.isSyncing ? Icons.sync : Icons.cloud_upload,
              syncProvider.isSyncing || !syncProvider.isOnline
                  ? null
                  : () => _syncAllData(syncProvider, projectProvider),
              isSyncing: syncProvider.isSyncing,
            ),
            _buildActionButton(
              context,
              'Download Data',
              'Download all data from cloud',
              Icons.cloud_download,
              syncProvider.isSyncing || !syncProvider.isOnline
                  ? null
                  : () => _downloadData(syncProvider),
            ),
            _buildActionButton(
              context,
              'Force Sync',
              'Retry failed sync operations',
              Icons.refresh,
              syncProvider.isSyncing || !syncProvider.isOnline
                  ? null
                  : () => _forceSync(syncProvider, projectProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onPressed, {
    bool isSyncing = false,
  }) {
    return ListTile(
      leading: isSyncing
          ? SyncAnimationWidget(isSyncing: true, size: 24, showText: false)
          : Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onPressed != null
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : const Icon(Icons.block, color: Colors.grey),
      onTap: onPressed,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSyncResultsCard(
    BuildContext context,
    SyncProvider syncProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sync Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => syncProvider.clearSyncResults(),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...syncProvider.syncResults.entries.map(
              (entry) => _buildSyncResultItem(context, entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncResultItem(
    BuildContext context,
    String itemId,
    bool success,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(itemId, style: Theme.of(context).textTheme.bodySmall),
          ),
          Text(
            success ? 'Success' : 'Failed',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: success ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudDataCard(
    BuildContext context,
    SyncProvider syncProvider,
    ProjectProvider projectProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cloud Data Management',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              'Clear Cloud Data',
              'Delete all data from cloud (Dangerous)',
              Icons.delete_forever,
              syncProvider.isSyncing
                  ? null
                  : () => _clearCloudData(syncProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSummaryCard(
    BuildContext context,
    SyncProvider syncProvider,
  ) {
    final summary = syncProvider.getSyncSummary();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            _buildSummaryRow(
              context,
              'Total Items',
              '${summary['totalItems']}',
            ),
            _buildSummaryRow(
              context,
              'Successful',
              '${summary['successfulItems']}',
            ),
            _buildSummaryRow(context, 'Failed', '${summary['failedItems']}'),
            _buildSummaryRow(
              context,
              'Last Sync',
              summary['lastSyncTime'] != null
                  ? _formatDateTime(summary['lastSyncTime'])
                  : 'Never',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _syncAllData(
    SyncProvider syncProvider,
    ProjectProvider projectProvider,
  ) async {
    final results = await syncProvider.syncAllData(
      projects: projectProvider.projects,
      clients: projectProvider.clients,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Synced ${results.length} items'),
          backgroundColor: results.values.every((success) => success)
              ? Colors.green
              : Colors.orange,
        ),
      );
    }
  }

  Future<void> _downloadData(SyncProvider syncProvider) async {
    final data = await syncProvider.downloadAllData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded ${data.length} collections'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _forceSync(
    SyncProvider syncProvider,
    ProjectProvider projectProvider,
  ) async {
    await syncProvider.forceSync(
      projects: projectProvider.projects,
      clients: projectProvider.clients,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Force sync completed'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _clearCloudData(SyncProvider syncProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cloud Data'),
        content: const Text(
          'Are you sure you want to delete all data from the cloud? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await syncProvider.clearAllCloudData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud data cleared'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
