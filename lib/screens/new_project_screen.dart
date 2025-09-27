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
          if (_currentStep == 4) // Show save button only on last step
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
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(context),

          // Step Content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildStep1(), // Project Basics
                  _buildStep2(), // Client Selection
                  _buildStep3(), // Budget & Timeline
                  _buildStep4(), // Priority & AI Suggestions
                  _buildStep5(), // Review & Create
                ],
              ),
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${_currentStep + 1} of 5',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${((_currentStep + 1) / 5 * 100).round()}% Complete',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index <= _currentStep
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            context,
            'Project Basics',
            'Let\'s start with the essential project information',
            Icons.description,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Project Name *',
              hintText: 'Enter project name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.work),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Project name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Project Description',
              hintText: 'Brief description of the project...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textAlignVertical: TextAlignVertical.top,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            context,
            'Client Selection',
            'Choose an existing client or add a new one',
            Icons.person,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        prefixIcon: Icon(Icons.people),
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
                        prefixIcon: Icon(Icons.person_add),
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
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            context,
            'Budget & Timeline',
            'Set the project budget and deadline',
            Icons.attach_money,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _budgetController,
            decoration: InputDecoration(
              labelText: 'Project Budget *',
              hintText: 'Enter project budget',
              prefixText: '\$ ',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.account_balance_wallet),
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          InkWell(
            onTap: _selectDeadline,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Project Deadline *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
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
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${_selectedDeadline.difference(DateTime.now()).inDays} days from now',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              _selectedDeadline.isBefore(
                                DateTime.now().add(const Duration(days: 7)),
                              )
                              ? Colors.red
                              : _selectedDeadline.isBefore(
                                  DateTime.now().add(const Duration(days: 30)),
                                )
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            context,
            'Priority & AI Suggestions',
            'Set project priority and review AI recommendations',
            Icons.flag,
          ),
          const SizedBox(height: 24),

          // AI Suggestions Card
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
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Suggested Deadline: $_suggestedDeadline',
                                  style: Theme.of(context).textTheme.bodyMedium
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
                        label: const Text('Apply AI Suggestions'),
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

          const SizedBox(height: 24),

          // Priority Selection
          DropdownButtonFormField<Priority>(
            value: _selectedPriority,
            decoration: const InputDecoration(
              labelText: 'Priority Level *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag),
            ),
            items: Priority.values.map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Tooltip(
                  message: _getPriorityDescription(priority),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      Flexible(
                        child: Text(
                          priority.name.toUpperCase(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
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
    );
  }

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            context,
            'Review & Create',
            'Review your project details before creating',
            Icons.check_circle,
          ),
          const SizedBox(height: 24),

          // Project Summary Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Project Name', _nameController.text),
                  _buildSummaryRow(
                    'Client',
                    _isNewClient
                        ? _clientController.text
                        : _selectedClient?.name ?? '',
                  ),
                  _buildSummaryRow('Budget', '\$${_budgetController.text}'),
                  _buildSummaryRow(
                    'Deadline',
                    DateFormat('MMM d, yyyy').format(_selectedDeadline),
                  ),
                  _buildSummaryRow(
                    'Priority',
                    _selectedPriority.name.toUpperCase(),
                  ),
                  if (_notesController.text.isNotEmpty)
                    _buildSummaryRow('Description', _notesController.text),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Create Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.rocket_launch),
              label: Text(
                _isLoading ? 'Creating Project...' : 'Create Project',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _currentStep < 4
                  ? () {
                      if (_validateCurrentStep()) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  : null,
              icon: Icon(_currentStep == 4 ? Icons.check : Icons.arrow_forward),
              label: Text(_currentStep == 4 ? 'Complete' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Project Basics
        return _nameController.text.trim().isNotEmpty;
      case 1: // Client Selection
        return _isNewClient
            ? _clientController.text.trim().isNotEmpty
            : _selectedClient != null;
      case 2: // Budget & Timeline
        return _budgetController.text.trim().isNotEmpty &&
            double.tryParse(_budgetController.text) != null;
      case 3: // Priority
        return true; // Priority is always set
      case 4: // Review
        return true; // All validation done
      default:
        return false;
    }
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
        return 'Urgent';
      case Priority.medium:
        return 'Important';
      case Priority.low:
        return 'Normal';
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Success!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isNewClient
                    ? 'Project "${_nameController.text.trim()}" and client have been created successfully!'
                    : 'Project "${_nameController.text.trim()}" has been created successfully!',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your project is ready to go!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.done),
              label: const Text('Great!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
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
        // Show success dialog first
        await _showSuccessDialog();

        // Then navigate back
        Navigator.of(context).pop();

        // Show snackbar confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isNewClient
                        ? 'Project "${_nameController.text.trim()}" and client created successfully!'
                        : 'Project "${_nameController.text.trim()}" created successfully!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
