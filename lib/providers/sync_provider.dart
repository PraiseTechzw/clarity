import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cloud_sync_service.dart';
import '../services/network_service.dart';
import '../models/project.dart';
import 'auth_provider.dart';

class SyncProvider extends ChangeNotifier {
  final CloudSyncService _cloudSyncService = CloudSyncService();
  final NetworkService _networkService = NetworkService();
  AuthProvider? _authProvider;

  bool _isInitialized = false;
  bool _isSyncing = false;
  bool _isOnline = true;
  DateTime? _lastSyncTime;
  String _syncStatus = 'Ready';
  Map<String, bool> _syncResults = {};

  // Enhanced sync tracking
  double _syncProgress = 0.0;
  int _totalItems = 0;
  int _completedItems = 0;
  int _failedItems = 0;
  List<String> _syncErrors = [];
  int _retryCount = 0;
  static const int maxRetries = 3;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;
  String get syncStatus => _syncStatus;
  Map<String, bool> get syncResults => _syncResults;
  bool get isSignedIn =>
      _authProvider?.isAuthenticated ?? _cloudSyncService.isSignedIn;

  // Enhanced getters
  double get syncProgress => _syncProgress;
  int get totalItems => _totalItems;
  int get completedItems => _completedItems;
  int get failedItems => _failedItems;
  List<String> get syncErrors => _syncErrors;
  int get retryCount => _retryCount;
  bool get hasErrors => _syncErrors.isNotEmpty;
  bool get canRetry => _retryCount < maxRetries && hasErrors;

  SyncProvider() {
    _initialize();
  }

