import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  // Google OAuth
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  static String get googleClientSecret =>
      dotenv.env['GOOGLE_CLIENT_SECRET'] ?? '';

  // GitHub OAuth
  static String get githubClientId => dotenv.env['GITHUB_CLIENT_ID'] ?? '';
  static String get githubClientSecret =>
      dotenv.env['GITHUB_CLIENT_SECRET'] ?? '';

  // Firebase
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  // Helper method to check if all required variables are loaded
  static bool get isGoogleConfigured =>
      googleClientId.isNotEmpty && googleClientSecret.isNotEmpty;

  static bool get isGitHubConfigured =>
      githubClientId.isNotEmpty && githubClientSecret.isNotEmpty;
}
