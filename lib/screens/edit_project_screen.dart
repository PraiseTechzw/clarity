import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';

class EditProjectScreen extends StatefulWidget {
  final Project project;
  final Function(Project) onProjectUpdated;

  const EditProjectScreen({
    super.key,
    required this.project,
    required this.onProjectUpdated,
  });

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 30));
  Priority _selectedPriority = Priority.medium;
  List<Client> _clients = [];
  Client? _selectedClient;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadClients();
  }

  void _initializeForm() {
    _nameController.text = widget.project.name;
    _clientController.text = widget.project.clientName;
    _budgetController.text = widget.project.budget.toString();
    _notesController.text = widget.project.notes ?? '';
    _selectedDeadline = widget.project.deadline;
    _selectedPriority = widget.project.priority;
  }

  void _loadClients() {
    final provider = context.read<ProjectProvider>();
    setState(() {
      _clients = provider.clients;
      _selectedClient = _clients.firstWhere(
        (client) => client.name == widget.project.clientName,
        orElse: () => _clients.isNotEmpty
            ? _clients.first
            : Client(
                id: '1',
                name: widget.project.clientName,
                createdAt: DateTime.now(),
              ),
      );
    });
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        actions: [
          TextButton(onPressed: _saveProject, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'Enter project name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Client Selection
              DropdownButtonFormField<Client>(
                value: _selectedClient,
                decoration: const InputDecoration(
                  labelText: 'Client',
                  border: OutlineInputBorder(),
                ),
                items: _clients.map((client) {
                  return DropdownMenuItem(
                    value: client,
                    child: Text(client.name),
                  );
                }).toList(),
                onChanged: (client) {
                  setState(() {
                    _selectedClient = client;
                    _clientController.text = client?.name ?? '';
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a client';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Budget
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget',
                  hintText: 'Enter project budget',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a budget';
                  }
                  final budget = double.tryParse(value);
                  if (budget == null || budget <= 0) {
                    return 'Please enter a valid budget';
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
                    labelText: 'Deadline',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDeadline.day}/${_selectedDeadline.month}/${_selectedDeadline.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Priority
              DropdownButtonFormField<Priority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
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
                onChanged: (priority) {
                  setState(() {
                    _selectedPriority = priority!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Enter project notes (optional)',
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

  void _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDeadline = date;
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

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      final updatedProject = widget.project.copyWith(
        name: _nameController.text.trim(),
        clientName: _selectedClient?.name ?? _clientController.text.trim(),
        budget: double.parse(_budgetController.text),
        deadline: _selectedDeadline,
        priority: _selectedPriority,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      widget.onProjectUpdated(updatedProject);
      Navigator.of(context).pop();
    }
  }
}