  /// Set the AuthProvider reference
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    // Listen to auth changes
    _authProvider!.addListener(_onAuthStateChanged);
    notifyListeners();
  }

  /// Handle auth state changes
  void _onAuthStateChanged() {
    notifyListeners();
  }

  /// Initialize sync provider
  Future<void> _initialize() async {
    try {
      await _cloudSyncService.initialize();
      await _networkService.initialize();
      await _loadLastSyncTime();
      await _loadSyncStatus();

      // Listen to network changes
      _networkService.addListener(_onNetworkChanged);

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

  /// Handle network changes
  void _onNetworkChanged() {
    _isOnline = _networkService.isOnline;
    notifyListeners();

    // Auto-sync when back online
    if (_isOnline && _authProvider?.isAuthenticated == true) {
      _autoSync();
    }
  }

  /// Auto-sync when back online
  Future<void> _autoSync() async {
    if (_isSyncing) return;

    try {
      _updateSyncStatus('Auto-syncing...');
      // This would trigger a sync with the current data
      // Implementation depends on your specific needs
    } catch (e) {
      if (kDebugMode) {
        print('Auto-sync failed: $e');
      }
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

  /// Load sync status from preferences
  Future<void> _loadSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final syncStatusString = prefs.getString('sync_status');
    if (syncStatusString != null) {
      _syncStatus = syncStatusString;
    }

    final progress = prefs.getDouble('sync_progress');
    if (progress != null) {
      _syncProgress = progress;
    }
  }

  /// Save sync status to preferences
  Future<void> _saveSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sync_status', _syncStatus);
    await prefs.setDouble('sync_progress', _syncProgress);
  }

  /// Update sync status
  void _updateSyncStatus(String status) {
    _syncStatus = status;
    _saveSyncStatus();
    notifyListeners();
  }

  /// Update sync progress
  void _updateSyncProgress(double progress) {
    _syncProgress = progress;
    _saveSyncStatus();
    notifyListeners();
  }

  /// Set online status
  void setOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  /// Reset sync state
  void _resetSyncState() {
    _syncProgress = 0.0;
    _totalItems = 0;
    _completedItems = 0;
    _failedItems = 0;
    _syncErrors.clear();
    _retryCount = 0;
    notifyListeners();
  }

  /// Add sync error
  void _addSyncError(String error) {
    _syncErrors.add(error);
    _failedItems++;
    notifyListeners();
  }

  /// Clear sync errors
  void clearSyncErrors() {
    _syncErrors.clear();
    _failedItems = 0;
    notifyListeners();
  }

  /// Retry failed sync operations
  Future<void> retryFailedSync({
    required List<Project> projects,
    required List<Client> clients,
  }) async {
    if (!canRetry) return;

    _retryCount++;
    _updateSyncStatus(
      'Retrying failed sync... (Attempt $_retryCount/$maxRetries)',
    );

    await syncAllData(projects: projects, clients: clients);
  }

  /// Sync single project to cloud with progress tracking
  Future<bool> syncProject(Project project) async {
    if (!isSignedIn || !_isOnline) return false;

    _isSyncing = true;
    _updateSyncStatus('Syncing project: ${project.name}');
    notifyListeners();

    try {
      final success = await _retrySync(
        () => _cloudSyncService.syncProject(project),
      );
      _syncResults['project_${project.id}'] = success;

      if (success) {
        _completedItems++;
        _lastSyncTime = DateTime.now();
        await _saveLastSyncTime();
        _updateSyncStatus('Project synced successfully');
      } else {
        _addSyncError('Failed to sync project: ${project.name}');
        _updateSyncStatus('Failed to sync project');
      }

      _updateSyncProgress(
        _totalItems > 0 ? _completedItems / _totalItems : 0.0,
      );
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing project: $e');
      }
      _addSyncError('Error syncing project ${project.name}: $e');
      _updateSyncStatus('Error: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync single client to cloud with progress tracking
  Future<bool> syncClient(Client client) async {
    if (!isSignedIn || !_isOnline) return false;

    _isSyncing = true;
    _updateSyncStatus('Syncing client: ${client.name}');
    notifyListeners();

    try {
      final success = await _retrySync(
        () => _cloudSyncService.syncClient(client),
      );
      _syncResults['client_${client.id}'] = success;

      if (success) {
        _completedItems++;
        _lastSyncTime = DateTime.now();
        await _saveLastSyncTime();
        _updateSyncStatus('Client synced successfully');
      } else {
        _addSyncError('Failed to sync client: ${client.name}');
        _updateSyncStatus('Failed to sync client');
      }

      _updateSyncProgress(
        _totalItems > 0 ? _completedItems / _totalItems : 0.0,
      );
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing client: $e');
      }
      _addSyncError('Error syncing client ${client.name}: $e');
      _updateSyncStatus('Error: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync all data to cloud with progress tracking
  Future<Map<String, bool>> syncAllData({
    required List<Project> projects,
    required List<Client> clients,
  }) async {
    if (!isSignedIn || !_isOnline) return {};

    _resetSyncState();
    _isSyncing = true;
    _totalItems = projects.length + clients.length;
    _updateSyncStatus('Syncing all data...');
    notifyListeners();

    try {
      final results = <String, bool>{};

      // Sync projects
      for (int i = 0; i < projects.length; i++) {
        final project = projects[i];
        _updateSyncStatus(
          'Syncing project ${i + 1}/${projects.length}: ${project.name}',
        );

        final success = await _retrySync(
          () => _cloudSyncService.syncProject(project),
        );
        results['project_${project.id}'] = success;

        if (success) {
          _completedItems++;
        } else {
          _addSyncError('Failed to sync project: ${project.name}');
        }

        _updateSyncProgress(_completedItems / _totalItems);
      }

      // Sync clients
      for (int i = 0; i < clients.length; i++) {
        final client = clients[i];
        _updateSyncStatus(
          'Syncing client ${i + 1}/${clients.length}: ${client.name}',
        );

        final success = await _retrySync(
          () => _cloudSyncService.syncClient(client),
        );
        results['client_${client.id}'] = success;

        if (success) {
          _completedItems++;
        } else {
          _addSyncError('Failed to sync client: ${client.name}');
        }

        _updateSyncProgress(_completedItems / _totalItems);
      }

      _syncResults = results;
      _lastSyncTime = DateTime.now();
      await _saveLastSyncTime();

      final successCount = results.values.where((success) => success).length;
      _updateSyncStatus('Synced $successCount/$_totalItems items');

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing all data: $e');
      }
      _addSyncError('Error syncing all data: $e');
      _updateSyncStatus('Error: $e');
      return {};
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Retry mechanism for sync operations
  Future<bool> _retrySync(Future<bool> Function() syncOperation) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await syncOperation();
      } catch (e) {
        if (i == maxRetries - 1) {
          _addSyncError('Max retries exceeded: $e');
          rethrow;
        }
        await Future.delayed(Duration(seconds: 2 * (i + 1)));
      }
    }
    return false;
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
      _addSyncError('Error downloading data: $e');
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
      final success = await _retrySync(
        () => _cloudSyncService.deleteProject(projectId),
      );

      if (success) {
        _lastSyncTime = DateTime.now();
        await _saveLastSyncTime();
        _updateSyncStatus('Project deleted successfully');
      } else {
        _addSyncError('Failed to delete project');
        _updateSyncStatus('Failed to delete project');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting project: $e');
      }
      _addSyncError('Error deleting project: $e');
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
      final success = await _retrySync(
        () => _cloudSyncService.deleteClient(clientId),
      );

      if (success) {
        _lastSyncTime = DateTime.now();
        await _saveLastSyncTime();
        _updateSyncStatus('Client deleted successfully');
      } else {
        _addSyncError('Failed to delete client');
        _updateSyncStatus('Failed to delete client');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting client: $e');
      }
      _addSyncError('Error deleting client: $e');
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
      _addSyncError('Error clearing cloud data: $e');
      _updateSyncStatus('Error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Get sync summary
  Map<String, dynamic> getSyncSummary() {
    return {
      'totalItems': _totalItems,
      'completedItems': _completedItems,
      'failedItems': _failedItems,
      'lastSyncTime': _lastSyncTime,
      'isOnline': _isOnline,
      'isSignedIn': isSignedIn,
      'syncProgress': _syncProgress,
      'retryCount': _retryCount,
      'canRetry': canRetry,
      'hasErrors': hasErrors,
      'errors': _syncErrors,
    };
  }

  @override
  void dispose() {
    _authProvider?.removeListener(_onAuthStateChanged);
    _networkService.removeListener(_onNetworkChanged);
    super.dispose();
  }
}
