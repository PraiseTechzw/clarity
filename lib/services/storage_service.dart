import 'dart:io';
import 'package:clarity/models/project.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../providers/project_provider.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = await getTemporaryDirectory();

      // Get database size
      final dbPath = join(await getDatabasesPath(), 'clarity.db');
      final dbFile = File(dbPath);
      final dbSize = await dbFile.exists() ? await dbFile.length() : 0;

      // Get cache size
      final cacheSize = await _getDirectorySize(cacheDir);

      // Get app documents size
      final appSize = await _getDirectorySize(appDir);

      // Get shared preferences size (estimate)
      final prefs = await SharedPreferences.getInstance();
      final prefsSize = await _getSharedPreferencesSize(prefs);

      return {
        'database': _formatBytes(dbSize),
        'cache': _formatBytes(cacheSize),
        'documents': _formatBytes(appSize),
        'preferences': _formatBytes(prefsSize),
        'total': _formatBytes(dbSize + cacheSize + appSize + prefsSize),
        'databaseBytes': dbSize,
        'cacheBytes': cacheSize,
        'documentsBytes': appSize,
        'preferencesBytes': prefsSize,
        'totalBytes': dbSize + cacheSize + appSize + prefsSize,
      };
    } catch (e) {
      debugPrint('Error getting storage info: $e');
      return {
        'database': '0 B',
        'cache': '0 B',
        'documents': '0 B',
        'preferences': '0 B',
        'total': '0 B',
        'databaseBytes': 0,
        'cacheBytes': 0,
        'documentsBytes': 0,
        'preferencesBytes': 0,
        'totalBytes': 0,
      };
    }
  }

  Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      if (await dir.exists()) {
        await for (final file in dir.list(recursive: true)) {
          if (file is File) {
            size += await file.length();
          }
        }
      }
    } catch (e) {
      debugPrint('Error calculating directory size: $e');
    }
    return size;
  }

  Future<int> _getSharedPreferencesSize(SharedPreferences prefs) async {
    // This is an estimate since SharedPreferences doesn't expose size directly
    int size = 0;
    final keys = prefs.getKeys();
    for (final key in keys) {
      size += key.length * 2; // Rough estimate for key size
      final value = prefs.get(key);
      if (value is String) {
        size += value.length * 2;
      } else if (value is int) {
        size += 8;
      } else if (value is bool) {
        size += 1;
      } else if (value is double) {
        size += 8;
      } else if (value is List<String>) {
        size += value.join().length * 2;
      }
    }
    return size;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<bool> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }
      return true;
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      return false;
    }
  }

  Future<bool> clearAllData() async {
    try {
      // Clear cache
      await clearCache();

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear database
      final dbPath = join(await getDatabasesPath(), 'clarity.db');
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      return true;
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> exportData(
    ProjectProvider projectProvider,
  ) async {
    try {
      final projects = projectProvider.projects;
      final clients = projectProvider.clients;

      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'projects': projects.map((p) => p.toJson()).toList(),
        'clients': clients.map((c) => c.toJson()).toList(),
        'metadata': {
          'totalProjects': projects.length,
          'totalClients': clients.length,
          'appVersion': '1.0.0',
        },
      };

      return exportData;
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return {};
    }
  }

  Future<bool> importData(
    Map<String, dynamic> data,
    ProjectProvider projectProvider,
  ) async {
    try {
      if (data['projects'] != null) {
        final projects = (data['projects'] as List)
            .map((p) => Project.fromJson(p))
            .toList();

        for (final project in projects) {
          await projectProvider.addProject(project);
        }
      }

      if (data['clients'] != null) {
        final clients = (data['clients'] as List)
            .map((c) => Client.fromJson(c))
            .toList();

        for (final client in clients) {
          await projectProvider.addClient(client);
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }
}
