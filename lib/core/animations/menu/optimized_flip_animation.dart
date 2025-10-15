import 'package:flutter/material.dart';
import 'package:moving_text_background_new/features/menu/domain/entities/menu_entity.dart';
import 'package:vector_math/vector_math_64.dart';
import '../../utils/performance_logger.dart';

class OptimizedFlipAnimation extends StatefulWidget {
  final Widget child;
  final MenuItems id;

  const OptimizedFlipAnimation({
    super.key,
    required this.child,
    required this.id,
  });

  @override
  State<OptimizedFlipAnimation> createState() => _OptimizedFlipAnimationState();
}

class _OptimizedFlipAnimationState extends State<OptimizedFlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  static const String _performanceId = 'OptimizedFlipAnimation';

  @override
  void initState() {
    super.initState();
    PerformanceLogger.logAnimation(_performanceId, 'Initializing flip animation');
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Use TweenSequence for smooth flip animation
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: -1.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -1.0, end: 1.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> startAnimation(double tune) async {
    PerformanceLogger.logAnimation(_performanceId, 'Starting flip animation', data: {
      'tune': tune,
      'id': widget.id.name,
    });
    
    _controller.reset();
    
    // Calculate delay based on tune value
    final delay = ((1 - tune) * 1000).toInt();
    await Future.delayed(Duration(milliseconds: delay));
    
    if (mounted) {
      await _controller.forward();
      PerformanceLogger.logAnimation(_performanceId, 'Flip animation completed');
    }
  }

  @override
  void dispose() {
    PerformanceLogger.logAnimation(_performanceId, 'Disposing flip animation');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scaleByVector3(Vector3(1.0, _animation.value, 1.0)),
            child: widget.child,
          );
        },
      ),
    );
  }
}
