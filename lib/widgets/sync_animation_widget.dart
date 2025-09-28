import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';
import '../services/network_service.dart';

class SyncAnimationWidget extends StatefulWidget {
  final bool isSyncing;
  final String? status;
  final double size;
  final Color? color;
  final bool showText;
  final bool showProgress;
  final bool showNetworkStatus;

  const SyncAnimationWidget({
    super.key,
    required this.isSyncing,
    this.status,
    this.size = 24.0,
    this.color,
    this.showText = true,
    this.showProgress = false,
    this.showNetworkStatus = false,
  });

  @override
  State<SyncAnimationWidget> createState() => _SyncAnimationWidgetState();
}

class _SyncAnimationWidgetState extends State<SyncAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _progressController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Rotation animation for sync icon
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Pulse animation for active sync
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Fade animation for status text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(SyncAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing != oldWidget.isSyncing) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    if (widget.isSyncing) {
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
      _fadeController.forward();
    } else {
      _rotationController.stop();
      _pulseController.stop();
      _fadeController.reverse();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SyncProvider, NetworkService>(
      builder: (context, syncProvider, networkService, child) {
        final isOnline = networkService.isOnline;
        final isSignedIn = syncProvider.isSignedIn;
        final syncProgress = syncProvider.syncProgress;
        final hasErrors = syncProvider.hasErrors;
        final canRetry = syncProvider.canRetry;

        // Update progress animation
        _progressController.animateTo(syncProgress);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main sync indicator
            _buildSyncIndicator(
              context,
              isOnline,
              isSignedIn,
              hasErrors,
              canRetry,
            ),

            // Progress bar
            if (widget.showProgress && widget.isSyncing)
              _buildProgressBar(context, syncProgress),

            // Status text
            if (widget.showText)
              _buildStatusText(
                context,
                isOnline,
                isSignedIn,
                hasErrors,
                canRetry,
              ),

            // Network status
            if (widget.showNetworkStatus)
              _buildNetworkStatus(context, networkService),
          ],
        );
      },
    );
  }

  Widget _buildSyncIndicator(
    BuildContext context,
    bool isOnline,
    bool isSignedIn,
    bool hasErrors,
    bool canRetry,
  ) {
    Color iconColor;
    IconData iconData;
    bool shouldAnimate = false;

    if (!isSignedIn) {
      iconColor = Colors.grey;
      iconData = Icons.cloud_off;
    } else if (!isOnline) {
      iconColor = Colors.orange;
      iconData = Icons.cloud_off;
    } else if (hasErrors) {
      iconColor = canRetry ? Colors.orange : Colors.red;
      iconData = canRetry ? Icons.refresh : Icons.error;
      shouldAnimate = canRetry;
    } else if (widget.isSyncing) {
      iconColor = Theme.of(context).primaryColor;
      iconData = Icons.sync;
      shouldAnimate = true;
    } else {
      iconColor = Colors.green;
      iconData = Icons.cloud_done;
    }

    Widget iconWidget = Icon(iconData, size: widget.size, color: iconColor);

    if (shouldAnimate) {
      iconWidget = AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                );
              },
              child: iconWidget,
            ),
          );
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconColor.withOpacity(0.1),
        border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
      ),
      child: iconWidget,
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    return Container(
      width: widget.size * 2,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(
    BuildContext context,
    bool isOnline,
    bool isSignedIn,
    bool hasErrors,
    bool canRetry,
  ) {
    String statusText = widget.status ?? 'Ready';

    if (!isSignedIn) {
      statusText = 'Offline';
    } else if (!isOnline) {
      statusText = 'No Connection';
    } else if (hasErrors) {
      statusText = canRetry ? 'Sync Failed - Tap to Retry' : 'Sync Error';
    } else if (widget.isSyncing) {
      statusText = 'Syncing...';
    } else {
      statusText = 'Synced';
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(top: 4),
            child: Text(
              statusText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getStatusTextColor(
                  context,
                  isOnline,
                  isSignedIn,
                  hasErrors,
                ),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkStatus(
    BuildContext context,
    NetworkService networkService,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: networkService.isOnline
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: networkService.isOnline
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            networkService.isOnline ? Icons.wifi : Icons.wifi_off,
            size: 12,
            color: networkService.isOnline ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            networkService.connectionTypeString,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: networkService.isOnline ? Colors.green : Colors.red,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusTextColor(
    BuildContext context,
    bool isOnline,
    bool isSignedIn,
    bool hasErrors,
  ) {
    if (!isSignedIn) {
      return Colors.grey;
    } else if (!isOnline) {
      return Colors.orange;
    } else if (hasErrors) {
      return Colors.red;
    } else if (widget.isSyncing) {
      return Theme.of(context).primaryColor;
    } else {
      return Colors.green;
    }
  }
}

class SyncStatusIndicator extends StatelessWidget {
  final bool isSyncing;
  final String? status;
  final double size;
  final Color? color;
  final bool showText;
  final bool showProgress;
  final bool showNetworkStatus;

  const SyncStatusIndicator({
    super.key,
    required this.isSyncing,
    this.status,
    this.size = 24.0,
    this.color,
    this.showText = true,
    this.showProgress = false,
    this.showNetworkStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return SyncAnimationWidget(
      isSyncing: isSyncing,
      status: status,
      size: size,
      color: color,
      showText: showText,
      showProgress: showProgress,
      showNetworkStatus: showNetworkStatus,
    );
  }
}

class SyncProgressIndicator extends StatelessWidget {
  final double progress;
  final String? status;
  final bool isActive;
  final Color? color;

  const SyncProgressIndicator({
    super.key,
    required this.progress,
    this.status,
    this.isActive = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.withOpacity(0.3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: color ?? Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status ?? 'Syncing...',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color ?? Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Activity indicator
          if (isActive) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
