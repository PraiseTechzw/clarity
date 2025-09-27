import 'package:flutter/material.dart';
import '../models/project.dart';
import 'task_item.dart';

class PhaseCard extends StatefulWidget {
  final Phase phase;
  final VoidCallback onAddTask;
  final VoidCallback onEditPhase;
  final VoidCallback onDeletePhase;
  final Function(Task) onTaskToggle;
  final Function(Task) onEditTask;
  final Function(Task) onDeleteTask;

  const PhaseCard({
    super.key,
    required this.phase,
    required this.onAddTask,
    required this.onEditPhase,
    required this.onDeletePhase,
    required this.onTaskToggle,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  @override
  State<PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<PhaseCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Column(
        children: [
          // Phase Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.phase.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.phase.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.phase.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Progress',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: widget.phase.progressPercentage / 100,
                                backgroundColor: colorScheme.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.phase.progressPercentage.toStringAsFixed(0)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.phase.tasks.where((t) => t.isCompleted).length} of ${widget.phase.tasks.length} tasks completed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: widget.onAddTask,
                        tooltip: 'Add Task',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: widget.onEditPhase,
                        tooltip: 'Edit Phase',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: widget.onDeletePhase,
                        tooltip: 'Delete Phase',
                      ),
                      Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tasks List
          if (_isExpanded) ...[
            if (widget.phase.tasks.isNotEmpty) ...[
              const Divider(height: 1),
              ...widget.phase.tasks.map(
                (task) => TaskItem(
                  task: task,
                  onToggle: () => widget.onTaskToggle(task),
                  onEdit: () => widget.onEditTask(task),
                  onDelete: () => widget.onDeleteTask(task),
                ),
              ),
            ] else ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No tasks yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: widget.onAddTask,
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Task'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
