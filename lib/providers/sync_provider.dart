import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cloud_sync_service.dart';
import '../models/project.dart';

class SyncProvider extends ChangeNotifier {
  final CloudSyncService _cloudSyncService = CloudSyncService();

  bool _isInitialized = false;
  bool _isSyncing = false;
  bool _isOnline = true;
  DateTime? _lastSyncTime;
  String _syncStatus = 'Ready';
  Map<String, bool> _syncResults = {};

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;
  String get syncStatus => _syncStatus;
  Map<String, bool> get syncResults => _syncResults;
  bool get isSignedIn => _cloudSyncService.isSignedIn;

  SyncProvider() {
    _initialize();
  }

  /// Initialize sync provider
  Future<void> _initialize() async {
    try {
      await _cloudSyncService.initialize();
      await _loadLastSyncTime();
      _isInitialized = true;
      _updateSyncStatus('Ready');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing SyncProvider: $e');
      }
      _updateSyncStatus('Error: $e');
      notifyListeners();
    }
  }

  /// Load last sync time from preferences
  Future<void> _loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString('last_sync_time');
    if (lastSyncString != null) {
      _lastSyncTime = DateTime.parse(lastSyncString);
    }
  }

  /// Save last sync time to preferences
  Future<void> _saveLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_sync_time', _lastSyncTime!.toIso8601String());
  }

  /// Update sync status
  void _updateSyncStatus(String status) {
    _syncStatus = status;
    notifyListeners();
  }

  /// Set online status
  void setOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  /// Sync single project to cloud
  Future<bool> syncProject(Project project) async {
    if (!isSignedIn || !_isOnline) return false;

    _isSyncing = true;
    _updateSyncStatus('Syncing project: ${project.name}');
    notifyListeners();

    try {
      final success = await _cloudSyncService.syncProject(project);
      _syncResults['project_${project.id}'] = success;

      if (success) {
        _lastSyncTime = DateTime.now();
        await _saveLastSyncTime();
        _updateSyncStatus('Project synced successfully');
      } else {
        _updateSyncStatus('Failed to sync project');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing project: $e');
      }
      _updateSyncStatus('Error: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync single client to cloud
  Future<bool> syncClient(Client client) async {
    if (!isSignedIn || !_isOnline) return false;

    _isSyncing = true;
    _updateSyncStatus('Syncing client: ${client.name}');
    notifyListeners();

    try {
      final success = await _cloudSyncService.syncClient(client);
      _syncResults['client_${client.id}'] = success;

      if (success) {
        _lastSyncTime = DateTime.now();
        await _saveLastSyncTime();
        _updateSyncStatus('Client synced successfully');
      } else {
        _updateSyncStatus('Failed to sync client');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing client: $e');
      }
      _updateSyncStatus('Error: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync all data to cloud
  Future<Map<String, bool>> syncAllData({
    required List<Project> projects,
    required List<Client> clients,
  }) async {
    if (!isSignedIn || !_isOnline) return {};

    _isSyncing = true;
    _updateSyncStatus('Syncing all data...');
    notifyListeners();

    try {
      final results = await _cloudSyncService.syncAllData(
        projects: projects,
        clients: clients,
      );

      _syncResults = results;
      _lastSyncTime = DateTime.now();
      await _saveLastSyncTime();

      final successCount = results.values.where((success) => success).length;
      final totalCount = results.length;

      _updateSyncStatus('Synced $successCount/$totalCount items');

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing all data: $e');
      }
      _updateSyncStatus('Error: $e');
      return {};
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Download all data from cloud
  Future<Map<String, dynamic>> downloadAllData() async {
    if (!isSignedIn || !_isOnline) return {};

    _isSyncing = true;
    _updateSyncStatus('Downloading data from cloud...');
    notifyListeners();

    try {
      final data = await _cloudSyncService.downloadAllData();

      _lastSyncTime = DateTime.now();
      await _saveLastSyncTime();

      _updateSyncStatus('Data downloaded successfully');

      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading data: $e');
      }
      _updateSyncStatus('Error: $e');
      return {};
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Delete project from cloud
  Future<bool> deleteProject(String projectId) async {
    if (!isSignedIn || !_isOnline) return false;

    _isSyncing = true;
    _updateSyncStatus('Deleting project from cloud...');
    notifyListeners();

    try {
      final success = await _cloudSyncService.deleteProject(projectId);

      if (success) {
        _lastSyncTime = DateTime.now();
        await _saveLastSyncTime();
        _updateSyncStatus('Project deleted successfully');
      } else {
        _updateSyncStatus('Failed to delete project');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting project: $e');
      }
      _updateSyncStatus('Error: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Delete client from cloud
  Future<bool> deleteClient(String clientId) async {
    if (!isSignedIn || !_isOnline) return false;

    _isSyncing = true;
    _updateSyncStatus('Deleting client from cloud...');
    notifyListeners();

    try {
      final success = await _cloudSyncService.deleteClient(clientId);

      if (success) {
        _lastSyncTime = DateTime.now();
        await _saveLastSyncTime();
        _updateSyncStatus('Client deleted successfully');
      } else {
        _updateSyncStatus('Failed to delete client');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting client: $e');
      }
      _updateSyncStatus('Error: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Listen to projects changes from cloud
  Stream<List<Project>> listenToProjects() {
    if (!isSignedIn) return Stream.value([]);
    return _cloudSyncService.listenToProjects();
  }

  /// Listen to clients changes from cloud
  Stream<List<Client>> listenToClients() {
    if (!isSignedIn) return Stream.value([]);
    return _cloudSyncService.listenToClients();
  }

  /// Check if item is synced
  Future<bool> isItemSynced(String itemId, String type) async {
    if (!isSignedIn) return false;
    return await _cloudSyncService.isDataSynced(itemId, type);
  }

  /// Get sync status for specific item
  bool getItemSyncStatus(String itemId) {
    return _syncResults[itemId] ?? false;
  }

  /// Clear sync results
  void clearSyncResults() {
    _syncResults.clear();
    notifyListeners();
  }

  /// Force sync (retry failed items)
  Future<void> forceSync({
    required List<Project> projects,
    required List<Client> clients,
  }) async {
    _syncResults.clear();
    await syncAllData(projects: projects, clients: clients);
  }

  /// Clear all cloud data
  Future<void> clearAllCloudData() async {
    if (!isSignedIn) return;

    _isSyncing = true;
    _updateSyncStatus('Clearing cloud data...');
    notifyListeners();

    try {
      await _cloudSyncService.clearAllCloudData();
      _updateSyncStatus('Cloud data cleared');
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cloud data: $e');
      }
      _updateSyncStatus('Error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Get sync summary
  Map<String, dynamic> getSyncSummary() {
    final totalItems = _syncResults.length;
    final successfulItems = _syncResults.values
        .where((success) => success)
        .length;
    final failedItems = totalItems - successfulItems;

    return {
      'totalItems': totalItems,
      'successfulItems': successfulItems,
      'failedItems': failedItems,
      'lastSyncTime': _lastSyncTime,
      'isOnline': _isOnline,
      'isSignedIn': isSignedIn,
    };
  }
}
