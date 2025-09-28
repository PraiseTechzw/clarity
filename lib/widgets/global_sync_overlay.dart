import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';
import 'sync_animation_widget.dart';

class GlobalSyncOverlay extends StatelessWidget {
  final Widget child;

  const GlobalSyncOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Consumer<SyncProvider>(
          builder: (context, syncProvider, child) {
            if (!syncProvider.isSyncing) return const SizedBox.shrink();

            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SyncProgressIndicator(
                progress: syncProvider.syncProgress,
                status: syncProvider.syncStatus,
                isActive: syncProvider.isSyncing,
              ),
            );
          },
        ),
      ],
    );
  }
}

class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              SyncStatusIndicator(
                isSyncing: syncProvider.isSyncing,
                status: syncProvider.syncStatus,
              ),
              const Spacer(),
              if (syncProvider.lastSyncTime != null)
                Text(
                  'Last sync: ${_formatTime(syncProvider.lastSyncTime!)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class SyncFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;

  const SyncFloatingActionButton({super.key, this.onPressed, this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        if (!syncProvider.isSignedIn || !syncProvider.isOnline) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: syncProvider.isSyncing ? null : onPressed,
          child: syncProvider.isSyncing
              ? SyncAnimationWidget(isSyncing: true, size: 24, showText: false)
              : this.child ?? const Icon(Icons.sync),
        );
      },
    );
  }
}
