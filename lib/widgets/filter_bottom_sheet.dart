import 'package:flutter/material.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import 'package:provider/provider.dart';

class FilterBottomSheet extends StatefulWidget {
  final Priority? selectedPriority;
  final PaymentStatus? selectedPaymentStatus;
  final String? selectedClient;
  final Function(Priority?, PaymentStatus?, String?) onFiltersChanged;

  const FilterBottomSheet({
    super.key,
    this.selectedPriority,
    this.selectedPaymentStatus,
    this.selectedClient,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  Priority? _selectedPriority;
  PaymentStatus? _selectedPaymentStatus;
  String? _selectedClient;

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.selectedPriority;
    _selectedPaymentStatus = widget.selectedPaymentStatus;
    _selectedClient = widget.selectedClient;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filter Projects',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Priority Filter
          Text(
            'Priority',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Priority.values.map((priority) {
              final isSelected = _selectedPriority == priority;
              return FilterChip(
                label: Text(priority.name.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = selected ? priority : null;
                  });
                },
                selectedColor: _getPriorityColor(priority).withOpacity(0.2),
                checkmarkColor: _getPriorityColor(priority),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Payment Status Filter
          Text(
            'Payment Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: PaymentStatus.values.map((status) {
              final isSelected = _selectedPaymentStatus == status;
              return FilterChip(
                label: Text(_getPaymentStatusText(status)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPaymentStatus = selected ? status : null;
                  });
                },
                selectedColor: _getPaymentStatusColor(status).withOpacity(0.2),
                checkmarkColor: _getPaymentStatusColor(status),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Client Filter
          Text(
            'Client',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<ProjectProvider>(
            builder: (context, provider, child) {
              final clients =
                  provider.projects
                      .map((project) => project.clientName)
                      .toSet()
                      .toList()
                    ..sort();

              return Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All Clients'),
                    selected: _selectedClient == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedClient = null;
                      });
                    },
                  ),
                  ...clients.map((client) {
                    final isSelected = _selectedClient == client;
                    return FilterChip(
                      label: Text(client),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedClient = selected ? client : null;
                        });
                      },
                    );
                  }),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedPriority = null;
      _selectedPaymentStatus = null;
      _selectedClient = null;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      _selectedPriority,
      _selectedPaymentStatus,
      _selectedClient,
    );
    Navigator.of(context).pop();
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.partiallyPaid:
        return 'Partial';
      case PaymentStatus.outstanding:
        return 'Outstanding';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.partiallyPaid:
        return Colors.orange;
      case PaymentStatus.outstanding:
        return Colors.red;
    }
  }
}
