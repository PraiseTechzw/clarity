import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../screens/notes_screen.dart';

class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection names
  static const String _projectsCollection = 'projects';
  static const String _clientsCollection = 'clients';
  static const String _notesCollection = 'notes';
  static const String _quickNotesCollection = 'quickNotes';
  static const String _usersCollection = 'users';

  // Getters
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isSignedIn => _auth.currentUser != null;

  /// Initialize cloud sync
  Future<void> initialize() async {
    try {
      // Enable offline persistence
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      if (kDebugMode) {
        print('CloudSyncService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing CloudSyncService: $e');
      }
    }
  }

  /// Get user document reference
  DocumentReference get _userDocRef {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection(_usersCollection).doc(currentUserId);
  }

  /// Sync project to cloud
  Future<bool> syncProject(Project project) async {
    try {
      if (!isSignedIn) return false;

      final projectData = project.toJson();
      projectData['lastModified'] = FieldValue.serverTimestamp();
      projectData['userId'] = currentUserId;

      await _userDocRef
          .collection(_projectsCollection)
          .doc(project.id)
          .set(projectData, SetOptions(merge: true));

      if (kDebugMode) {
        print('Project ${project.name} synced to cloud');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing project: $e');
      }
      return false;
    }
  }

  /// Sync client to cloud
  Future<bool> syncClient(Client client) async {
    try {
      if (!isSignedIn) return false;

      final clientData = client.toJson();
      clientData['lastModified'] = FieldValue.serverTimestamp();
      clientData['userId'] = currentUserId;

      await _userDocRef
          .collection(_clientsCollection)
          .doc(client.id)
          .set(clientData, SetOptions(merge: true));

      if (kDebugMode) {
        print('Client ${client.name} synced to cloud');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing client: $e');
      }
      return false;
    }
  }

  /// Delete project from cloud
  Future<bool> deleteProject(String projectId) async {
    try {
      if (!isSignedIn) return false;

      await _userDocRef.collection(_projectsCollection).doc(projectId).delete();

      if (kDebugMode) {
        print('Project $projectId deleted from cloud');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting project: $e');
      }
      return false;
    }
  }

  /// Delete client from cloud
  Future<bool> deleteClient(String clientId) async {
    try {
      if (!isSignedIn) return false;

      await _userDocRef.collection(_clientsCollection).doc(clientId).delete();

      if (kDebugMode) {
        print('Client $clientId deleted from cloud');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting client: $e');
      }
      return false;
    }
  }

  /// Fetch all projects from cloud
  Future<List<Project>> fetchProjects() async {
    try {
      if (!isSignedIn) return [];

      final snapshot = await _userDocRef
          .collection(_projectsCollection)
          .orderBy('lastModified', descending: true)
          .get();

      return snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching projects: $e');
      }
      return [];
    }
  }

  /// Fetch all clients from cloud
  Future<List<Client>> fetchClients() async {
    try {
      if (!isSignedIn) return [];

      final snapshot = await _userDocRef
          .collection(_clientsCollection)
          .orderBy('lastModified', descending: true)
          .get();

      return snapshot.docs.map((doc) => Client.fromJson(doc.data())).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching clients: $e');
      }
      return [];
    }
  }

  /// Listen to projects changes
  Stream<List<Project>> listenToProjects() {
    if (!isSignedIn) return Stream.value([]);

    return _userDocRef
        .collection(_projectsCollection)
        .orderBy('lastModified', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList(),
        );
  }

  /// Listen to clients changes
  Stream<List<Client>> listenToClients() {
    if (!isSignedIn) return Stream.value([]);

    return _userDocRef
        .collection(_clientsCollection)
        .orderBy('lastModified', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Client.fromJson(doc.data())).toList(),
        );
  }

  /// Sync all local data to cloud
  Future<Map<String, bool>> syncAllData({
    required List<Project> projects,
    required List<Client> clients,
  }) async {
    final results = <String, bool>{};

    // Sync projects
    for (final project in projects) {
      results['project_${project.id}'] = await syncProject(project);
    }

    // Sync clients
    for (final client in clients) {
      results['client_${client.id}'] = await syncClient(client);
    }

    return results;
  }

  /// Download all data from cloud
  Future<Map<String, dynamic>> downloadAllData() async {
    try {
      if (!isSignedIn) return {};

      final projects = await fetchProjects();
      final clients = await fetchClients();

      return {
        'projects': projects,
        'clients': clients,
        'lastSync': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading data: $e');
      }
      return {};
    }
  }

  /// Check if data is synced
  Future<bool> isDataSynced(String itemId, String type) async {
    try {
      if (!isSignedIn) return false;

      final collection = type == 'project'
          ? _projectsCollection
          : _clientsCollection;
      final doc = await _userDocRef.collection(collection).doc(itemId).get();

      return doc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking sync status: $e');
      }
      return false;
    }
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    try {
      if (!isSignedIn) return null;

      final doc = await _userDocRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final lastSync = data?['lastSync'] as Timestamp?;
        return lastSync?.toDate();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting last sync time: $e');
      }
      return null;
    }
  }

  /// Update last sync timestamp
  Future<void> updateLastSyncTime() async {
    try {
      if (!isSignedIn) return;

      await _userDocRef.set({
        'lastSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating last sync time: $e');
      }
    }
  }

  /// Sync project note to cloud
  Future<bool> syncProjectNote(Note note, String projectId) async {
    try {
      if (!isSignedIn) return false;

      final noteData = note.toJson();
      noteData['lastModified'] = FieldValue.serverTimestamp();
      noteData['userId'] = currentUserId;
      noteData['projectId'] = projectId;

      await _userDocRef
          .collection(_projectsCollection)
          .doc(projectId)
          .collection(_notesCollection)
          .doc(note.id)
          .set(noteData, SetOptions(merge: true));

      if (kDebugMode) {
        print('Project note ${note.title} synced to cloud');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing project note: $e');
      }
      return false;
    }
  }

  /// Sync quick note to cloud
  Future<bool> syncQuickNote(QuickNote note) async {
    try {
      if (!isSignedIn) return false;

      final noteData = note.toJson();
      noteData['lastModified'] = FieldValue.serverTimestamp();
      noteData['userId'] = currentUserId;

      await _userDocRef
          .collection(_quickNotesCollection)
          .doc(note.id)
          .set(noteData, SetOptions(merge: true));

      if (kDebugMode) {
        print('Quick note ${note.title} synced to cloud');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing quick note: $e');
      }
      return false;
    }
  }

  /// Delete project note from cloud
  Future<bool> deleteProjectNote(String noteId, String projectId) async {
    try {
      if (!isSignedIn) return false;

      await _userDocRef
          .collection(_projectsCollection)
          .doc(projectId)
          .collection(_notesCollection)
          .doc(noteId)
          .delete();

      if (kDebugMode) {
        print('Project note $noteId deleted from cloud');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting project note: $e');
      }
      return false;
    }
  }

  /// Delete quick note from cloud
  Future<bool> deleteQuickNote(String noteId) async {
    try {
      if (!isSignedIn) return false;

      await _userDocRef.collection(_quickNotesCollection).doc(noteId).delete();

      if (kDebugMode) {
        print('Quick note $noteId deleted from cloud');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting quick note: $e');
      }
      return false;
    }
  }

  /// Fetch all project notes from cloud
  Future<List<Note>> fetchProjectNotes(String projectId) async {
    try {
      if (!isSignedIn) return [];

      final snapshot = await _userDocRef
          .collection(_projectsCollection)
          .doc(projectId)
          .collection(_notesCollection)
          .orderBy('lastModified', descending: true)
          .get();

      return snapshot.docs.map((doc) => Note.fromJson(doc.data())).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching project notes: $e');
      }
      return [];
    }
  }

  /// Fetch all quick notes from cloud
  Future<List<QuickNote>> fetchQuickNotes() async {
    try {
      if (!isSignedIn) return [];

      final snapshot = await _userDocRef
          .collection(_quickNotesCollection)
          .orderBy('lastModified', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => QuickNote.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching quick notes: $e');
      }
      return [];
    }
  }

  /// Listen to project notes changes
  Stream<List<Note>> listenToProjectNotes(String projectId) {
    if (!isSignedIn) return Stream.value([]);

    return _userDocRef
        .collection(_projectsCollection)
        .doc(projectId)
        .collection(_notesCollection)
        .orderBy('lastModified', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Note.fromJson(doc.data())).toList(),
        );
  }

  /// Listen to quick notes changes
  Stream<List<QuickNote>> listenToQuickNotes() {
    if (!isSignedIn) return Stream.value([]);

    return _userDocRef
        .collection(_quickNotesCollection)
        .orderBy('lastModified', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => QuickNote.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Sync all project notes to cloud
  Future<Map<String, bool>> syncAllProjectNotes({
    required Map<String, List<Note>> projectNotes,
  }) async {
    final results = <String, bool>{};

    for (final entry in projectNotes.entries) {
      final projectId = entry.key;
      final notes = entry.value;

      for (final note in notes) {
        results['note_${note.id}'] = await syncProjectNote(note, projectId);
      }
    }

    return results;
  }

  /// Sync all quick notes to cloud
  Future<Map<String, bool>> syncAllQuickNotes({
    required List<QuickNote> quickNotes,
  }) async {
    final results = <String, bool>{};

    for (final note in quickNotes) {
      results['quickNote_${note.id}'] = await syncQuickNote(note);
    }

    return results;
  }

  /// Enhanced sync all data with all types
  Future<Map<String, bool>> syncAllDataEnhanced({
    required List<Project> projects,
    required List<Client> clients,
    required List<QuickNote> quickNotes,
    required Map<String, List<Note>> projectNotes,
  }) async {
    final results = <String, bool>{};

    // Sync projects
    for (final project in projects) {
      results['project_${project.id}'] = await syncProject(project);
    }

    // Sync clients
    for (final client in clients) {
      results['client_${client.id}'] = await syncClient(client);
    }

    // Sync quick notes
    final quickNoteResults = await syncAllQuickNotes(quickNotes: quickNotes);
    results.addAll(quickNoteResults);

    // Sync project notes
    final projectNoteResults = await syncAllProjectNotes(
      projectNotes: projectNotes,
    );
    results.addAll(projectNoteResults);

    return results;
  }

  /// Enhanced download all data with all types
  Future<Map<String, dynamic>> downloadAllDataEnhanced() async {
    try {
      if (!isSignedIn) return {};

      final projects = await fetchProjects();
      final clients = await fetchClients();
      final quickNotes = await fetchQuickNotes();

      // Get project notes for each project
      final projectNotes = <String, List<Note>>{};
      for (final project in projects) {
        projectNotes[project.id] = await fetchProjectNotes(project.id);
      }

      return {
        'projects': projects,
        'clients': clients,
        'quickNotes': quickNotes,
        'projectNotes': projectNotes,
        'lastSync': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading enhanced data: $e');
      }
      return {};
    }
  }

  /// Batch sync with progress tracking
  Future<Map<String, dynamic>> batchSyncWithProgress({
    required List<Project> projects,
    required List<Client> clients,
    required List<QuickNote> quickNotes,
    required Map<String, List<Note>> projectNotes,
    required Function(double progress, String status) onProgress,
  }) async {
    final results = <String, bool>{};
    final errors = <String>[];

    final totalItems =
        projects.length +
        clients.length +
        quickNotes.length +
        projectNotes.values.fold(0, (sum, notes) => sum + notes.length);

    int completedItems = 0;

    try {
      // Sync projects
      onProgress(0.0, 'Syncing projects...');
      for (int i = 0; i < projects.length; i++) {
        final project = projects[i];
        try {
          final success = await syncProject(project);
          results['project_${project.id}'] = success;
          if (!success) {
            errors.add('Failed to sync project: ${project.name}');
          }
        } catch (e) {
          errors.add('Error syncing project ${project.name}: $e');
          results['project_${project.id}'] = false;
        }

        completedItems++;
        onProgress(
          completedItems / totalItems,
          'Syncing projects... (${completedItems}/$totalItems)',
        );
      }

      // Sync clients
      onProgress(completedItems / totalItems, 'Syncing clients...');
      for (int i = 0; i < clients.length; i++) {
        final client = clients[i];
        try {
          final success = await syncClient(client);
          results['client_${client.id}'] = success;
          if (!success) {
            errors.add('Failed to sync client: ${client.name}');
          }
        } catch (e) {
          errors.add('Error syncing client ${client.name}: $e');
          results['client_${client.id}'] = false;
        }

        completedItems++;
        onProgress(
          completedItems / totalItems,
          'Syncing clients... (${completedItems}/$totalItems)',
        );
      }

      // Sync quick notes
      onProgress(completedItems / totalItems, 'Syncing quick notes...');
      for (int i = 0; i < quickNotes.length; i++) {
        final note = quickNotes[i];
        try {
          final success = await syncQuickNote(note);
          results['quickNote_${note.id}'] = success;
          if (!success) {
            errors.add('Failed to sync quick note: ${note.title}');
          }
        } catch (e) {
          errors.add('Error syncing quick note ${note.title}: $e');
          results['quickNote_${note.id}'] = false;
        }

        completedItems++;
        onProgress(
          completedItems / totalItems,
          'Syncing quick notes... (${completedItems}/$totalItems)',
        );
      }

      // Sync project notes
      onProgress(completedItems / totalItems, 'Syncing project notes...');
      for (final entry in projectNotes.entries) {
        final projectId = entry.key;
        final notes = entry.value;

        for (int i = 0; i < notes.length; i++) {
          final note = notes[i];
          try {
            final success = await syncProjectNote(note, projectId);
            results['note_${note.id}'] = success;
            if (!success) {
              errors.add('Failed to sync project note: ${note.title}');
            }
          } catch (e) {
            errors.add('Error syncing project note ${note.title}: $e');
            results['note_${note.id}'] = false;
          }

          completedItems++;
          onProgress(
            completedItems / totalItems,
            'Syncing project notes... (${completedItems}/$totalItems)',
          );
        }
      }

      onProgress(1.0, 'Sync completed!');

      return {
        'results': results,
        'errors': errors,
        'successCount': results.values.where((success) => success).length,
        'totalCount': totalItems,
        'errorCount': errors.length,
      };
    } catch (e) {
      onProgress(0.0, 'Sync failed: $e');
      return {
        'results': results,
        'errors': [...errors, 'Sync failed: $e'],
        'successCount': results.values.where((success) => success).length,
        'totalCount': totalItems,
        'errorCount': errors.length + 1,
      };
    }
  }

  /// Clear all cloud data (for testing)
  Future<void> clearAllCloudData() async {
    try {
      if (!isSignedIn) return;

      // Delete all projects
      final projectsSnapshot = await _userDocRef
          .collection(_projectsCollection)
          .get();

      for (final doc in projectsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all clients
      final clientsSnapshot = await _userDocRef
          .collection(_clientsCollection)
          .get();

      for (final doc in clientsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all quick notes
      final quickNotesSnapshot = await _userDocRef
          .collection(_quickNotesCollection)
          .get();

      for (final doc in quickNotesSnapshot.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        print('All cloud data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cloud data: $e');
      }
    }
  }
}
