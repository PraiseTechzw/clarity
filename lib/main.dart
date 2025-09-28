import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/project_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/main_navigation.dart';
import 'widgets/sync_initialization_widget.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  runApp(const ClarityApp());
}

class ClarityApp extends StatelessWidget {
  const ClarityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final syncProvider = SyncProvider();
            // Set the auth provider reference after both are created
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              syncProvider.setAuthProvider(authProvider);
            });
            return syncProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final projectProvider = ProjectProvider();
            // Set the sync provider reference after both are created
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final syncProvider = Provider.of<SyncProvider>(context, listen: false);
              projectProvider.setSyncProvider(syncProvider);
            });
            return projectProvider;
          },
        ),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: Consumer3<AuthProvider, ThemeProvider, LocaleProvider>(
        builder: (context, authProvider, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Clarity - Project Manager',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1), // Indigo
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                elevation: 4,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                elevation: 4,
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const SyncInitializationWidget(child: MainNavigation()),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}