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
  String? _suggestedPriority;
  String? _suggestedDeadline;
  String? _suggestionReason;
  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadClients();
    _budgetController.addListener(_calculateIntelligentSuggestions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadClients() {
    final provider = context.read<ProjectProvider>();
    setState(() {
      _clients = provider.clients;
    });
  }

  void _calculateIntelligentSuggestions() {
    if (_budgetController.text.isEmpty) return;

    final budget = double.tryParse(_budgetController.text);
    if (budget == null) return;

    final now = DateTime.now();
    final daysUntilDeadline = _selectedDeadline.difference(now).inDays;

    // Calculate priority based on budget and deadline
    Priority suggestedPriority;
    String reason;

    if (budget >= 10000) {
      // High-value project
      if (daysUntilDeadline <= 7) {
        suggestedPriority = Priority.high;
        reason =
            "High-value project (\$${budget.toStringAsFixed(0)}) with urgent deadline (${daysUntilDeadline} days)";
      } else if (daysUntilDeadline <= 30) {
        suggestedPriority = Priority.high;
        reason =
            "High-value project (\$${budget.toStringAsFixed(0)}) with moderate timeline (${daysUntilDeadline} days)";
      } else {
        suggestedPriority = Priority.medium;
        reason =
            "High-value project (\$${budget.toStringAsFixed(0)}) with flexible timeline (${daysUntilDeadline} days)";
      }
    } else if (budget >= 5000) {
      // Medium-value project
      if (daysUntilDeadline <= 3) {
        suggestedPriority = Priority.high;
        reason =
            "Medium-value project (\$${budget.toStringAsFixed(0)}) with urgent deadline (${daysUntilDeadline} days)";
      } else if (daysUntilDeadline <= 14) {
        suggestedPriority = Priority.medium;
        reason =
            "Medium-value project (\$${budget.toStringAsFixed(0)}) with reasonable timeline (${daysUntilDeadline} days)";
      } else {
        suggestedPriority = Priority.medium;
        reason =
            "Medium-value project (\$${budget.toStringAsFixed(0)}) with flexible timeline (${daysUntilDeadline} days)";
      }
    } else {
      // Low-value project
      if (daysUntilDeadline <= 3) {
        suggestedPriority = Priority.medium;
        reason =
            "Small project (\$${budget.toStringAsFixed(0)}) with urgent deadline (${daysUntilDeadline} days)";
      } else if (daysUntilDeadline <= 7) {
        suggestedPriority = Priority.medium;
        reason =
            "Small project (\$${budget.toStringAsFixed(0)}) with short timeline (${daysUntilDeadline} days)";
      } else {
        suggestedPriority = Priority.low;
        reason =
            "Small project (\$${budget.toStringAsFixed(0)}) with flexible timeline (${daysUntilDeadline} days)";
      }
    }

    // Calculate suggested deadline based on budget
    DateTime suggestedDeadline;
    if (budget >= 10000) {
      // High-value projects need more time
      suggestedDeadline = now.add(const Duration(days: 60));
    } else if (budget >= 5000) {
      // Medium-value projects
      suggestedDeadline = now.add(const Duration(days: 30));
    } else {
      // Small projects can be done quickly
      suggestedDeadline = now.add(const Duration(days: 14));
    }

    setState(() {
      _suggestedPriority = suggestedPriority.name.toUpperCase();
      _suggestedDeadline = DateFormat('MMM d, yyyy').format(suggestedDeadline);
      _suggestionReason = reason;
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

            // Intelligent Suggestions
            if (_suggestedPriority != null && _suggestionReason != null)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Suggestions',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.flag,
                                  size: 16,
                                  color: _getPriorityColor(_selectedPriority),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Suggested Priority: $_suggestedPriority',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            if (_suggestedDeadline != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Suggested Deadline: $_suggestedDeadline',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              _suggestionReason!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Apply priority suggestion
                                final priorityMap = {
                                  'HIGH': Priority.high,
                                  'MEDIUM': Priority.medium,
                                  'LOW': Priority.low,
                                };
                                setState(() {
                                  _selectedPriority =
                                      priorityMap[_suggestedPriority] ??
                                      Priority.medium;
                                });
                              },
                              icon: const Icon(Icons.flag, size: 16),
                              label: const Text('Apply Priority'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Apply deadline suggestion
                                final budget = double.tryParse(
                                  _budgetController.text,
                                );
                                if (budget != null) {
                                  DateTime suggestedDeadline;
                                  if (budget >= 10000) {
                                    suggestedDeadline = DateTime.now().add(
                                      const Duration(days: 60),
                                    );
                                  } else if (budget >= 5000) {
                                    suggestedDeadline = DateTime.now().add(
                                      const Duration(days: 30),
                                    );
                                  } else {
                                    suggestedDeadline = DateTime.now().add(
                                      const Duration(days: 14),
                                    );
                                  }
                                  setState(() {
                                    _selectedDeadline = suggestedDeadline;
                                  });
                                }
                              },
                              icon: const Icon(Icons.schedule, size: 16),
                              label: const Text('Apply Deadline'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Apply both suggestions
                            final priorityMap = {
                              'HIGH': Priority.high,
                              'MEDIUM': Priority.medium,
                              'LOW': Priority.low,
                            };
                            final budget = double.tryParse(
                              _budgetController.text,
                            );

                            setState(() {
                              _selectedPriority =
                                  priorityMap[_suggestedPriority] ??
                                  Priority.medium;
                              if (budget != null) {
                                if (budget >= 10000) {
                                  _selectedDeadline = DateTime.now().add(
                                    const Duration(days: 60),
                                  );
                                } else if (budget >= 5000) {
                                  _selectedDeadline = DateTime.now().add(
                                    const Duration(days: 30),
                                  );
                                } else {
                                  _selectedDeadline = DateTime.now().add(
                                    const Duration(days: 14),
                                  );
                                }
                              }
                            });
                          },
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('Apply All Suggestions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Budget
            TextFormField(
              controller: _budgetController,
              decoration: InputDecoration(
                labelText: 'Budget *',
                hintText: 'Enter project budget',
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
                suffixIcon: _suggestedPriority != null
                    ? Icon(
                        Icons.lightbulb,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                helperText: _suggestedPriority != null
                    ? '💡 AI suggestions available!'
                    : 'Enter budget to get intelligent suggestions',
                helperStyle: TextStyle(
                  color: _suggestedPriority != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
      // Recalculate suggestions with new deadline
      _calculateIntelligentSuggestions();
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
