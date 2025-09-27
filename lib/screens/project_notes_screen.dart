import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';

class ProjectNotesScreen extends StatefulWidget {
  final Project project;

  const ProjectNotesScreen({super.key, required this.project});

  @override
  State<ProjectNotesScreen> createState() => _ProjectNotesScreenState();
}

class _ProjectNotesScreenState extends State<ProjectNotesScreen> {
  late Project _currentProject;

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddNote,
          ),
        ],
      ),
      body: _currentProject.projectNotes.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentProject.projectNotes.length,
              itemBuilder: (context, index) {
                final note = _currentProject.projectNotes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      note.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editNote(note);
                        } else if (value == 'delete') {
                          _deleteNote(note);
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
                              Icon(Icons.delete, size: 20, color: Colors.red),
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
                    onTap: () => _viewNote(note),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Notes Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add notes and ideas for this project',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddNote,
            icon: const Icon(Icons.add),
            label: const Text('Add First Note'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddNote() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(
          project: _currentProject,
          onNoteAdded: (note) {
            setState(() {
              _currentProject = _currentProject.copyWith(
                projectNotes: [..._currentProject.projectNotes, note],
              );
            });
            _updateProject();
          },
        ),
      ),
    );
  }

  void _viewNote(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(
          note: note,
          project: _currentProject,
          onNoteUpdated: (updatedNote) {
            setState(() {
              final updatedNotes = _currentProject.projectNotes.map((n) {
                return n.id == updatedNote.id ? updatedNote : n;
              }).toList();
              _currentProject = _currentProject.copyWith(
                projectNotes: updatedNotes,
              );
            });
            _updateProject();
          },
          onNoteDeleted: () {
            setState(() {
              _currentProject = _currentProject.copyWith(
                projectNotes: _currentProject.projectNotes
                    .where((n) => n.id != note.id)
                    .toList(),
              );
            });
            _updateProject();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _editNote(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(
          project: _currentProject,
          note: note,
          onNoteAdded: (updatedNote) {
            setState(() {
              final updatedNotes = _currentProject.projectNotes.map((n) {
                return n.id == updatedNote.id ? updatedNote : n;
              }).toList();
              _currentProject = _currentProject.copyWith(
                projectNotes: updatedNotes,
              );
            });
            _updateProject();
          },
        ),
      ),
    );
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
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
                  projectNotes: _currentProject.projectNotes
                      .where((n) => n.id != note.id)
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

  void _updateProject() {
    context.read<ProjectProvider>().updateProject(_currentProject);
  }
}

class AddNoteScreen extends StatefulWidget {
  final Project project;
  final Note? note;
  final Function(Note) onNoteAdded;

  const AddNoteScreen({
    super.key,
    required this.project,
    this.note,
    required this.onNoteAdded,
  });

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        actions: [TextButton(onPressed: _saveNote, child: const Text('Save'))],
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
                  labelText: 'Note Title',
                  hintText: 'Enter a title for your note',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Enter your note content...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final note = widget.note == null
          ? Note(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text.trim(),
              content: _contentController.text.trim().isEmpty
                  ? ''
                  : _contentController.text.trim(),
              createdAt: DateTime.now(),
            )
          : widget.note!.copyWith(
              title: _titleController.text.trim(),
              content: _contentController.text.trim().isEmpty
                  ? ''
                  : _contentController.text.trim(),
            );

      widget.onNoteAdded(note);
      Navigator.of(context).pop();
    }
  }
}

class NoteDetailScreen extends StatelessWidget {
  final Note note;
  final Project project;
  final Function(Note) onNoteUpdated;
  final VoidCallback onNoteDeleted;

  const NoteDetailScreen({
    super.key,
    required this.note,
    required this.project,
    required this.onNoteUpdated,
    required this.onNoteDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editNote(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteNote(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(note.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Content:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editNote(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(
          project: project,
          note: note,
          onNoteAdded: onNoteUpdated,
        ),
      ),
    );
  }

  void _deleteNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onNoteDeleted();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
