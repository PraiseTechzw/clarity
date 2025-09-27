import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _currentUser;
  String? _userEmail;
  String? _userName;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get currentUser => _currentUser;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      _currentUser = prefs.getString('currentUser');
      _userEmail = prefs.getString('userEmail');
      _userName = prefs.getString('userName');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading auth state: $e');
      }
    }
  }

  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', _isAuthenticated);
      if (_currentUser != null) {
        await prefs.setString('currentUser', _currentUser!);
      }
      if (_userEmail != null) {
        await prefs.setString('userEmail', _userEmail!);
      }
      if (_userName != null) {
        await prefs.setString('userName', _userName!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving auth state: $e');
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, accept any email/password combination
      // In a real app, this would make an API call to your backend
      if (email.isNotEmpty && password.isNotEmpty) {
        _isAuthenticated = true;
        _currentUser = email;
        _userEmail = email;
        _userName = email.split('@')[0]; // Use email prefix as name for demo
        
        await _saveAuthState();
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _userEmail = null;
      _userName = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, accept any valid email/password combination
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        _isAuthenticated = true;
        _currentUser = email;
        _userEmail = email;
        _userName = name;
        
        await _saveAuthState();
      } else {
        throw Exception('Invalid registration data');
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _userEmail = null;
      _userName = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, always succeed
      if (email.isNotEmpty) {
        // In a real app, this would send an email
        if (kDebugMode) {
          print('Password reset email sent to: $email');
        }
      } else {
        throw Exception('Invalid email');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _isAuthenticated = false;
      _currentUser = null;
      _userEmail = null;
      _userName = null;
      
      // Clear stored auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isAuthenticated');
      await prefs.remove('currentUser');
      await prefs.remove('userEmail');
      await prefs.remove('userName');
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String name, String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _userName = name;
      _userEmail = email;
      _currentUser = email;
      
      await _saveAuthState();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, always succeed
      if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
        // Password changed successfully
        if (kDebugMode) {
          print('Password changed successfully');
        }
      } else {
        throw Exception('Invalid password data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error changing password: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
