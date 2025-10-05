import 'package:flutter/material.dart';

class BudgetSettingsScreen extends StatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoCategorization = true;
  bool _budgetAlerts = true;
  bool _savingsReminders = true;
  String _currency = 'USD';
  String _budgetPeriod = 'Monthly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildSliverAppBar(context),

          // Settings Sections
          _buildGeneralSettings(context),
          _buildNotificationSettings(context),
          _buildBudgetSettings(context),
          _buildDataSettings(context),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.withOpacity(0.1),
                Colors.blue.withOpacity(0.1),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings, color: Colors.grey[700], size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Budget Settings',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customize your budget experience',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildSettingsSection(context, 'General', Icons.tune, [
          _buildSettingsTile(
            context,
            'Currency',
            _currency,
            Icons.attach_money,
            () => _showCurrencyDialog(context),
          ),
          _buildSettingsTile(
            context,
            'Budget Period',
            _budgetPeriod,
            Icons.calendar_today,
            () => _showBudgetPeriodDialog(context),
          ),
          _buildSettingsTile(
            context,
            'Auto Categorization',
            _autoCategorization ? 'Enabled' : 'Disabled',
            Icons.auto_awesome,
            () => setState(() => _autoCategorization = !_autoCategorization),
            trailing: Switch(
              value: _autoCategorization,
              onChanged: (value) => setState(() => _autoCategorization = value),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildSettingsSection(
          context,
          'Notifications',
          Icons.notifications,
          [
            _buildSettingsTile(
              context,
              'Push Notifications',
              _notificationsEnabled ? 'Enabled' : 'Disabled',
              Icons.notifications_active,
              () => setState(
                () => _notificationsEnabled = !_notificationsEnabled,
              ),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
              ),
            ),
            _buildSettingsTile(
              context,
              'Budget Alerts',
              _budgetAlerts ? 'Enabled' : 'Disabled',
              Icons.warning,
              () => setState(() => _budgetAlerts = !_budgetAlerts),
              trailing: Switch(
                value: _budgetAlerts,
                onChanged: (value) => setState(() => _budgetAlerts = value),
              ),
            ),
            _buildSettingsTile(
              context,
              'Savings Reminders',
              _savingsReminders ? 'Enabled' : 'Disabled',
              Icons.savings,
              () => setState(() => _savingsReminders = !_savingsReminders),
              trailing: Switch(
                value: _savingsReminders,
                onChanged: (value) => setState(() => _savingsReminders = value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSettings(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildSettingsSection(
          context,
          'Budget Management',
          Icons.account_balance_wallet,
          [
            _buildSettingsTile(
              context,
              'Default Budget Categories',
              'Manage',
              Icons.category,
              () => _navigateToCategories(context),
            ),
            _buildSettingsTile(
              context,
              'Budget Templates',
              'View',
              Icons.description,
              () => _navigateToTemplates(context),
            ),
            _buildSettingsTile(
              context,
              'Recurring Transactions',
              'Manage',
              Icons.repeat,
              () => _navigateToRecurring(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSettings(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child:
            _buildSettingsSection(context, 'Data & Privacy', Icons.security, [
              _buildSettingsTile(
                context,
                'Export Data',
                'Download your data',
                Icons.download,
                () => _exportData(context),
              ),
              _buildSettingsTile(
                context,
                'Import Data',
                'Upload from file',
                Icons.upload,
                () => _importData(context),
              ),
              _buildSettingsTile(
                context,
                'Clear All Data',
                'Reset budget data',
                Icons.delete_forever,
                () => _showClearDataDialog(context),
                isDestructive: true,
              ),
            ]),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildSettingsSection(context, 'About', Icons.info, [
          _buildSettingsTile(
            context,
            'Version',
            '1.0.0',
            Icons.info_outline,
            null,
          ),
          _buildSettingsTile(
            context,
            'Privacy Policy',
            'View',
            Icons.privacy_tip,
            () => _openPrivacyPolicy(context),
          ),
          _buildSettingsTile(
            context,
            'Terms of Service',
            'View',
            Icons.description,
            () => _openTermsOfService(context),
          ),
          _buildSettingsTile(
            context,
            'Support',
            'Get help',
            Icons.help,
            () => _openSupport(context),
          ),
        ]),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap, {
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Colors.red
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption(context, 'USD', 'US Dollar'),
            _buildCurrencyOption(context, 'EUR', 'Euro'),
            _buildCurrencyOption(context, 'GBP', 'British Pound'),
            _buildCurrencyOption(context, 'JPY', 'Japanese Yen'),
            _buildCurrencyOption(context, 'CAD', 'Canadian Dollar'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(BuildContext context, String code, String name) {
    return ListTile(
      title: Text(code),
      subtitle: Text(name),
      trailing: _currency == code ? const Icon(Icons.check) : null,
      onTap: () {
        setState(() => _currency = code);
        Navigator.pop(context);
      },
    );
  }

  void _showBudgetPeriodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Budget Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPeriodOption(context, 'Weekly'),
            _buildPeriodOption(context, 'Monthly'),
            _buildPeriodOption(context, 'Quarterly'),
            _buildPeriodOption(context, 'Yearly'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodOption(BuildContext context, String period) {
    return ListTile(
      title: Text(period),
      trailing: _budgetPeriod == period ? const Icon(Icons.check) : null,
      onTap: () {
        setState(() => _budgetPeriod = period);
        Navigator.pop(context);
      },
    );
  }

  void _navigateToCategories(BuildContext context) {
    // Navigate to categories management
  }

  void _navigateToTemplates(BuildContext context) {
    // Navigate to budget templates
  }

  void _navigateToRecurring(BuildContext context) {
    // Navigate to recurring transactions
  }

  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Your budget data will be exported as a CSV file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement export functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data exported successfully')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _importData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('Select a CSV file to import your budget data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement import functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data imported successfully')),
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your budget data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement clear data functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('All data cleared')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy(BuildContext context) {
    // Open privacy policy
  }

  void _openTermsOfService(BuildContext context) {
    // Open terms of service
  }

  void _openSupport(BuildContext context) {
    // Open support
  }
}
