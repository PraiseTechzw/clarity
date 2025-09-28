import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/project.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'clarity.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // Handle database downgrade if needed
    // For now, we'll just recreate the database
    await db.close();
    await deleteDatabase(join(await getDatabasesPath(), 'clarity.db'));
    _database = null;
    await database; // This will recreate the database
  }

  Future<void> _onCreate(Database db, int version) async {
    // Projects table
    await db.execute('''
      CREATE TABLE projects(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        clientName TEXT NOT NULL,
        budget REAL NOT NULL,
        deadline TEXT NOT NULL,
        priority TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        phases TEXT DEFAULT '[]',
        payments TEXT DEFAULT '[]',
        projectNotes TEXT DEFAULT '[]'
      )
    ''');

    // Phases table
    await db.execute('''
      CREATE TABLE phases(
        id TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        dueDate TEXT,
        FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        phaseId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        FOREIGN KEY (phaseId) REFERENCES phases (id) ON DELETE CASCADE
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments(
        id TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        reference TEXT,
        status TEXT NOT NULL DEFAULT 'paid',
        FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    // Notes table
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        projectId TEXT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // Clients table
    await db.execute('''
      CREATE TABLE clients(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        company TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        projectIds TEXT DEFAULT '[]'
      )
    ''');

    // Project-Client relationship table
    await db.execute('''
      CREATE TABLE project_clients(
        projectId TEXT NOT NULL,
        clientId TEXT NOT NULL,
        PRIMARY KEY (projectId, clientId),
        FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE,
        FOREIGN KEY (clientId) REFERENCES clients (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to projects table (with existence checks)
      await _addColumnIfNotExists(
        db,
        'projects',
        'phases',
        'TEXT DEFAULT "[]"',
      );
      await _addColumnIfNotExists(
        db,
        'projects',
        'payments',
        'TEXT DEFAULT "[]"',
      );
      await _addColumnIfNotExists(
        db,
        'projects',
        'projectNotes',
        'TEXT DEFAULT "[]"',
      );
      // Add new column to clients table
      await _addColumnIfNotExists(
        db,
        'clients',
        'projectIds',
        'TEXT DEFAULT "[]"',
      );
    }
    
    if (oldVersion < 3) {
      // Add status column to payments table
      await _addColumnIfNotExists(
        db,
        'payments',
        'status',
        'TEXT NOT NULL DEFAULT "paid"',
      );
    }
  }

  Future<void> _addColumnIfNotExists(
    Database db,
    String tableName,
    String columnName,
    String columnDefinition,
  ) async {
    try {
      // Check if column exists by querying table info
      final result = await db.rawQuery("PRAGMA table_info($tableName)");
      final columnExists = result.any((column) => column['name'] == columnName);

      if (!columnExists) {
        await db.execute(
          'ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition',
        );
      }
    } catch (e) {
      // If there's an error checking, try to add the column anyway
      // This handles cases where the table might not exist yet
      try {
        await db.execute(
          'ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition',
        );
      } catch (addError) {
        // Column might already exist, ignore the error
        print(
          'Column $columnName might already exist in $tableName: $addError',
        );
      }
    }
  }

  // Project CRUD operations
  Future<String> insertProject(Project project) async {
    final db = await database;
    await db.insert('projects', project.toJson());

    // Insert phases
    for (final phase in project.phases) {
      // Create phase data without tasks (tasks are stored separately)
      final phaseData = {
        'id': phase.id,
        'name': phase.name,
        'description': phase.description,
        'dueDate': phase.dueDate?.toIso8601String(),
        'projectId': project.id,
      };
      await db.insert('phases', phaseData);

      // Insert tasks for each phase
      for (final task in phase.tasks) {
        await db.insert('tasks', {
          ...task.toJson(),
          'phaseId': phase.id,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    // Insert payments
    for (final payment in project.payments) {
      await db.insert('payments', {
        ...payment.toJson(),
        'projectId': project.id,
      });
    }

    // Insert project notes
    for (final note in project.projectNotes) {
      await db.insert('notes', {...note.toJson(), 'projectId': project.id});
    }

    return project.id;
  }

  Future<List<Project>> getAllProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> projectMaps = await db.query('projects');

    List<Project> projects = [];

    for (final projectMap in projectMaps) {
      final projectId = projectMap['id'];

      // Get phases for this project
      final phaseMaps = await db.query(
        'phases',
        where: 'projectId = ?',
        whereArgs: [projectId],
      );

      List<Phase> phases = [];
      for (final phaseMap in phaseMaps) {
        final phaseId = phaseMap['id'];

        // Get tasks for this phase
        final taskMaps = await db.query(
          'tasks',
          where: 'phaseId = ?',
          whereArgs: [phaseId],
        );

        List<Task> tasks = taskMaps
            .map((taskMap) => Task.fromJson(taskMap))
            .toList();

        phases.add(
          Phase.fromJson({
            ...phaseMap,
            'tasks': tasks.map((task) => task.toJson()).toList(),
          }),
        );
      }

      // Get payments for this project
      final paymentMaps = await db.query(
        'payments',
        where: 'projectId = ?',
        whereArgs: [projectId],
      );
      List<Payment> payments = paymentMaps
          .map((paymentMap) => Payment.fromJson(paymentMap))
          .toList();

      // Get notes for this project
      final noteMaps = await db.query(
        'notes',
        where: 'projectId = ?',
        whereArgs: [projectId],
      );
      List<Note> notes = noteMaps
          .map((noteMap) => Note.fromJson(noteMap))
          .toList();

      projects.add(
        Project.fromJson({
          ...projectMap,
          'phases': phases.map((phase) => phase.toJson()).toList(),
          'payments': payments.map((payment) => payment.toJson()).toList(),
          'projectNotes': notes.map((note) => note.toJson()).toList(),
        }),
      );
    }

    return projects;
  }

  Future<Project?> getProject(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> projectMaps = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (projectMaps.isEmpty) return null;

    final projectMap = projectMaps.first;

    // Get phases for this project
    final phaseMaps = await db.query(
      'phases',
      where: 'projectId = ?',
      whereArgs: [id],
    );

    List<Phase> phases = [];
    for (final phaseMap in phaseMaps) {
      final phaseId = phaseMap['id'];

      // Get tasks for this phase
      final taskMaps = await db.query(
        'tasks',
        where: 'phaseId = ?',
        whereArgs: [phaseId],
      );

      List<Task> tasks = taskMaps
          .map((taskMap) => Task.fromJson(taskMap))
          .toList();

      phases.add(
        Phase.fromJson({
          ...phaseMap,
          'tasks': tasks.map((task) => task.toJson()).toList(),
        }),
      );
    }

    // Get payments for this project
    final paymentMaps = await db.query(
      'payments',
      where: 'projectId = ?',
      whereArgs: [id],
    );
    List<Payment> payments = paymentMaps
        .map((paymentMap) => Payment.fromJson(paymentMap))
        .toList();

    // Get notes for this project
    final noteMaps = await db.query(
      'notes',
      where: 'projectId = ?',
      whereArgs: [id],
    );
    List<Note> notes = noteMaps
        .map((noteMap) => Note.fromJson(noteMap))
        .toList();

    return Project.fromJson({
      ...projectMap,
      'phases': phases.map((phase) => phase.toJson()).toList(),
      'payments': payments.map((payment) => payment.toJson()).toList(),
      'projectNotes': notes.map((note) => note.toJson()).toList(),
    });
  }

  Future<int> updateProject(Project project) async {
    final db = await database;

    // Create a simplified project data for database update
    final projectData = {
      'id': project.id,
      'name': project.name,
      'clientName': project.clientName,
      'budget': project.budget,
      'deadline': project.deadline.toIso8601String(),
      'priority': project.priority.name,
      'notes': project.notes,
      'createdAt': project.createdAt.toIso8601String(),
      'phases': '[]', // These are handled separately
      'payments': '[]',
      'projectNotes': '[]',
    };

    // Update project
    int result = await db.update(
      'projects',
      projectData,
      where: 'id = ?',
      whereArgs: [project.id],
    );

    // Delete existing tasks first (to avoid foreign key constraints)
    await db.delete(
      'tasks',
      where: 'phaseId IN (SELECT id FROM phases WHERE projectId = ?)',
      whereArgs: [project.id],
    );

    // Delete existing phases, payments, and notes
    await db.delete('phases', where: 'projectId = ?', whereArgs: [project.id]);
    await db.delete(
      'payments',
      where: 'projectId = ?',
      whereArgs: [project.id],
    );
    await db.delete('notes', where: 'projectId = ?', whereArgs: [project.id]);

    // Re-insert phases and tasks
    for (final phase in project.phases) {
      // Create phase data without tasks (tasks are stored separately)
      final phaseData = {
        'id': phase.id,
        'name': phase.name,
        'description': phase.description,
        'dueDate': phase.dueDate?.toIso8601String(),
        'projectId': project.id,
      };
      await db.insert('phases', phaseData);

      for (final task in phase.tasks) {
        await db.insert('tasks', {
          ...task.toJson(),
          'phaseId': phase.id,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    // Re-insert payments
    for (final payment in project.payments) {
      await db.insert('payments', {
        ...payment.toJson(),
        'projectId': project.id,
      });
    }

    // Re-insert notes
    for (final note in project.projectNotes) {
      await db.insert('notes', {...note.toJson(), 'projectId': project.id});
    }

    return result;
  }

  Future<int> deleteProject(String id) async {
    final db = await database;
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // Client CRUD operations
  Future<String> insertClient(Client client) async {
    final db = await database;
    await db.insert('clients', client.toJson());
    return client.id;
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    final List<Map<String, dynamic>> clientMaps = await db.query('clients');
    return clientMaps.map((clientMap) => Client.fromJson(clientMap)).toList();
  }

  Future<Client?> getClient(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> clientMaps = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (clientMaps.isEmpty) return null;
    return Client.fromJson(clientMaps.first);
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      client.toJson(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(String id) async {
    final db = await database;
    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }
}
