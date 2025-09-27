import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 30));
  Priority _selectedPriority = Priority.medium;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProject,
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
            // Project Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name *',
                hintText: 'Enter project name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Project name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Client Name
            TextFormField(
              controller: _clientController,
              decoration: const InputDecoration(
                labelText: 'Client Name *',
                hintText: 'Enter client name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Client name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Budget
            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Budget *',
                hintText: 'Enter project budget',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Budget is required';
                }
                final budget = double.tryParse(value);
                if (budget == null || budget <= 0) {
                  return 'Please enter a valid budget amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Deadline
            InkWell(
              onTap: _selectDeadline,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Deadline *',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDeadline.day}/${_selectedDeadline.month}/${_selectedDeadline.year}',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority
            DropdownButtonFormField<Priority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority *',
                border: OutlineInputBorder(),
              ),
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(priority.name.toUpperCase()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Optional project notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProject,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Project'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
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

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        clientName: _clientController.text.trim(),
        budget: double.parse(_budgetController.text),
        deadline: _selectedDeadline,
        priority: _selectedPriority,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await context.read<ProjectProvider>().addProject(project);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating project: $e'),
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
