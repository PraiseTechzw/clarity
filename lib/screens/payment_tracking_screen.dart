import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/payment_item.dart';
import 'add_payment_screen.dart';

class PaymentTrackingScreen extends StatefulWidget {
  final Project project;

  const PaymentTrackingScreen({super.key, required this.project});

  @override
  State<PaymentTrackingScreen> createState() => _PaymentTrackingScreenState();
}

class _PaymentTrackingScreenState extends State<PaymentTrackingScreen> {
  late Project _currentProject;

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // Payment Summary
          PaymentSummaryCard(project: _currentProject),

          // Payments List
          Expanded(
            child: _currentProject.payments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _currentProject.payments.length,
                    itemBuilder: (context, index) {
                      final payment = _currentProject.payments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PaymentItem(
                          payment: payment,
                          onEdit: () => _editPayment(payment),
                          onDelete: () => _deletePayment(payment),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPayment,
        icon: const Icon(Icons.add),
        label: const Text('Add Payment'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Payments Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking payments for this project',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddPayment,
            icon: const Icon(Icons.add),
            label: const Text('Add First Payment'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPaymentScreen(
          project: _currentProject,
          onPaymentAdded: (payment) {
            setState(() {
              _currentProject = _currentProject.copyWith(
                payments: [..._currentProject.payments, payment],
              );
            });
            _updateProject();
          },
        ),
      ),
    );
  }

  void _editPayment(Payment payment) {
    // TODO: Implement edit payment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit payment functionality coming soon!')),
    );
  }

  void _deletePayment(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text(
          'Are you sure you want to delete this payment of \$${payment.amount.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentProject = _currentProject.copyWith(
                  payments: _currentProject.payments
                      .where((p) => p.id != payment.id)
                      .toList(),
                );
              });
              _updateProject();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateProject() {
    context.read<ProjectProvider>().updateProject(_currentProject);
  }
}
