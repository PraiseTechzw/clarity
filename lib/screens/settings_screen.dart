import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: const Text('Profile'),
              subtitle: const Text('Manage your profile information'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile settings coming soon!')),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Preferences Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Theme'),
                  subtitle: const Text('Light / Dark mode'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Theme settings coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: const Text('English'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language settings coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: const Text('Currency'),
                  subtitle: const Text('USD (\$)'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Currency settings coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Notifications Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  subtitle: const Text('Manage notification preferences'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification settings coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Reminders'),
                  subtitle: const Text('Set up project reminders'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminder settings coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Data Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Backup & Restore'),
                  subtitle: const Text('Backup your data'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup functionality coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_sync),
                  title: const Text('Cloud Sync'),
                  subtitle: const Text('Sync across devices'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cloud sync coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // About Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  subtitle: const Text('App version and information'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Clarity',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.dashboard),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  subtitle: const Text('Get help and support'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & support coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
