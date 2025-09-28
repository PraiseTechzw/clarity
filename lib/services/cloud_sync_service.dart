import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/project.dart';

class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection names
  static const String _projectsCollection = 'projects';
  static const String _clientsCollection = 'clients';
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
