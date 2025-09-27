import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../widgets/phase_card.dart';
import 'add_phase_screen.dart';
import 'add_task_screen.dart';
import 'edit_phase_screen.dart';

class PhasesTasksScreen extends StatefulWidget {
  final Project project;

  const PhasesTasksScreen({super.key, required this.project});

  @override
  State<PhasesTasksScreen> createState() => _PhasesTasksScreenState();
}

class _PhasesTasksScreenState extends State<PhasesTasksScreen> {
  late Project _currentProject;

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentProject.phases.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentProject.phases.length,
              itemBuilder: (context, index) {
                final phase = _currentProject.phases[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PhaseCard(
                    phase: phase,
                    onAddTask: () => _navigateToAddTask(phase),
                    onEditPhase: () => _editPhase(phase),
                    onDeletePhase: () => _deletePhase(phase),
                    onTaskToggle: (task) => _toggleTask(phase, task),
                    onEditTask: (task) => _editTask(phase, task),
                    onDeleteTask: (task) => _deleteTask(phase, task),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPhase,
        icon: const Icon(Icons.add),
        label: const Text('Add Phase'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Phases Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Break down your project into manageable phases',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddPhase,
            icon: const Icon(Icons.add),
            label: const Text('Create First Phase'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddPhase() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPhaseScreen(
          project: _currentProject,
          onPhaseAdded: (phase) {
            setState(() {
              _currentProject = _currentProject.copyWith(
                phases: [..._currentProject.phases, phase],
              );
            });
            _updateProject();
          },
        ),
      ),
    );
  }

  void _navigateToAddTask(Phase phase) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          phase: phase,
          onTaskAdded: (task) {
            setState(() {
              final updatedPhase = phase.copyWith(
                tasks: [...phase.tasks, task],
              );
              final phaseIndex = _currentProject.phases.indexWhere(
                (p) => p.id == phase.id,
              );
              final updatedPhases = List<Phase>.from(_currentProject.phases);
              updatedPhases[phaseIndex] = updatedPhase;
              _currentProject = _currentProject.copyWith(phases: updatedPhases);
            });
            _updateProject();
          },
        ),
      ),
    );
  }

  void _editPhase(Phase phase) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPhaseScreen(
          phase: phase,
          onPhaseUpdated: (updatedPhase) {
            setState(() {
              final phaseIndex = _currentProject.phases.indexWhere(
                (p) => p.id == phase.id,
              );
              final updatedPhases = List<Phase>.from(_currentProject.phases);
              updatedPhases[phaseIndex] = updatedPhase;
              _currentProject = _currentProject.copyWith(phases: updatedPhases);
            });
            _updateProject();
          },
        ),
      ),
    );
  }

  void _deletePhase(Phase phase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Phase'),
        content: Text(
          'Are you sure you want to delete "${phase.name}"? This will also delete all tasks in this phase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentProject = _currentProject.copyWith(
                  phases: _currentProject.phases
                      .where((p) => p.id != phase.id)
                      .toList(),
                );
              });
              _updateProject();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleTask(Phase phase, Task task) {
    setState(() {
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );
      final taskIndex = phase.tasks.indexWhere((t) => t.id == task.id);
      final updatedTasks = List<Task>.from(phase.tasks);
      updatedTasks[taskIndex] = updatedTask;

      final updatedPhase = phase.copyWith(tasks: updatedTasks);
      final phaseIndex = _currentProject.phases.indexWhere(
        (p) => p.id == phase.id,
      );
      final updatedPhases = List<Phase>.from(_currentProject.phases);
      updatedPhases[phaseIndex] = updatedPhase;

      _currentProject = _currentProject.copyWith(phases: updatedPhases);
    });
    _updateProject();
  }

  void _editTask(Phase phase, Task task) {
    // TODO: Implement edit task functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit task functionality coming soon!')),
    );
  }

  void _deleteTask(Phase phase, Task task) {
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
              setState(() {
                final updatedTasks = phase.tasks
                    .where((t) => t.id != task.id)
                    .toList();
                final updatedPhase = phase.copyWith(tasks: updatedTasks);
                final phaseIndex = _currentProject.phases.indexWhere(
                  (p) => p.id == phase.id,
                );
                final updatedPhases = List<Phase>.from(_currentProject.phases);
                updatedPhases[phaseIndex] = updatedPhase;
                _currentProject = _currentProject.copyWith(
                  phases: updatedPhases,
                );
              });
              _updateProject();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateProject() {
    context.read<ProjectProvider>().updateProject(_currentProject);
  }
}
