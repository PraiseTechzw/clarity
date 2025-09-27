import 'package:flutter/material.dart';

enum Priority { high, medium, low }

enum PaymentStatus { paid, outstanding, partiallyPaid }

class Project {
  final String id;
  final String name;
  final String clientName;
  final double budget;
  final DateTime deadline;
  final Priority priority;
  final String? notes;
  final DateTime createdAt;
  final List<Phase> phases;
  final List<Payment> payments;
  final List<Note> projectNotes;

  Project({
    required this.id,
    required this.name,
    required this.clientName,
    required this.budget,
    required this.deadline,
    required this.priority,
    this.notes,
    required this.createdAt,
    this.phases = const [],
    this.payments = const [],
    this.projectNotes = const [],
  });

  double get totalPaid =>
      payments.fold(0.0, (sum, payment) => sum + payment.amount);
  double get outstandingBalance => budget - totalPaid;
  PaymentStatus get paymentStatus {
    if (totalPaid == 0) return PaymentStatus.outstanding;
    if (totalPaid >= budget) return PaymentStatus.paid;
    return PaymentStatus.partiallyPaid;
  }

  double get progressPercentage {
    if (phases.isEmpty) return 0.0;
    final totalTasks = phases.fold(0, (sum, phase) => sum + phase.tasks.length);
    if (totalTasks == 0) return 0.0;
    final completedTasks = phases.fold(
      0,
      (sum, phase) =>
          sum + phase.tasks.where((task) => task.isCompleted).length,
    );
    return (completedTasks / totalTasks) * 100;
  }

  int get daysUntilDeadline {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }

  bool get isOverdue => daysUntilDeadline < 0;

  Color get priorityColor {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  Project copyWith({
    String? id,
    String? name,
    String? clientName,
    double? budget,
    DateTime? deadline,
    Priority? priority,
    String? notes,
    DateTime? createdAt,
    List<Phase>? phases,
    List<Payment>? payments,
    List<Note>? projectNotes,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      clientName: clientName ?? this.clientName,
      budget: budget ?? this.budget,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      phases: phases ?? this.phases,
      payments: payments ?? this.payments,
      projectNotes: projectNotes ?? this.projectNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'clientName': clientName,
      'budget': budget,
      'deadline': deadline.toIso8601String(),
      'priority': priority.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'phases': phases.map((phase) => phase.toJson()).toList(),
      'payments': payments.map((payment) => payment.toJson()).toList(),
      'projectNotes': projectNotes.map((note) => note.toJson()).toList(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      clientName: json['clientName'],
      budget: json['budget'].toDouble(),
      deadline: DateTime.parse(json['deadline']),
      priority: Priority.values.firstWhere((p) => p.name == json['priority']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      phases:
          (json['phases'] as List<dynamic>?)
              ?.map((phase) => Phase.fromJson(phase))
              .toList() ??
          [],
      payments:
          (json['payments'] as List<dynamic>?)
              ?.map((payment) => Payment.fromJson(payment))
              .toList() ??
          [],
      projectNotes:
          (json['projectNotes'] as List<dynamic>?)
              ?.map((note) => Note.fromJson(note))
              .toList() ??
          [],
    );
  }
}

class Phase {
  final String id;
  final String name;
  final String? description;
  final List<Task> tasks;
  final DateTime? dueDate;

  Phase({
    required this.id,
    required this.name,
    this.description,
    this.tasks = const [],
    this.dueDate,
  });

  double get progressPercentage {
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return (completedTasks / tasks.length) * 100;
  }

  Phase copyWith({
    String? id,
    String? name,
    String? description,
    List<Task>? tasks,
    DateTime? dueDate,
  }) {
    return Phase(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tasks: tasks ?? this.tasks,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Phase.fromJson(Map<String, dynamic> json) {
    return Phase(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((task) => Task.fromJson(task))
              .toList() ??
          [],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
  });

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

class Payment {
  final String id;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? reference;
  final PaymentStatus status;

  Payment({
    required this.id,
    required this.amount,
    required this.date,
    this.notes,
    this.reference,
    this.status = PaymentStatus.paid,
  });

  Payment copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? notes,
    String? reference,
    PaymentStatus? status,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      reference: reference ?? this.reference,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'reference': reference,
      'status': status.name,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      reference: json['reference'],
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.paid,
      ),
    );
  }
}

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

class Client {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? company;
  final String? notes;
  final DateTime createdAt;
  final List<String> projectIds;

  Client({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.notes,
    required this.createdAt,
    this.projectIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'projectIds': projectIds,
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      company: json['company'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      projectIds: List<String>.from(json['projectIds'] ?? []),
    );
  }
}
