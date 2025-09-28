import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _currentUser;
  String? _userEmail;
  String? _userName;
  String? _userPhotoUrl;
  String? _authProvider;
  String? _accessToken;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get currentUser => _currentUser;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userPhotoUrl => _userPhotoUrl;
  String? get authProvider => _authProvider;
  String? get accessToken => _accessToken;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      _currentUser = prefs.getString('currentUser');
      _userEmail = prefs.getString('userEmail');
      _userName = prefs.getString('userName');
      _userPhotoUrl = prefs.getString('userPhotoUrl');
      _authProvider = prefs.getString('authProvider');
      _accessToken = prefs.getString('accessToken');

      // Validate session if authenticated
      if (_isAuthenticated && _currentUser != null) {
        final token = prefs.getString('authToken');
        final loginTimestamp = prefs.getInt('loginTimestamp');

        if (token == null) {
          // Session expired or invalid
          await _clearAuthState();
        } else if (loginTimestamp != null) {
          // Check if session is older than 30 days (optional)
          final sessionAge =
              DateTime.now().millisecondsSinceEpoch - loginTimestamp;
          const maxSessionAge =
              30 * 24 * 60 * 60 * 1000; // 30 days in milliseconds

          if (sessionAge > maxSessionAge) {
            // Session expired
            await _clearAuthState();
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (kDebugMode) {
        print('Error loading auth state: $e');
      }
      notifyListeners();
    }
  }

  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', _isAuthenticated);
      await prefs.setString(
        'authToken',
        'dummy_token_for_${_userEmail ?? 'user'}',
      );

      if (_currentUser != null) {
        await prefs.setString('currentUser', _currentUser!);
      }
      if (_userEmail != null) {
        await prefs.setString('userEmail', _userEmail!);
      }
      if (_userName != null) {
        await prefs.setString('userName', _userName!);
      }
      if (_userPhotoUrl != null) {
        await prefs.setString('userPhotoUrl', _userPhotoUrl!);
      }
      if (_authProvider != null) {
        await prefs.setString('authProvider', _authProvider!);
      }
      if (_accessToken != null) {
        await prefs.setString('accessToken', _accessToken!);
      }

      // Save login timestamp for session management
      await prefs.setInt(
        'loginTimestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving auth state: $e');
      }
    }
  }

  Future<void> _clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isAuthenticated');
      await prefs.remove('currentUser');
      await prefs.remove('userEmail');
      await prefs.remove('userName');
      await prefs.remove('userPhotoUrl');
      await prefs.remove('authProvider');
      await prefs.remove('accessToken');
      await prefs.remove('authToken');
      await prefs.remove('loginTimestamp');

      _isAuthenticated = false;
      _currentUser = null;
      _userEmail = null;
      _userName = null;
      _userPhotoUrl = null;
      _authProvider = null;
      _accessToken = null;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing auth state: $e');
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

      // Clear all auth state
      await _clearAuthState();
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

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
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

  /// Google Sign-In
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final authService = AuthService();
      final result = await authService.signInWithGoogle();

      if (result.success && result.user != null) {
        _isAuthenticated = true;
        _currentUser = result.user!.id;
        _userEmail = result.user!.email;
        _userName = result.user!.name;
        _userPhotoUrl = result.user!.photoUrl;
        _authProvider = result.user!.provider;
        _accessToken = result.user!.accessToken;

        await _saveAuthState();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        if (kDebugMode) {
          print('Google sign-in failed: ${result.error}');
        }
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Google sign-in error: $e');
      }
      return false;
    }
  }

  /// GitHub Sign-In
  Future<bool> signInWithGitHub() async {
    _isLoading = true;
    notifyListeners();

    try {
      final authService = AuthService();
      final result = await authService.signInWithGitHub();

      if (result.success && result.user != null) {
        _isAuthenticated = true;
        _currentUser = result.user!.id;
        _userEmail = result.user!.email;
        _userName = result.user!.name;
        _userPhotoUrl = result.user!.photoUrl;
        _authProvider = result.user!.provider;
        _accessToken = result.user!.accessToken;

        await _saveAuthState();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        if (kDebugMode) {
          print('GitHub sign-in failed: ${result.error}');
        }
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('GitHub sign-in error: $e');
      }
      return false;
    }
  }

  /// Enhanced sign out that handles provider-specific logout
  Future<void> enhancedSignOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Sign out from provider-specific services
      if (_authProvider == 'google') {
        final authService = AuthService();
        await authService.signOutGoogle();
      }
      // Add GitHub sign-out logic here if needed

      // Clear all auth state
      await _clearAuthState();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Enhanced sign-out error: $e');
      }
    }
  }
}
