import 'package:flutter/material.dart';
import 'package:moving_text_background_new/features/menu/domain/entities/menu_entity.dart';
import '../../core/utils/performance_logger.dart';

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
  late Animation<double> _loopAnimation;
  late String _performanceId;
  int _buildCount = 0;

  @override
  void initState() {
    super.initState();
    _performanceId = 'FlipAnimation_${widget.id.name}';
    
    PerformanceLogger.logAnimation(_performanceId, 'Initializing');
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _loopAnimation = TweenSequence<double>([
      for (int i = 0; i < 1; i++) ...[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: -1.0),
          weight: 1,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -1.0, end: 1.0),
          weight: 1,
        ),
      ],
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    PerformanceLogger.logAnimation(_performanceId, 'Initialized');
  }

  @override
  void dispose() {
    PerformanceLogger.logAnimation(_performanceId, 'Disposing', data: {
      'total_builds': _buildCount,
    });
    _animationController.dispose();
    super.dispose();
  }

  Future<void> startAnimation(double tune) async {
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
      PerformanceLogger.logAnimation(_performanceId, 'Animation completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    PerformanceLogger.startBuild(_performanceId);
    
    final widget = AnimatedBuilder(
      animation: _loopAnimation,
      builder: (context, child) {
        // Use RepaintBoundary to isolate transform repaints
        return RepaintBoundary(
          child: Transform(
            alignment: Alignment.center,
            // Transform is GPU-accelerated and efficient
            transform: Matrix4.identity()..scale(1.0, _loopAnimation.value),
            child: child,
          ),
        );
      },
      child: this.widget.child,
    );
    
    PerformanceLogger.endBuild(_performanceId);
    return widget;
  }
}

