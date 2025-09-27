import 'package:flutter/material.dart';
import '../models/project.dart';

class EditPhaseScreen extends StatefulWidget {
  final Phase phase;
  final Function(Phase) onPhaseUpdated;

  const EditPhaseScreen({
    super.key,
    required this.phase,
    required this.onPhaseUpdated,
  });

  @override
  State<EditPhaseScreen> createState() => _EditPhaseScreenState();
}

class _EditPhaseScreenState extends State<EditPhaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.phase.name;
    _descriptionController.text = widget.phase.description ?? '';
  }

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
        title: const Text('Edit Phase'),
        actions: [TextButton(onPressed: _savePhase, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Phase Name',
                  hintText: 'Enter phase name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a phase name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter phase description (optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textAlignVertical: TextAlignVertical.top,
              ),
              const SizedBox(height: 24),
              // Tasks Section
              Text(
                'Tasks (${widget.phase.tasks.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: widget.phase.tasks.isEmpty
                    ? _buildEmptyTasks()
                    : ListView.builder(
                        itemCount: widget.phase.tasks.length,
                        itemBuilder: (context, index) {
                          final task = widget.phase.tasks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) {
                                  setState(() {
                                    // Note: This is a read-only view, changes should be handled by parent
                                    // For now, just show a message that editing is not available here
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please use the main phases screen to edit tasks',
                                        ),
                                      ),
                                    );
                                  });
                                },
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: task.dueDate != null
                                  ? Text(
                                      'Due: ${_formatDate(task.dueDate!)}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    )
                                  : null,
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editTask(task);
                                  } else if (value == 'delete') {
                                    _deleteTask(task);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTasks() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text('No Tasks Yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Add tasks to this phase',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _editTask(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(
          task: task,
          onTaskUpdated: (updatedTask) {
            // Note: This is a read-only view, changes should be handled by parent
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please use the main phases screen to edit tasks',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Note: This is a read-only view, changes should be handled by parent
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please use the main phases screen to delete tasks',
                  ),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _savePhase() {
    if (_formKey.currentState!.validate()) {
      final updatedPhase = widget.phase.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      widget.onPhaseUpdated(updatedPhase);
      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;

  const EditTaskScreen({
    super.key,
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDueDate;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task.title;
    _descriptionController.text = widget.task.description ?? '';
    _selectedDueDate = widget.task.dueDate;
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [TextButton(onPressed: _saveTask, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description (optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textAlignVertical: TextAlignVertical.top,
              ),
              const SizedBox(height: 16),
              // Due Date
              InkWell(
                onTap: _selectDueDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDueDate != null
                        ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                        : 'No due date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Completion Status
              CheckboxListTile(
                title: const Text('Completed'),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueDate: _selectedDueDate,
        isCompleted: _isCompleted,
      );

      widget.onTaskUpdated(updatedTask);
      Navigator.of(context).pop();
    }
  }
}
