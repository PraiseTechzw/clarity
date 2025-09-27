import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  List<Client> _clients = [];
  Client? _selectedClient;
  bool _isNewClient = false;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadClients() {
    final provider = context.read<ProjectProvider>();
    setState(() {
      _clients = provider.clients;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('New Project'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveProject,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: _isLoading
                ? const Text('Creating...')
                : const Text('Create'),
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

            // Client Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Client Selection',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Existing Client'),
                            value: false,
                            groupValue: _isNewClient,
                            onChanged: (value) {
                              setState(() {
                                _isNewClient = value!;
                                if (!_isNewClient) {
                                  _clientController.clear();
                                }
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('New Client'),
                            value: true,
                            groupValue: _isNewClient,
                            onChanged: (value) {
                              setState(() {
                                _isNewClient = value!;
                                if (_isNewClient) {
                                  _selectedClient = null;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_isNewClient) ...[
                      DropdownButtonFormField<Client>(
                        value: _selectedClient,
                        decoration: const InputDecoration(
                          labelText: 'Select Client *',
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
                          });
                        },
                        validator: (value) {
                          if (!_isNewClient && value == null) {
                            return 'Please select a client';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _clientController,
                        decoration: const InputDecoration(
                          labelText: 'New Client Name *',
                          hintText: 'Enter client name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_isNewClient &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Client name is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Project Timeline',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDeadline,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Project Deadline *',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'EEEE, MMMM d, yyyy',
                                  ).format(_selectedDeadline),
                                  style: theme.textTheme.bodyLarge,
                                ),
                                Text(
                                  '${_selectedDeadline.difference(DateTime.now()).inDays} days from now',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        _selectedDeadline.isBefore(
                                          DateTime.now().add(
                                            const Duration(days: 7),
                                          ),
                                        )
                                        ? Colors.red
                                        : _selectedDeadline.isBefore(
                                            DateTime.now().add(
                                              const Duration(days: 30),
                                            ),
                                          )
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority and Project Type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Project Priority & Type',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Priority>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority Level *',
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
                              const SizedBox(width: 8),
                              Text(
                                _getPriorityDescription(priority),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes and Additional Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Project Details',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Project Notes',
                        hintText:
                            'Add any additional project details, requirements, or notes...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.rocket_launch, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Creating Project...' : 'Create Project',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
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

  String _getPriorityDescription(Priority priority) {
    switch (priority) {
      case Priority.high:
        return '(Urgent - Complete ASAP)';
      case Priority.medium:
        return '(Normal - Standard timeline)';
      case Priority.low:
        return '(Low - Flexible timeline)';
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
      String clientName;

      // Handle client creation if it's a new client
      if (_isNewClient) {
        clientName = _clientController.text.trim();

        // Create new client
        final newClient = Client(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: clientName,
          createdAt: DateTime.now(),
        );

        await context.read<ProjectProvider>().addClient(newClient);
      } else {
        clientName = _selectedClient?.name ?? '';
      }

      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        clientName: clientName,
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isNewClient
                        ? 'Project and client created successfully!'
                        : 'Project created successfully!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error creating project: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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
