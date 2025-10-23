import 'package:flutter/material.dart';
import '../../utils/performance_logger.dart';

/// Optimized MovingRow with AnimationController and Transform.translate
/// 
/// Performance Improvements:
/// - Uses Ticker-based AnimationController (frame-perfect timing, no drift)
/// - Transform.translate instead of AnimatedPositioned (GPU-accelerated)
/// - FadeTransition instead of SizeTransition (GPU-accelerated)
/// - Proper lifecycle management with animation status listeners
/// - Reduced rebuilds with AnimatedBuilder
class MovingRow extends StatefulWidget {
  final int delaySec;
  final bool reverse;
  final bool isMenuOpen;
  final Widget childMenu;
  final Widget childBackground;

  const MovingRow({
    super.key,
    required this.delaySec,
    required this.childMenu,
    required this.childBackground,
    required this.isMenuOpen,
    this.reverse = false,
  });

  @override
  State<MovingRow> createState() => _MovingRowState();
}

class _MovingRowState extends State<MovingRow> with SingleTickerProviderStateMixin {
  late final List<Widget> menuList;
  late final List<Widget> backgroundList;
  late final String _performanceId;
  late AnimationController _controller;
  late Animation<double> _animation;
  
  bool _isDisposed = false;
  int _buildCount = 0;
  int _cycleCount = 0;

  @override
  void initState() {
    super.initState();
    _performanceId = 'MovingRow_delay${widget.delaySec}_${widget.isMenuOpen ? "menu" : "bg"}';
    
    PerformanceLogger.logAnimation(_performanceId, 'Initializing', data: {
      'delay': widget.delaySec,
      'reverse': widget.reverse,
      'isMenuOpen': widget.isMenuOpen,
    });
    
    // Create widget lists once (immutable for better performance)
    menuList = List.generate(5, (index) => widget.childMenu, growable: false);
    backgroundList = List.generate(3, (index) => widget.childBackground, growable: false);
    
    // Initialize AnimationController with Ticker (frame-perfect timing)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Animation duration
    );
    
    // Create animation with easing curve
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    // Listen to animation status for automatic looping
    _controller.addStatusListener(_handleAnimationStatus);
    
    PerformanceLogger.logAnimation(_performanceId, 'Controller initialized', data: {
      'menuCount': menuList.length,
      'backgroundCount': backgroundList.length,
    });
    
    // Start animation after initial delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: widget.delaySec)).then((_) {
        if (mounted && !_isDisposed) {
          PerformanceLogger.logAnimation(_performanceId, 'Starting animation loop');
          _startAnimationCycle();
        }
      });
    });
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (!mounted || _isDisposed) return;
    
    if (status == AnimationStatus.completed) {
      // Animation forward completed, wait then reverse
      _cycleCount++;
      PerformanceLogger.logAnimation(_performanceId, 'Forward complete', data: {
        'cycle': _cycleCount,
      });
      
      Future.delayed(const Duration(seconds: 5)).then((_) {
        if (mounted && !_isDisposed) {
          _controller.reverse();
        }
      });
    } else if (status == AnimationStatus.dismissed) {
      // Animation reverse completed, wait then forward
      PerformanceLogger.logAnimation(_performanceId, 'Reverse complete', data: {
        'cycle': _cycleCount,
      });
      
      Future.delayed(const Duration(seconds: 5)).then((_) {
        if (mounted && !_isDisposed) {
          _controller.forward();
        }
      });
    }
  }

  void _startAnimationCycle() {
    if (widget.reverse) {
      _controller.value = 1.0;
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    PerformanceLogger.logAnimation(_performanceId, 'Disposing', data: {
      'total_builds': _buildCount,
      'total_cycles': _cycleCount,
    });
    
    _isDisposed = true;
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    
    // Only log every 60 builds to reduce overhead
    if (_buildCount % 60 == 0) {
      PerformanceLogger.startBuild(_performanceId);
    }
    
    // RepaintBoundary to isolate widget repaints
    final builtWidget = RepaintBoundary(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          // Use FadeTransition (GPU-accelerated) instead of SizeTransition (layout-heavy)
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: widget.isMenuOpen
            ? _buildInnerWidget(
                key: 'm',
                children: menuList,
              )
            : _buildInnerWidget(
                key: 'b',
                children: backgroundList,
              ),
      ),
    );
    
    if (_buildCount % 60 == 0) {
      PerformanceLogger.endBuild(_performanceId);
    }
    
    return builtWidget;
  }

  Widget _buildInnerWidget({required String key, required List<Widget> children}) {
    return SizedBox(
      key: Key(key),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate max translation distance (20% of width)
          final maxTranslation = constraints.maxWidth / 5;
          
          // Use AnimatedBuilder to only rebuild the Transform widget
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Calculate current translation based on animation value
              final translation = widget.reverse 
                  ? maxTranslation * (1 - _animation.value)
                  : maxTranslation * _animation.value;
              
              // Transform.translate is GPU-accelerated (no layout recalculation!)
              return Transform.translate(
                offset: Offset(translation, 0),
                child: child,
              );
            },
            // Child is not rebuilt, only the Transform changes
            child: RepaintBoundary(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: children,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

