import 'package:flutter/material.dart';
import '../models/project.dart';

class AddPhaseScreen extends StatefulWidget {
  final Project project;
  final Function(Phase) onPhaseAdded;

  const AddPhaseScreen({
    super.key,
    required this.project,
    required this.onPhaseAdded,
  });

  @override
  State<AddPhaseScreen> createState() => _AddPhaseScreenState();
}

class _AddPhaseScreenState extends State<AddPhaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Phase'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePhase,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Phase Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Phase Name *',
                hintText: 'e.g., Design, Development, Testing',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phase name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional description of this phase',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Due Date
            InkWell(
              onTap: _selectDueDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due Date (Optional)',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDueDate != null
                          ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                          : 'Select due date',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _selectedDueDate != null
                            ? null
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePhase,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Phase'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _savePhase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final phase = Phase(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueDate: _selectedDueDate,
      );

      widget.onPhaseAdded(phase);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phase created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating phase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
