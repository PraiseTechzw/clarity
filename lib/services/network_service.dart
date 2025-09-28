import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService extends ChangeNotifier {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isOnline = true;
  ConnectivityResult _connectionType = ConnectivityResult.none;
  DateTime? _lastOnlineTime;
  DateTime? _lastOfflineTime;

  // Getters
  bool get isOnline => _isOnline;
  ConnectivityResult get connectionType => _connectionType;
  DateTime? get lastOnlineTime => _lastOnlineTime;
  DateTime? get lastOfflineTime => _lastOfflineTime;

  /// Initialize network monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectivityStatus([result]);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(ConnectivityResult result) {
    _updateConnectivityStatus([result]);
  }

  /// Update connectivity status
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    final primaryResult = results.isNotEmpty
        ? results.first
        : ConnectivityResult.none;

    _connectionType = primaryResult;
    _isOnline = primaryResult != ConnectivityResult.none;

    if (_isOnline && !wasOnline) {
      _lastOnlineTime = DateTime.now();
      if (kDebugMode) {
        print('Network: Back online (${primaryResult.name})');
      }
    } else if (!_isOnline && wasOnline) {
      _lastOfflineTime = DateTime.now();
      if (kDebugMode) {
        print('Network: Gone offline (${primaryResult.name})');
      }
    }

    notifyListeners();
  }

  /// Get connection type as string
  String get connectionTypeString {
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  /// Get connection quality indicator
  String get connectionQuality {
    if (!_isOnline) return 'Offline';

    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'Excellent';
      case ConnectivityResult.ethernet:
        return 'Excellent';
      case ConnectivityResult.mobile:
        return 'Good';
      case ConnectivityResult.vpn:
        return 'Good';
      case ConnectivityResult.bluetooth:
        return 'Fair';
      case ConnectivityResult.other:
        return 'Unknown';
      case ConnectivityResult.none:
        return 'Offline';
    }
  }

  /// Check if connection is stable (online for at least 5 seconds)
  bool get isStable {
    if (!_isOnline || _lastOnlineTime == null) return false;
    return DateTime.now().difference(_lastOnlineTime!).inSeconds >= 5;
  }

  /// Get time since last online
  Duration? get timeSinceLastOnline {
    if (_lastOnlineTime == null) return null;
    return DateTime.now().difference(_lastOnlineTime!);
  }

  /// Get time since last offline
  Duration? get timeSinceLastOffline {
    if (_lastOfflineTime == null) return null;
    return DateTime.now().difference(_lastOfflineTime!);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
