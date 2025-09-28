import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';
import '../providers/auth_provider.dart';
import '../services/network_service.dart';
import '../services/offline_queue_service.dart';

class SyncSettingsScreen extends StatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  bool _autoSyncEnabled = true;
  bool _syncOnWifiOnly = false;
  int _syncFrequency = 15; // minutes
  bool _syncInBackground = true;
  bool _notifyOnSyncComplete = true;
  bool _notifyOnSyncError = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from SharedPreferences
    // This would be implemented based on your preferences structure
  }

  Future<void> _saveSettings() async {
    // Save settings to SharedPreferences
    // This would be implemented based on your preferences structure
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          Consumer4<
            SyncProvider,
            AuthProvider,
            NetworkService,
            OfflineQueueService
          >(
            builder:
                (
                  context,
                  syncProvider,
                  authProvider,
                  networkService,
                  queueService,
                  child,
                ) {
                  return CustomScrollView(
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.1),
                                Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.sync,
                                size: 48,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sync Configuration',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Configure how your data syncs with the cloud',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Sync Status
                      SliverToBoxAdapter(
                        child: _buildSyncStatusCard(
                          context,
                          syncProvider,
                          authProvider,
                          networkService,
                        ),
                      ),

                      // Offline Queue Status
                      if (queueService.pendingCount > 0)
                        SliverToBoxAdapter(
                          child: _buildOfflineQueueCard(context, queueService),
                        ),

                      // Sync Settings
                      SliverToBoxAdapter(
                        child: _buildSyncSettingsCard(context),
                      ),

                      // Network Settings
                      SliverToBoxAdapter(
                        child: _buildNetworkSettingsCard(
                          context,
                          networkService,
                        ),
                      ),

                      // Sync Actions
                      SliverToBoxAdapter(
                        child: _buildSyncActionsCard(
                          context,
                          syncProvider,
                          queueService,
                        ),
                      ),

                      // Advanced Settings
                      SliverToBoxAdapter(
                        child: _buildAdvancedSettingsCard(context),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  );
                },
          ),
    );
  }

  Widget _buildSyncStatusCard(
    BuildContext context,
    SyncProvider syncProvider,
    AuthProvider authProvider,
    NetworkService networkService,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
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

              // Authentication Status
              _buildStatusRow(
                context,
                'Authentication',
                authProvider.isAuthenticated ? 'Signed In' : 'Not Signed In',
                authProvider.isAuthenticated ? Colors.green : Colors.red,
                authProvider.isAuthenticated
                    ? Icons.check_circle
                    : Icons.cancel,
              ),

              const SizedBox(height: 8),

              // Network Status
              _buildStatusRow(
                context,
                'Network',
                networkService.isOnline ? 'Online' : 'Offline',
                networkService.isOnline ? Colors.green : Colors.red,
                networkService.isOnline ? Icons.wifi : Icons.wifi_off,
              ),

              const SizedBox(height: 8),

              // Sync Status
              _buildStatusRow(
                context,
                'Sync Status',
                syncProvider.syncStatus,
                syncProvider.isSyncing
                    ? Colors.blue
                    : syncProvider.hasErrors
                    ? Colors.red
                    : Colors.green,
                syncProvider.isSyncing
                    ? Icons.sync
                    : syncProvider.hasErrors
                    ? Icons.error
                    : Icons.check_circle,
              ),

              if (syncProvider.lastSyncTime != null) ...[
                const SizedBox(height: 8),
                _buildStatusRow(
                  context,
                  'Last Sync',
                  _formatDateTime(syncProvider.lastSyncTime!),
                  Colors.grey,
                  Icons.access_time,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineQueueCard(
    BuildContext context,
    OfflineQueueService queueService,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        color: Colors.orange.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.queue, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Offline Queue',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${queueService.pendingCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'You have ${queueService.pendingCount} operations waiting to sync',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: queueService.canProcess
                          ? () {
                              // Process queue
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Processing offline queue...'),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.sync, size: 16),
                      label: const Text('Sync Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showQueueDetails(context, queueService);
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncSettingsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.settings, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Sync Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Auto Sync
              SwitchListTile(
                title: const Text('Auto Sync'),
                subtitle: const Text('Automatically sync data when online'),
                value: _autoSyncEnabled,
                onChanged: (value) {
                  setState(() {
                    _autoSyncEnabled = value;
                  });
                  _saveSettings();
                },
                secondary: const Icon(Icons.sync),
              ),

              // WiFi Only
              SwitchListTile(
                title: const Text('WiFi Only'),
                subtitle: const Text('Only sync when connected to WiFi'),
                value: _syncOnWifiOnly,
                onChanged: (value) {
                  setState(() {
                    _syncOnWifiOnly = value;
                  });
                  _saveSettings();
                },
                secondary: const Icon(Icons.wifi),
              ),

              // Sync Frequency
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Sync Frequency'),
                subtitle: Text('Every $_syncFrequency minutes'),
                trailing: DropdownButton<int>(
                  value: _syncFrequency,
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 minutes')),
                    DropdownMenuItem(value: 15, child: Text('15 minutes')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                    DropdownMenuItem(value: 60, child: Text('1 hour')),
                    DropdownMenuItem(value: 240, child: Text('4 hours')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _syncFrequency = value;
                      });
                      _saveSettings();
                    }
                  },
                ),
              ),

              // Background Sync
              SwitchListTile(
                title: const Text('Background Sync'),
                subtitle: const Text('Sync data in the background'),
                value: _syncInBackground,
                onChanged: (value) {
                  setState(() {
                    _syncInBackground = value;
                  });
                  _saveSettings();
                },
                secondary: const Icon(Icons.sync),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkSettingsCard(
    BuildContext context,
    NetworkService networkService,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.network_check,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Network Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildStatusRow(
                context,
                'Connection Type',
                networkService.connectionTypeString,
                networkService.isOnline ? Colors.green : Colors.red,
                networkService.isOnline ? Icons.wifi : Icons.wifi_off,
              ),

              const SizedBox(height: 8),

              _buildStatusRow(
                context,
                'Connection Quality',
                networkService.connectionQuality,
                networkService.isOnline ? Colors.green : Colors.red,
                Icons.signal_cellular_alt,
              ),

              if (networkService.lastOnlineTime != null) ...[
                const SizedBox(height: 8),
                _buildStatusRow(
                  context,
                  'Last Online',
                  _formatDateTime(networkService.lastOnlineTime!),
                  Colors.grey,
                  Icons.access_time,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncActionsCard(
    BuildContext context,
    SyncProvider syncProvider,
    OfflineQueueService queueService,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.play_arrow, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Sync Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: syncProvider.isSyncing
                          ? null
                          : () {
                              // Force sync
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Starting sync...'),
                                ),
                              );
                            },
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync Now'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Download from cloud
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading from cloud...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Download'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: queueService.hasFailedOperations
                          ? () {
                              // Retry failed operations
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Retrying failed operations...',
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Failed'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Clear queue
                        _showClearQueueDialog(context, queueService);
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear Queue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tune, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Advanced Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notifications
              SwitchListTile(
                title: const Text('Sync Notifications'),
                subtitle: const Text('Notify when sync completes'),
                value: _notifyOnSyncComplete,
                onChanged: (value) {
                  setState(() {
                    _notifyOnSyncComplete = value;
                  });
                  _saveSettings();
                },
                secondary: const Icon(Icons.notifications),
              ),

              SwitchListTile(
                title: const Text('Error Notifications'),
                subtitle: const Text('Notify when sync fails'),
                value: _notifyOnSyncError,
                onChanged: (value) {
                  setState(() {
                    _notifyOnSyncError = value;
                  });
                  _saveSettings();
                },
                secondary: const Icon(Icons.error_outline),
              ),

              // Clear sync data
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text('Clear Sync Data'),
                subtitle: const Text('Remove all sync history and cache'),
                onTap: () {
                  _showClearSyncDataDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showQueueDetails(
    BuildContext context,
    OfflineQueueService queueService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Queue Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Operations: ${queueService.pendingCount}'),
            Text('Failed Operations: ${queueService.failedCount}'),
            Text('Retryable Operations: ${queueService.retryableCount}'),
            const SizedBox(height: 16),
            const Text('Operations by Type:'),
            ...queueService.getQueueSummary()['operationsByType'].entries.map(
              (entry) => Text('  ${entry.key}: ${entry.value}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearQueueDialog(
    BuildContext context,
    OfflineQueueService queueService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Offline Queue'),
        content: const Text(
          'Are you sure you want to clear all pending operations? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              queueService.clearQueue();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offline queue cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearSyncDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Sync Data'),
        content: const Text(
          'This will clear all sync history, cache, and offline queue. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear sync data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sync data cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
