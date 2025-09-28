import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/sync_provider.dart';
import '../widgets/sync_animation_widget.dart';

class SyncInitializationWidget extends StatefulWidget {
  final Widget child;

  const SyncInitializationWidget({super.key, required this.child});

  @override
  State<SyncInitializationWidget> createState() =>
      _SyncInitializationWidgetState();
}

class _SyncInitializationWidgetState extends State<SyncInitializationWidget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Defer initialization until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    if (!mounted) return;

    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      final syncProvider = Provider.of<SyncProvider>(context, listen: false);

      // Initialize project provider with sync provider with timeout
      await projectProvider.initializeWithSync(syncProvider).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Continue even if sync initialization times out
          if (kDebugMode) {
            print('Sync initialization timed out, continuing...');
          }
        },
      );
    } catch (e) {
      // Continue even if there's an error
      if (kDebugMode) {
        print('Error during sync initialization: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SyncAnimationWidget(
                isSyncing: true,
                status: 'Initializing sync...',
                size: 48,
              ),
              const SizedBox(height: 24),
              Text(
                'Setting up cloud sync',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we connect to the cloud',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
