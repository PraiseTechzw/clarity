import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../services/storage_service.dart';
import '../widgets/sync_animation_widget.dart';
import 'auth/login_screen.dart';
import 'profile_screen.dart';
import 'backup_restore_screen.dart';
import 'notifications_settings_screen.dart';
import 'cloud_sync_screen.dart';
import 'about_screen.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  Map<String, dynamic> _storageInfo = {};

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    final info = await _storageService.getStorageInfo();
    if (mounted) {
      setState(() {
        _storageInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.person, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          tooltip: 'Profile',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Settings Content
          SliverToBoxAdapter(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // User Profile Section
                      _buildEnhancedUserSection(authProvider),
                      const SizedBox(height: 32),

                      // Account Settings
                      _buildEnhancedSectionTitle('Account', Icons.account_circle),
                      const SizedBox(height: 12),
                      _buildEnhancedSettingsCard([
                        _buildEnhancedSettingsTile(
                          icon: Icons.person_outline,
                          title: 'Profile',
                          subtitle: 'Manage your personal information',
                          gradient: [Colors.blue, Colors.blue.shade300],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        _buildEnhancedSettingsTile(
                          icon: Icons.security_outlined,
                          title: 'Security',
                          subtitle: 'Password and security settings',
                          gradient: [Colors.orange, Colors.orange.shade300],
                          onTap: () {
                            _showSecurityDialog();
                          },
                        ),
                        _buildEnhancedSettingsTile(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage notification preferences',
                          gradient: [Colors.purple, Colors.purple.shade300],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsSettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ]),

                      const SizedBox(height: 32),

                      // App Settings
                      _buildEnhancedSectionTitle('App', Icons.settings),
                      const SizedBox(height: 12),
                      _buildEnhancedSettingsCard([
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return _buildEnhancedSettingsTile(
                              icon: Icons.palette_outlined,
                              title: 'Theme',
                              subtitle: themeProvider.getThemeDisplayName(),
                              gradient: [Colors.indigo, Colors.indigo.shade300],
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      themeProvider.getThemeIcon(),
                                      size: 16,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      themeProvider.getThemeDisplayName(),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () => _showThemeDialog(themeProvider),
                            );
                          },
                        ),
                        Consumer<LocaleProvider>(
                          builder: (context, localeProvider, child) {
                            return _buildEnhancedSettingsTile(
                              icon: Icons.language_outlined,
                              title: 'Language',
                              subtitle: localeProvider.selectedLanguage,
                              gradient: [Colors.teal, Colors.teal.shade300],
                              onTap: () => _showLanguageDialog(localeProvider),
                            );
                          },
                        ),
                        Consumer<LocaleProvider>(
                          builder: (context, localeProvider, child) {
                            return _buildEnhancedSettingsTile(
                              icon: Icons.currency_exchange_outlined,
                              title: 'Currency',
                              subtitle: localeProvider.getCurrencyDisplayName(
                                localeProvider.selectedCurrency,
                              ),
                              gradient: [Colors.green, Colors.green.shade300],
                              onTap: () => _showCurrencyDialog(localeProvider),
                            );
                          },
                        ),
                      ]),

                      const SizedBox(height: 32),

                      // Data & Storage
                      _buildEnhancedSectionTitle('Data & Storage', Icons.storage),
                      const SizedBox(height: 12),
                      _buildEnhancedSettingsCard([
                        _buildEnhancedSyncSettingsTile(),
                        _buildEnhancedSettingsTile(
                          icon: Icons.backup_outlined,
                          title: 'Backup & Restore',
                          subtitle: 'Export and import your data',
                          gradient: [Colors.cyan, Colors.cyan.shade300],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const BackupRestoreScreen(),
                              ),
                            );
                          },
                        ),
                        _buildEnhancedSettingsTile(
                          icon: Icons.storage_outlined,
                          title: 'Storage Usage',
                          subtitle: 'Total: ${_storageInfo['total'] ?? '0 B'}',
                          gradient: [Colors.amber, Colors.amber.shade300],
                          onTap: () {
                            _showStorageDialog();
                          },
                        ),
                        _buildEnhancedSettingsTile(
                          icon: Icons.delete_outline,
                          title: 'Clear Cache',
                          subtitle: 'Free up ${_storageInfo['cache'] ?? '0 B'}',
                          gradient: [Colors.red, Colors.red.shade300],
                          onTap: () {
                            _showClearCacheDialog();
                          },
                        ),
                      ]),

                      const SizedBox(height: 32),

                      // Support & Info
                      _buildEnhancedSectionTitle('Support & Info', Icons.help_outline),
                      const SizedBox(height: 12),
                      _buildEnhancedSettingsCard([
                        _buildEnhancedSettingsTile(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'Get help and contact support',
                          gradient: [Colors.lightBlue, Colors.lightBlue.shade300],
                          onTap: () {
                            _showHelpDialog();
                          },
                        ),
                        _buildEnhancedSettingsTile(
                          icon: Icons.bug_report_outlined,
                          title: 'Report a Bug',
                          subtitle: 'Help us improve the app',
                          gradient: [Colors.deepOrange, Colors.deepOrange.shade300],
                          onTap: () {
                            _showBugReportDialog();
                          },
                        ),
                        _buildEnhancedSettingsTile(
                          icon: Icons.info_outline,
                          title: 'About',
                          subtitle: 'App version and information',
                          gradient: [Colors.grey, Colors.grey.shade400],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                      ]),

                      const SizedBox(height: 32),

                      // Authentication Section
                      if (authProvider.isAuthenticated) ...[
                        _buildEnhancedSignOutButton(authProvider),
                        const SizedBox(height: 32),
                      ] else ...[
                        _buildEnhancedSignInSection(),
                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedUserSection(AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.transparent,
                child: Text(
                  authProvider.userName?.isNotEmpty == true
                      ? authProvider.userName![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.userName ?? 'Guest User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: authProvider.isAuthenticated
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: authProvider.isAuthenticated
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      authProvider.userEmail ?? 'Offline Mode',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: authProvider.isAuthenticated
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Edit Profile',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Text(
                authProvider.userName?.isNotEmpty == true
                    ? authProvider.userName![0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.userName ?? 'Guest User',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.userEmail ?? 'Not signed in',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEnhancedSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(child: Column(children: children));
  }

  Widget _buildEnhancedSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing,
                ] else ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildEnhancedSyncSettingsTile() {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return _buildEnhancedSettingsTile(
          icon: Icons.cloud_sync,
          title: 'Cloud Sync',
          subtitle: syncProvider.isSignedIn
              ? syncProvider.isOnline
                  ? 'Synced and online'
                  : 'Offline mode'
              : 'Not signed in',
          gradient: syncProvider.isSignedIn
              ? [Colors.blue, Colors.blue.shade300]
              : [Colors.grey, Colors.grey.shade400],
          trailing: SyncStatusIndicator(
            isSyncing: syncProvider.isSyncing,
            status: syncProvider.syncStatus,
            isOnline: syncProvider.isOnline,
            isSignedIn: syncProvider.isSignedIn,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CloudSyncScreen()),
            );
          },
        );
      },
    );
  }

  Widget _buildSyncSettingsTile() {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return ListTile(
          leading: SyncAnimationWidget(
            isSyncing: syncProvider.isSyncing,
            status: syncProvider.syncStatus,
            size: 24,
            showText: false,
          ),
          title: const Text('Cloud Sync'),
          subtitle: Text(
            syncProvider.isSignedIn
                ? syncProvider.isOnline
                      ? 'Synced and online'
                      : 'Offline mode'
                : 'Not signed in',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SyncStatusIndicator(
                isSyncing: syncProvider.isSyncing,
                status: syncProvider.syncStatus,
                isOnline: syncProvider.isOnline,
                isSignedIn: syncProvider.isSignedIn,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CloudSyncScreen()),
            );
          },
        );
      },
    );
  }

  Widget _buildSignInSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_off,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sign In to Sync',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to sync your data across devices and access cloud backup features.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showSignOutDialog(authProvider),
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Settings'),
        content: const Text(
          'Change password and security settings will be available soon.',
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

  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              subtitle: const Text('Always use light theme'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              subtitle: const Text('Always use dark theme'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              subtitle: const Text('Follow system theme'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: localeProvider.getSupportedCurrencies().map((currency) {
            return RadioListTile<String>(
              title: Text(localeProvider.getCurrencyDisplayName(currency)),
              value: currency,
              groupValue: localeProvider.selectedCurrency,
              onChanged: (String? value) {
                if (value != null) {
                  localeProvider.setCurrency(value);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Currency set to $value')),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStorageItem(
              'Database',
              _storageInfo['database'] ?? '0 B',
              _storageInfo['databaseBytes'] ?? 0,
              _storageInfo['totalBytes'] ?? 1,
            ),
            _buildStorageItem(
              'Cache',
              _storageInfo['cache'] ?? '0 B',
              _storageInfo['cacheBytes'] ?? 0,
              _storageInfo['totalBytes'] ?? 1,
            ),
            _buildStorageItem(
              'Documents',
              _storageInfo['documents'] ?? '0 B',
              _storageInfo['documentsBytes'] ?? 0,
              _storageInfo['totalBytes'] ?? 1,
            ),
            _buildStorageItem(
              'Preferences',
              _storageInfo['preferences'] ?? '0 B',
              _storageInfo['preferencesBytes'] ?? 0,
              _storageInfo['totalBytes'] ?? 1,
            ),
            const Divider(),
            _buildStorageItem(
              'Total',
              _storageInfo['total'] ?? '0 B',
              _storageInfo['totalBytes'] ?? 0,
              _storageInfo['totalBytes'] ?? 1,
              isTotal: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _loadStorageInfo();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(
    String name,
    String size,
    int bytes,
    int totalBytes, {
    bool isTotal = false,
  }) {
    final percentage = totalBytes > 0 ? bytes / totalBytes : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: isTotal
                      ? Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )
                      : Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isTotal
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            size,
            style: isTotal
                ? Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: Text(
          'This will clear all cached data and free up ${_storageInfo['cache'] ?? '0 B'} of storage space. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _storageService.clearCache();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Cache cleared successfully'
                          : 'Failed to clear cache',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                await _loadStorageInfo();
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'For help and support, please contact us at support@clarity.app or visit our help center.',
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

  void _showBugReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const Text(
          'Help us improve Clarity by reporting bugs. Please describe the issue you encountered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report submitted. Thank you!'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: localeProvider.getSupportedLanguages().map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: localeProvider.selectedLanguage,
              onChanged: (String? value) {
                if (value != null) {
                  localeProvider.setLanguage(value);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Language set to $value')),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
