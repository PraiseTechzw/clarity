import 'package:flutter/material.dart';

class SyncAnimationWidget extends StatefulWidget {
  final bool isSyncing;
  final String? status;
  final double size;
  final Color? color;
  final bool showText;

  const SyncAnimationWidget({
    super.key,
    required this.isSyncing,
    this.status,
    this.size = 24.0,
    this.color,
    this.showText = true,
  });

  @override
  State<SyncAnimationWidget> createState() => _SyncAnimationWidgetState();
}

class _SyncAnimationWidgetState extends State<SyncAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    if (widget.isSyncing) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(SyncAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSyncing && !oldWidget.isSyncing) {
      _startAnimations();
    } else if (!widget.isSyncing && oldWidget.isSyncing) {
      _stopAnimations();
    }
  }

  void _startAnimations() {
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  void _stopAnimations() {
    _rotationController.stop();
    _pulseController.stop();
    _fadeController.reverse();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _pulseAnimation,
        _fadeAnimation,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Icon(
                    Icons.sync,
                    size: widget.size,
                    color: widget.isSyncing ? color : Colors.grey,
                  ),
                ),
              ),
              if (widget.showText && widget.status != null) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: Text(
                    widget.status!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: widget.isSyncing ? color : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class SyncStatusIndicator extends StatelessWidget {
  final bool isSyncing;
  final String? status;
  final bool isOnline;
  final bool isSignedIn;

  const SyncStatusIndicator({
    super.key,
    required this.isSyncing,
    this.status,
    required this.isOnline,
    required this.isSignedIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isSignedIn) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            'Offline',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (!isOnline) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 16, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            'Offline',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (isSyncing) {
      return SyncAnimationWidget(
        isSyncing: true,
        status: status,
        size: 16,
        showText: true,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_done, size: 16, color: Colors.green),
        const SizedBox(width: 4),
        Text(
          'Synced',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SyncProgressIndicator extends StatefulWidget {
  final bool isVisible;
  final String message;
  final double progress;

  const SyncProgressIndicator({
    super.key,
    required this.isVisible,
    required this.message,
    this.progress = 0.0,
  });

  @override
  State<SyncProgressIndicator> createState() => _SyncProgressIndicatorState();
}

class _SyncProgressIndicatorState extends State<SyncProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(SyncProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animation.value) * 100),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SyncAnimationWidget(
                    isSyncing: true,
                    size: 20,
                    showText: false,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        if (widget.progress > 0) ...[
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: widget.progress,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
