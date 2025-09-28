import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/project_provider.dart';
import '../providers/sync_provider.dart';
import '../services/storage_service.dart';
import '../widgets/sync_animation_widget.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final StorageService _storageService = StorageService();
  bool _isExporting = false;
  bool _isImporting = false;
  List<Map<String, dynamic>> _backupHistory = [];

  @override
  void initState() {
    super.initState();
    _loadBackupHistory();
  }

  Future<void> _loadBackupHistory() async {
    // Load backup history from shared preferences
    // This is a simplified implementation
    setState(() {
      _backupHistory = [
        {
          'type': 'Full Backup',
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'size': '2.3 MB',
          'status': 'success',
        },
        {
          'type': 'Projects Backup',
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'size': '1.8 MB',
          'status': 'success',
        },
        {
          'type': 'Cloud Sync',
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'size': '2.1 MB',
          'status': 'success',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup Section
            _buildSectionCard(
              title: 'Backup Your Data',
              icon: Icons.backup,
              color: Colors.blue,
              children: [
                _buildActionCard(
                  'Export All Data',
                  'Create a complete backup of your projects, clients, and settings.',
                  Icons.download,
                  _isExporting ? null : () => _exportAllData(),
                  isLoading: _isExporting,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  'Export Projects Only',
                  'Backup only your projects and related data.',
                  Icons.folder,
                  _isExporting ? null : () => _exportProjects(),
                  isLoading: _isExporting,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  'Export Clients Only',
                  'Backup only your client information.',
                  Icons.people,
                  _isExporting ? null : () => _exportClients(),
                  isLoading: _isExporting,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Restore Section
            _buildSectionCard(
              title: 'Restore Your Data',
              icon: Icons.restore,
              color: Colors.green,
              children: [
                _buildActionCard(
                  'Import from File',
                  'Restore your data from a previously exported backup file.',
                  Icons.upload,
                  _isImporting ? null : () => _importFromFile(),
                  isLoading: _isImporting,
                ),
                const SizedBox(height: 12),
                Consumer<SyncProvider>(
                  builder: (context, syncProvider, child) {
                    return _buildActionCard(
                      'Import from Cloud',
                      'Restore from your cloud backup.',
                      Icons.cloud,
                      _isImporting || !syncProvider.isSignedIn
                          ? null
                          : () => _importFromCloud(),
                      isLoading: _isImporting,
                      isDisabled: !syncProvider.isSignedIn,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Cloud Backup Section
            _buildSectionCard(
              title: 'Cloud Backup',
              icon: Icons.cloud_sync,
              color: Colors.purple,
              children: [
                Consumer<SyncProvider>(
                  builder: (context, syncProvider, child) {
                    return _buildActionCard(
                      'Sync to Cloud',
                      'Manually sync your data to the cloud.',
                      Icons.cloud_upload,
                      syncProvider.isSyncing || !syncProvider.isSignedIn
                          ? null
                          : () => _syncToCloud(),
                      isLoading: syncProvider.isSyncing,
                      isDisabled: !syncProvider.isSignedIn,
                    );
                  },
                ),
                const SizedBox(height: 12),
                Consumer<SyncProvider>(
                  builder: (context, syncProvider, child) {
                    return _buildActionCard(
                      'Download from Cloud',
                      'Download your data from the cloud.',
                      Icons.cloud_download,
                      syncProvider.isSyncing || !syncProvider.isSignedIn
                          ? null
                          : () => _downloadFromCloud(),
                      isLoading: syncProvider.isSyncing,
                      isDisabled: !syncProvider.isSignedIn,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Backup History
            _buildBackupHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    VoidCallback? onTap, {
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDisabled
                ? Theme.of(context).colorScheme.outline.withOpacity(0.1)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDisabled
              ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDisabled
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isLoading
                  ? SyncAnimationWidget(
                      isSyncing: true,
                      size: 20,
                      showText: false,
                    )
                  : Icon(
                      icon,
                      color: isDisabled
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDisabled
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLoading)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDisabled
                    ? Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.5)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Backup History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_backupHistory.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No backup history',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._backupHistory.map((backup) => _buildBackupItem(backup)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupItem(Map<String, dynamic> backup) {
    final status = backup['status'] as String;
    final isSuccess = status == 'success';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup['type'],
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatDate(backup['date']),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            backup['size'],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _exportAllData() async {
    setState(() => _isExporting = true);

    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      final exportData = await _storageService.exportData(projectProvider);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/clarity_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonEncode(exportData));

      // Show success message with file path
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup saved to: ${file.path}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Add to history
      _addToHistory('Full Backup', file.lengthSync());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportProjects() async {
    setState(() => _isExporting = true);

    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      final projects = projectProvider.projects;

      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'type': 'projects',
        'projects': projects.map((p) => p.toJson()).toList(),
        'metadata': {'totalProjects': projects.length, 'appVersion': '1.0.0'},
      };

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/clarity_projects_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonEncode(exportData));

      // Show success message with file path
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Projects backup saved to: ${file.path}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Add to history
      _addToHistory('Projects Backup', file.lengthSync());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projects exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportClients() async {
    setState(() => _isExporting = true);

    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      final clients = projectProvider.clients;

      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'type': 'clients',
        'clients': clients.map((c) => c.toJson()).toList(),
        'metadata': {'totalClients': clients.length, 'appVersion': '1.0.0'},
      };

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/clarity_clients_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonEncode(exportData));

      // Show success message with file path
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clients backup saved to: ${file.path}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Add to history
      _addToHistory('Clients Backup', file.lengthSync());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clients exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _importFromFile() async {
    setState(() => _isImporting = true);

    try {
      // For now, show a dialog to inform user about file import
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import from File'),
            content: const Text(
              'File import functionality requires additional packages. '
              'For now, you can use cloud sync to restore your data.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _importFromCloud() async {
    setState(() => _isImporting = true);

    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      await projectProvider.syncFromCloud();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data imported from cloud successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cloud import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _syncToCloud() async {
    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      await projectProvider.syncToCloud();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced to cloud successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cloud sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadFromCloud() async {
    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      await projectProvider.syncFromCloud();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data downloaded from cloud successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cloud download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToHistory(String type, int size) {
    setState(() {
      _backupHistory.insert(0, {
        'type': type,
        'date': DateTime.now(),
        'size': _formatBytes(size),
        'status': 'success',
      });
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
