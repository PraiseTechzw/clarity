import 'package:flutter/material.dart';
import '../models/project.dart';

class EditPaymentScreen extends StatefulWidget {
  final Payment payment;
  final Function(Payment) onPaymentUpdated;

  const EditPaymentScreen({
    super.key,
    required this.payment,
    required this.onPaymentUpdated,
  });

  @override
  State<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  PaymentStatus _selectedStatus = PaymentStatus.paid;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.payment.amount.toString();
    _referenceController.text = widget.payment.reference ?? '';
    _notesController.text = widget.payment.notes ?? '';
    _selectedDate = widget.payment.date;
    _selectedStatus = widget.payment.status;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Payment'),
        actions: [
          TextButton(onPressed: _savePayment, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter payment amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Payment Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<PaymentStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: PaymentStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_getStatusText(status)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (status) {
                  setState(() {
                    _selectedStatus = status!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Reference
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference',
                  hintText: 'Enter payment reference (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Enter payment notes (optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textAlignVertical: TextAlignVertical.top,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.outstanding:
        return Colors.red;
      case PaymentStatus.partiallyPaid:
        return Colors.orange;
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.outstanding:
        return 'Outstanding';
      case PaymentStatus.partiallyPaid:
        return 'Partially Paid';
    }
  }

  void _savePayment() {
    if (_formKey.currentState!.validate()) {
      final updatedPayment = widget.payment.copyWith(
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        status: _selectedStatus,
        reference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      widget.onPaymentUpdated(updatedPayment);
      Navigator.of(context).pop();
    }
  }
}
