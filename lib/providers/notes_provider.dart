import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/notes_screen.dart';
import '../services/database_helper.dart';

class NotesProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<QuickNote> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<QuickNote> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load notes from database
  Future<void> loadNotes() async {
    _setLoading(true);
    try {
      // For now, we'll use the sample data but in a real app,
      // this would load from database
      _notes = await _getSampleNotes();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Add a new note
  Future<void> addNote(QuickNote note) async {
    try {
      _notes.add(note);
      notifyListeners();
      // In a real app, save to database here
      // await _databaseHelper.insertNote(note);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update an existing note
  Future<void> updateNote(QuickNote note) async {
    try {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
        notifyListeners();
        // In a real app, update in database here
        // await _databaseHelper.updateNote(note);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      _notes.removeWhere((note) => note.id == noteId);
      notifyListeners();
      // In a real app, delete from database here
      // await _databaseHelper.deleteNote(noteId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get note by ID
  QuickNote? getNote(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get notes by category
  List<QuickNote> getNotesByCategory(String category) {
    return _notes.where((note) => note.category == category).toList();
  }

  // Get pinned notes
  List<QuickNote> getPinnedNotes() {
    return _notes.where((note) => note.isPinned).toList();
  }

  // Search notes
  List<QuickNote> searchNotes(String query) {
    if (query.isEmpty) return _notes;

    final queryLower = query.toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(queryLower) ||
          (note.content?.toLowerCase().contains(queryLower) ?? false) ||
          note.tags.any((tag) => tag.toLowerCase().contains(queryLower));
    }).toList();
  }

  // Get notes by project
  List<QuickNote> getNotesByProject(String projectId) {
    return _notes.where((note) => note.projectId == projectId).toList();
  }

  // Get all categories
  List<String> getCategories() {
    final categories = _notes.map((note) => note.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Get all tags
  List<String> getAllTags() {
    final tags = <String>{};
    for (final note in _notes) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }

  // Get notes statistics
  Map<String, dynamic> getNotesStatistics() {
    final totalNotes = _notes.length;
    final pinnedNotes = _notes.where((note) => note.isPinned).length;
    final categories = _notes.map((note) => note.category).toSet().length;
    final totalTags = getAllTags().length;

    // Recent notes (last 7 days)
    final now = DateTime.now();
    final recentNotes = _notes.where((note) {
      return now.difference(note.createdAt).inDays <= 7;
    }).length;

    return {
      'totalNotes': totalNotes,
      'pinnedNotes': pinnedNotes,
      'categories': categories,
      'totalTags': totalTags,
      'recentNotes': recentNotes,
    };
  }

  // Generate intelligent insights
  List<String> generateInsights() {
    final insights = <String>[];
    final stats = getNotesStatistics();

    if (stats['totalNotes'] == 0) {
      insights.add('Start creating notes to organize your thoughts and ideas!');
      return insights;
    }

    if (stats['pinnedNotes'] == 0) {
      insights.add('Consider pinning important notes for quick access');
    }

    if (stats['recentNotes'] == 0) {
      insights.add(
        'You haven\'t created any notes recently. Time to jot down some ideas!',
      );
    } else if (stats['recentNotes'] >= 5) {
      insights.add('Great! You\'ve been actively taking notes recently');
    }

    if (stats['categories'] < 3) {
      insights.add(
        'Try organizing your notes into more categories for better structure',
      );
    }

    // Check for notes without content
    final emptyNotes = _notes
        .where((note) => note.content == null || note.content!.isEmpty)
        .length;
    if (emptyNotes > 0) {
      insights.add(
        'You have $emptyNotes notes without content. Consider adding details to make them more useful',
      );
    }

    // Check for notes without tags
    final untaggedNotes = _notes.where((note) => note.tags.isEmpty).length;
    if (untaggedNotes > 0) {
      insights.add(
        'Consider adding tags to your notes for better organization',
      );
    }

    return insights;
  }

  // Get sample notes with more realistic data
  Future<List<QuickNote>> _getSampleNotes() async {
    final now = DateTime.now();

    return [
      QuickNote(
        id: '1',
        title: 'Project Planning Meeting',
        content:
            'Discuss project requirements with client. Key points: Budget approved, timeline extended by 2 weeks, need to add mobile app support. Client wants real-time notifications and offline capabilities.',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        category: 'Meeting',
        tags: ['client', 'requirements', 'budget', 'mobile'],
        isPinned: true,
        color: Colors.blue,
        projectId: 'project_1',
      ),
      QuickNote(
        id: '2',
        title: 'App Enhancement Ideas',
        content:
            'Add dark mode support, better analytics dashboard, real-time notifications, and offline sync capabilities. Also consider adding voice notes and image attachments.',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        category: 'Ideas',
        tags: ['features', 'ui', 'analytics', 'enhancement'],
        isPinned: false,
        color: Colors.purple,
        projectId: 'project_2',
      ),
      QuickNote(
        id: '3',
        title: 'Development Timeline',
        content:
            'Phase 1: Design (2 weeks)\nPhase 2: Development (4 weeks)\nPhase 3: Testing (1 week)\nPhase 4: Deployment (1 week)\n\nMilestones: UI mockups by Friday, API integration by next month',
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        category: 'Project',
        tags: ['timeline', 'phases', 'planning', 'milestones'],
        isPinned: true,
        color: Colors.green,
        projectId: 'project_1',
      ),
      QuickNote(
        id: '4',
        title: 'Code Review Notes',
        content:
            'Review completed for authentication module. Issues found: Password validation needs improvement, error handling could be better. Need to add rate limiting for login attempts.',
        createdAt: now.subtract(const Duration(hours: 3)),
        category: 'Development',
        tags: ['code', 'review', 'security', 'authentication'],
        isPinned: false,
        color: Colors.orange,
        projectId: 'project_1',
      ),
      QuickNote(
        id: '5',
        title: 'Client Feedback',
        content:
            'Client loves the new dashboard design! They want to add more customization options and export functionality. Also mentioned they need better reporting features.',
        createdAt: now.subtract(const Duration(hours: 1)),
        category: 'Feedback',
        tags: ['client', 'feedback', 'dashboard', 'customization'],
        isPinned: false,
        color: Colors.teal,
        projectId: 'project_2',
      ),
      QuickNote(
        id: '6',
        title: 'Bug Fixes Needed',
        content:
            'Critical bugs to fix:\n1. Login issue on mobile devices\n2. Data sync problems\n3. Performance issues with large datasets\n4. UI glitches in dark mode',
        createdAt: now.subtract(const Duration(minutes: 30)),
        category: 'Bugs',
        tags: ['bugs', 'fixes', 'mobile', 'performance'],
        isPinned: true,
        color: Colors.red,
        projectId: 'project_1',
      ),
      QuickNote(
        id: '7',
        title: 'Team Meeting Agenda',
        content:
            'Weekly team sync:\n- Review progress on current sprint\n- Discuss upcoming deadlines\n- Address any blockers\n- Plan next week\'s tasks\n- Demo new features',
        createdAt: now.subtract(const Duration(minutes: 15)),
        category: 'Meeting',
        tags: ['team', 'agenda', 'sprint', 'planning'],
        isPinned: false,
        color: Colors.indigo,
      ),
      QuickNote(
        id: '8',
        title: 'Learning Resources',
        content:
            'Useful resources for the team:\n- Flutter documentation updates\n- New design patterns to implement\n- Performance optimization techniques\n- Testing best practices',
        createdAt: now.subtract(const Duration(minutes: 5)),
        category: 'Learning',
        tags: ['resources', 'learning', 'flutter', 'documentation'],
        isPinned: false,
        color: Colors.amber,
      ),
    ];
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
