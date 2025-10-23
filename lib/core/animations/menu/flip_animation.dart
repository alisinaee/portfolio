import 'package:flutter/material.dart';
import 'package:moving_text_background_new/features/menu/domain/entities/menu_entity.dart';
import '../../utils/performance_logger.dart';

/// Optimized FlipAnimation with enhanced performance
/// 
/// Performance Improvements:
/// - Cached TweenSequence to avoid recreation
/// - Optimized RepaintBoundary placement
/// - Reduced performance logging overhead
/// - Better lifecycle management
/// - GPU-accelerated Transform with optimized matrix operations
class FlipAnimation extends StatefulWidget {
  final Widget child;
  final MenuItems id;

  const FlipAnimation({
    super.key,
    required this.child,
    required this.id,
  });

  @override
  State<FlipAnimation> createState() => FlipAnimationState();
}

class FlipAnimationState extends State<FlipAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late String _performanceId;
  int _buildCount = 0;
  bool _isAnimating = false;

  // Static tween sequence to avoid recreation
  static final TweenSequence<double> _flipTween = TweenSequence<double>([
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: 1.0, end: -1.0),
      weight: 1,
    ),
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: -1.0, end: 1.0),
      weight: 1,
    ),
  ]);

  @override
  void initState() {
    super.initState();
    _performanceId = 'FlipAnimation_${widget.id.name}';
    
    if (_buildCount == 0) {
      PerformanceLogger.logAnimation(_performanceId, 'Initializing');
    }
    
    // Initialize AnimationController with Ticker
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Create animation with cached tween and curve
    _animation = _flipTween.animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (_buildCount == 0) {
      PerformanceLogger.logAnimation(_performanceId, 'Initialized');
    }
  }

  @override
  void dispose() {
    if (_buildCount > 0) {
      PerformanceLogger.logAnimation(_performanceId, 'Disposing', data: {
        'total_builds': _buildCount,
        'was_animating': _isAnimating,
      });
    }
    _animationController.dispose();
    super.dispose();
  }

  Future<void> startAnimation(double tune) async {
    if (_isAnimating) return; // Prevent overlapping animations
    
    _isAnimating = true;
    
    PerformanceLogger.logAnimation(_performanceId, 'Starting animation', data: {
      'tune': tune.toStringAsFixed(2),
      'delay_ms': ((1 - tune) * 1000).toInt(),
    });
    
    _animationController.reset();
    
    await Future.delayed(
      Duration(milliseconds: ((1 - tune) * 1000).toInt()),
    );
    
    if (mounted) {
      await _animationController.forward();
      _isAnimating = false;
      
      if (mounted) {
        PerformanceLogger.logAnimation(_performanceId, 'Animation completed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    
    // Only log every 60 builds to reduce overhead
    if (_buildCount % 60 == 0) {
      PerformanceLogger.startBuild(_performanceId);
    }
    
    // Use AnimatedBuilder to only rebuild the Transform widget
    final builtWidget = AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Use RepaintBoundary to isolate transform repaints
        return RepaintBoundary(
          child: Transform(
            alignment: Alignment.center,
            // Optimized matrix operation - GPU-accelerated
            transform: Matrix4.identity()..scale(1.0, _animation.value),
            // Filter quality for better performance
            filterQuality: FilterQuality.medium,
            child: child,
          ),
        );
      },
      // Child is cached and not rebuilt on every animation frame
      child: widget.child,
    );
    
    if (_buildCount % 60 == 0) {
      PerformanceLogger.endBuild(_performanceId);
    }
    
    return builtWidget;
  }
}

