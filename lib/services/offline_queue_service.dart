import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';

enum QueueOperationType {
  createProject,
  updateProject,
  deleteProject,
  createClient,
  updateClient,
  deleteClient,
  createPhase,
  updatePhase,
  deletePhase,
  createTask,
  updateTask,
  deleteTask,
  createPayment,
  updatePayment,
  deletePayment,
}

class QueueOperation {
  final String id;
  final QueueOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;
  final String? error;

  QueueOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'error': error,
    };
  }

  factory QueueOperation.fromJson(Map<String, dynamic> json) {
    return QueueOperation(
      id: json['id'],
      type: QueueOperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QueueOperationType.createProject,
      ),
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
      error: json['error'],
    );
  }

  QueueOperation copyWith({
    String? id,
    QueueOperationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
    String? error,
  }) {
    return QueueOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
    );
  }
}

class OfflineQueueService extends ChangeNotifier {
  static const String _queueKey = 'offline_queue';
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(minutes: 5);

  List<QueueOperation> _operations = [];
  bool _isProcessing = false;

  // Getters
  List<QueueOperation> get operations => List.unmodifiable(_operations);
  bool get isProcessing => _isProcessing;
  int get pendingCount => _operations.length;
  int get failedCount => _operations.where((op) => op.error != null).length;
  int get retryableCount => _operations
      .where((op) => op.error != null && op.retryCount < maxRetries)
      .length;

  OfflineQueueService() {
    _loadOperations();
  }

