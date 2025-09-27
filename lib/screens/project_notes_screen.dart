import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectNotesScreen extends StatelessWidget {
  final Project project;

  const ProjectNotesScreen({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Project Notes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Keep notes and ideas for this project',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project notes functionality coming soon!')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Note'),
            ),
          ],
        ),
      ),
    );
  }
}
