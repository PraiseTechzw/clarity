import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/database_helper.dart';

class ProjectProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Project> _projects = [];
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Project methods
  Future<void> loadProjects() async {
    _setLoading(true);
    try {
      _projects = await _databaseHelper.getAllProjects();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addProject(Project project) async {
    try {
      await _databaseHelper.insertProject(project);
      _projects.add(project);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _databaseHelper.updateProject(project);
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _databaseHelper.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Project? getProject(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  // Client methods
  Future<void> loadClients() async {
    _setLoading(true);
    try {
      _clients = await _databaseHelper.getAllClients();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addClient(Client client) async {
    try {
      await _databaseHelper.insertClient(client);
      _clients.add(client);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateClient(Client client) async {
    try {
      await _databaseHelper.updateClient(client);
      final index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = client;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      await _databaseHelper.deleteClient(clientId);
      _clients.removeWhere((c) => c.id == clientId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Client? getClient(String id) {
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (e) {
      return null;
    }
  }

  // Analytics methods
  double get totalEarnings {
    return _projects.fold(0.0, (sum, project) => sum + project.totalPaid);
  }

  double get totalOutstanding {
    return _projects.fold(
      0.0,
      (sum, project) => sum + project.outstandingBalance,
    );
  }

  List<Project> get overdueProjects {
    return _projects.where((project) => project.isOverdue).toList();
  }

  List<Project> get highPriorityProjects {
    return _projects
        .where((project) => project.priority == Priority.high)
        .toList();
  }

  List<Project> get projectsWithOutstandingPayments {
    return _projects
        .where(
          (project) =>
              project.paymentStatus == PaymentStatus.outstanding ||
              project.paymentStatus == PaymentStatus.partiallyPaid,
        )
        .toList();
  }

  // Filter methods
  List<Project> getProjectsByPriority(Priority priority) {
    return _projects.where((project) => project.priority == priority).toList();
  }

  List<Project> getProjectsByClient(String clientName) {
    return _projects
        .where((project) => project.clientName == clientName)
        .toList();
  }

  List<Project> getProjectsByPaymentStatus(PaymentStatus status) {
    return _projects
        .where((project) => project.paymentStatus == status)
        .toList();
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