  /// Load operations from storage
  Future<void> _loadOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);

      if (queueJson != null) {
        final List<dynamic> operationsJson = json.decode(queueJson);
        _operations = operationsJson
            .map((json) => QueueOperation.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading offline queue: $e');
      }
    }
  }

  /// Save operations to storage
  Future<void> _saveOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operationsJson = _operations.map((op) => op.toJson()).toList();
      await prefs.setString(_queueKey, json.encode(operationsJson));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving offline queue: $e');
      }
    }
  }

  /// Add operation to queue
  Future<void> addOperation(QueueOperation operation) async {
    _operations.add(operation);
    await _saveOperations();
    notifyListeners();

    if (kDebugMode) {
      print('Added operation to queue: ${operation.type.name}');
    }
  }

  /// Add project operation
  Future<void> addProjectOperation(
    QueueOperationType type,
    Project project,
  ) async {
    final operation = QueueOperation(
      id: '${type.name}_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      data: project.toJson(),
      timestamp: DateTime.now(),
    );
    await addOperation(operation);
  }

  /// Add client operation
  Future<void> addClientOperation(
    QueueOperationType type,
    Client client,
  ) async {
    final operation = QueueOperation(
      id: '${type.name}_${client.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      data: client.toJson(),
      timestamp: DateTime.now(),
    );
    await addOperation(operation);
  }

  /// Add phase operation
  Future<void> addPhaseOperation(
    QueueOperationType type,
    Phase phase,
    String projectId,
  ) async {
    final operation = QueueOperation(
      id: '${type.name}_${phase.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      data: {...phase.toJson(), 'projectId': projectId},
      timestamp: DateTime.now(),
    );
    await addOperation(operation);
  }

  /// Add task operation
  Future<void> addTaskOperation(
    QueueOperationType type,
    Task task,
    String projectId,
    String phaseId,
  ) async {
    final operation = QueueOperation(
      id: '${type.name}_${task.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      data: {...task.toJson(), 'projectId': projectId, 'phaseId': phaseId},
      timestamp: DateTime.now(),
    );
    await addOperation(operation);
  }

  /// Add payment operation
  Future<void> addPaymentOperation(
    QueueOperationType type,
    Payment payment,
    String projectId,
  ) async {
    final operation = QueueOperation(
      id: '${type.name}_${payment.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      data: {...payment.toJson(), 'projectId': projectId},
      timestamp: DateTime.now(),
    );
    await addOperation(operation);
  }

  /// Process all pending operations
  Future<void> processQueue(Function(QueueOperation) processor) async {
    if (_isProcessing || _operations.isEmpty) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final operationsToProcess = List<QueueOperation>.from(_operations);
      final processedOperations = <String>[];
      final failedOperations = <QueueOperation>[];

      for (final operation in operationsToProcess) {
        try {
          await processor(operation);
          processedOperations.add(operation.id);

          if (kDebugMode) {
            print('Successfully processed operation: ${operation.type.name}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to process operation ${operation.type.name}: $e');
          }

          final updatedOperation = operation.copyWith(
            retryCount: operation.retryCount + 1,
            error: e.toString(),
          );

          if (updatedOperation.retryCount < maxRetries) {
            failedOperations.add(updatedOperation);
          } else {
            if (kDebugMode) {
              print('Operation ${operation.type.name} exceeded max retries');
            }
          }
        }
      }

      // Remove processed operations
      _operations.removeWhere((op) => processedOperations.contains(op.id));

      // Update failed operations
      for (final failedOp in failedOperations) {
        final index = _operations.indexWhere((op) => op.id == failedOp.id);
        if (index != -1) {
          _operations[index] = failedOp;
        }
      }

      await _saveOperations();
    } catch (e) {
      if (kDebugMode) {
        print('Error processing queue: $e');
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Retry failed operations
  Future<void> retryFailedOperations(Function(QueueOperation) processor) async {
    final retryableOperations = _operations
        .where((op) => op.error != null && op.retryCount < maxRetries)
        .toList();

    if (retryableOperations.isEmpty) return;

    for (final operation in retryableOperations) {
      final updatedOperation = operation.copyWith(
        retryCount: operation.retryCount + 1,
        error: null,
      );

      final index = _operations.indexWhere((op) => op.id == operation.id);
      if (index != -1) {
        _operations[index] = updatedOperation;
      }
    }

    await _saveOperations();
    await processQueue(processor);
  }

  /// Remove operation from queue
  Future<void> removeOperation(String operationId) async {
    _operations.removeWhere((op) => op.id == operationId);
    await _saveOperations();
    notifyListeners();
  }

  /// Clear all operations
  Future<void> clearQueue() async {
    _operations.clear();
    await _saveOperations();
    notifyListeners();
  }

  /// Clear failed operations
  Future<void> clearFailedOperations() async {
    _operations.removeWhere((op) => op.error != null);
    await _saveOperations();
    notifyListeners();
  }

  /// Get operations by type
  List<QueueOperation> getOperationsByType(QueueOperationType type) {
    return _operations.where((op) => op.type == type).toList();
  }

  /// Get operations by project
  List<QueueOperation> getOperationsByProject(String projectId) {
    return _operations
        .where(
          (op) =>
              op.data['projectId'] == projectId || op.data['id'] == projectId,
        )
        .toList();
  }

  /// Get operations by client
  List<QueueOperation> getOperationsByClient(String clientId) {
    return _operations
        .where(
          (op) => op.data['clientId'] == clientId || op.data['id'] == clientId,
        )
        .toList();
  }

  /// Check if project has pending operations
  bool hasPendingOperationsForProject(String projectId) {
    return _operations.any(
      (op) => op.data['projectId'] == projectId || op.data['id'] == projectId,
    );
  }

  /// Check if client has pending operations
  bool hasPendingOperationsForClient(String clientId) {
    return _operations.any(
      (op) => op.data['clientId'] == clientId || op.data['id'] == clientId,
    );
  }

  /// Get queue summary
  Map<String, dynamic> getQueueSummary() {
    return {
      'totalOperations': _operations.length,
      'pendingOperations': _operations.where((op) => op.error == null).length,
      'failedOperations': failedCount,
      'retryableOperations': retryableCount,
      'isProcessing': _isProcessing,
      'operationsByType': Map.fromEntries(
        QueueOperationType.values.map(
          (type) => MapEntry(
            type.name,
            _operations.where((op) => op.type == type).length,
          ),
        ),
      ),
    };
  }

  /// Get oldest operation
  QueueOperation? getOldestOperation() {
    if (_operations.isEmpty) return null;
    _operations.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return _operations.first;
  }

  /// Get newest operation
  QueueOperation? getNewestOperation() {
    if (_operations.isEmpty) return null;
    _operations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return _operations.first;
  }

  /// Check if queue is empty
  bool get isEmpty => _operations.isEmpty;

  /// Check if queue has failed operations
  bool get hasFailedOperations => failedCount > 0;

  /// Check if queue can be processed
  bool get canProcess => !_isProcessing && _operations.isNotEmpty;
}
