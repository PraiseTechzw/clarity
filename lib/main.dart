import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/project_provider.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const ClarityApp());
}

class ClarityApp extends StatelessWidget {
  const ClarityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProjectProvider(),
      child: MaterialApp(
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
        home: const MainNavigation(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
