import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
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
                _buildInfoCard(
                  'Export All Data',
                  'Create a complete backup of your projects, clients, and settings.',
                  Icons.download,
                  () => _exportAllData(),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Export Projects Only',
                  'Backup only your projects and related data.',
                  Icons.folder,
                  () => _exportProjects(),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Export Clients Only',
                  'Backup only your client information.',
                  Icons.people,
                  () => _exportClients(),
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
                _buildInfoCard(
                  'Import from File',
                  'Restore your data from a previously exported backup file.',
                  Icons.upload,
                  () => _importFromFile(),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Import from Cloud',
                  'Restore from your cloud backup (coming soon).',
                  Icons.cloud,
                  () => _importFromCloud(),
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
                _buildInfoCard(
                  'Enable Auto Backup',
                  'Automatically backup your data to the cloud.',
                  Icons.sync,
                  () => _enableAutoBackup(),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Manual Cloud Backup',
                  'Manually sync your data to the cloud.',
                  Icons.cloud_upload,
                  () => _manualCloudBackup(),
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

  Widget _buildInfoCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
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
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            _buildBackupItem(
              'Full Backup',
              '2024-01-15 14:30',
              '2.3 MB',
              Icons.check_circle,
              Colors.green,
            ),
            _buildBackupItem(
              'Projects Backup',
              '2024-01-14 09:15',
              '1.8 MB',
              Icons.check_circle,
              Colors.green,
            ),
            _buildBackupItem(
              'Cloud Sync',
              '2024-01-13 16:45',
              '2.1 MB',
              Icons.cloud_done,
              Colors.blue,
            ),
            _buildBackupItem(
              'Failed Backup',
              '2024-01-12 11:20',
              '0 MB',
              Icons.error,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupItem(
    String title,
    String date,
    String size,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            size,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _exportAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export All Data'),
        content: const Text('This will create a complete backup of all your data. The backup file will be saved to your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showExportProgress('All Data');
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _exportProjects() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Projects'),
        content: const Text('This will create a backup of all your projects and related data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showExportProgress('Projects');
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _exportClients() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Clients'),
        content: const Text('This will create a backup of all your client information.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showExportProgress('Clients');
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _importFromFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File import feature coming soon!')),
    );
  }

  void _importFromCloud() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cloud import feature coming soon!')),
    );
  }

  void _enableAutoBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Auto backup feature coming soon!')),
    );
  }

  void _manualCloudBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cloud backup feature coming soon!')),
    );
  }

  void _showExportProgress(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exporting $type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Creating backup of your $type...'),
          ],
        ),
      ),
    );

    // Simulate export process
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}
