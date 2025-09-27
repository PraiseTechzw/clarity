import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<QuickNote> _notes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    // For now, we'll use a simple in-memory list
    // In a real app, this would be stored in a database
    setState(() {
      _notes = [
        QuickNote(
          id: '1',
          title: 'Meeting Notes',
          content: 'Discuss project requirements with client',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        QuickNote(
          id: '2',
          title: 'Ideas for New Feature',
          content: 'Add dark mode support and better analytics',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _notes.where((note) {
      if (_searchQuery.isEmpty) return true;
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (note.content != null &&
              note.content!.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddNote,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Notes List
          Expanded(
            child: filteredNotes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            note.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: note.content != null
                              ? Text(
                                  note.content!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
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
                          onTap: () => _viewNote(note),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
            _searchQuery.isEmpty ? 'No Notes Yet' : 'No Notes Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Add quick notes and ideas'
                : 'Try adjusting your search terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddNote,
              icon: const Icon(Icons.add),
              label: const Text('Add First Note'),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToAddNote() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddQuickNoteScreen(
          onNoteAdded: (note) {
            setState(() {
              _notes = [note, ..._notes];
            });
          },
        ),
      ),
    );
  }

  void _viewNote(QuickNote note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuickNoteDetailScreen(
          note: note,
          onNoteUpdated: (updatedNote) {
            setState(() {
              final index = _notes.indexWhere((n) => n.id == updatedNote.id);
              if (index != -1) {
                _notes[index] = updatedNote;
              }
            });
          },
          onNoteDeleted: () {
            setState(() {
              _notes = _notes.where((n) => n.id != note.id).toList();
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _editNote(QuickNote note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddQuickNoteScreen(
          note: note,
          onNoteAdded: (updatedNote) {
            setState(() {
              final index = _notes.indexWhere((n) => n.id == updatedNote.id);
              if (index != -1) {
                _notes[index] = updatedNote;
              }
            });
          },
        ),
      ),
    );
  }

  void _deleteNote(QuickNote note) {
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
                _notes = _notes.where((n) => n.id != note.id).toList();
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class QuickNote {
  final String id;
  final String title;
  final String? content;
  final DateTime createdAt;

  QuickNote({
    required this.id,
    required this.title,
    this.content,
    required this.createdAt,
  });

  QuickNote copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return QuickNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AddQuickNoteScreen extends StatefulWidget {
  final QuickNote? note;
  final Function(QuickNote) onNoteAdded;

  const AddQuickNoteScreen({super.key, this.note, required this.onNoteAdded});

  @override
  State<AddQuickNoteScreen> createState() => _AddQuickNoteScreenState();
}

class _AddQuickNoteScreenState extends State<AddQuickNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content ?? '';
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
          ? QuickNote(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text.trim(),
              content: _contentController.text.trim().isEmpty
                  ? null
                  : _contentController.text.trim(),
              createdAt: DateTime.now(),
            )
          : widget.note!.copyWith(
              title: _titleController.text.trim(),
              content: _contentController.text.trim().isEmpty
                  ? null
                  : _contentController.text.trim(),
            );

      widget.onNoteAdded(note);
      Navigator.of(context).pop();
    }
  }
}

class QuickNoteDetailScreen extends StatelessWidget {
  final QuickNote note;
  final Function(QuickNote) onNoteUpdated;
  final VoidCallback onNoteDeleted;

  const QuickNoteDetailScreen({
    super.key,
    required this.note,
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
            if (note.content != null) ...[
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
                    note.content!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Text(
                    'No content available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _editNote(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddQuickNoteScreen(note: note, onNoteAdded: onNoteUpdated),
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
