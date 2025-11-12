import 'package:flutter/material.dart';
import '../../utils/performance_logger.dart';
import '../../performance/performance_boost.dart';

/// Enhanced MovingRow with performance optimizations
/// Maintains exact same behavior but with better performance
class EnhancedMovingRow extends StatefulWidget {
  final int delaySec;
  final bool reverse;
  final bool isMenuOpen;
  final Widget childMenu;
  final Widget childBackground;
  final Animation<double>? sharedAnimation;

  const EnhancedMovingRow({
    super.key,
    required this.delaySec,
    required this.childMenu,
    required this.childBackground,
    required this.isMenuOpen,
    this.reverse = false,
    this.sharedAnimation,
  });

  @override
  State<EnhancedMovingRow> createState() => _EnhancedMovingRowState();
}

class _EnhancedMovingRowState extends State<EnhancedMovingRow> 
    with SingleTickerProviderStateMixin, PerformanceMonitorMixin {
  
  late final List<Widget> menuList;
  late final List<Widget> backgroundList;
  late final String _performanceId;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _ownsController = false;
  
  bool _isDisposed = false;
  bool? _lastMenuOpenState;
  Widget? _cachedWidget;

  @override
  void initState() {
    super.initState();
    _performanceId = 'EnhancedMovingRow_delay${widget.delaySec}_${widget.isMenuOpen ? "menu" : "bg"}';
    
    PerformanceLogger.logAnimation(_performanceId, 'Initializing Enhanced Version', data: {
      'delay': widget.delaySec,
      'reverse': widget.reverse,
      'isMenuOpen': widget.isMenuOpen,
    });
    
    // Create widget lists once (immutable for better performance)
    menuList = List.generate(5, (index) => widget.childMenu, growable: false);
    backgroundList = List.generate(3, (index) => widget.childBackground, growable: false);
    
    // Initialize Animation
    if (widget.sharedAnimation != null) {
      _animation = widget.sharedAnimation!;
      _ownsController = false;
    } else {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 30),
      );
      _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      );
      _ownsController = true;
    }
    
    // Start animation after initial delay
    if (_ownsController) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // GUARD: Check mounted before scheduling delayed animation
        if (!mounted) return;
        
        Future.delayed(Duration(seconds: widget.delaySec)).then((_) {
          // GUARD: Check mounted and not disposed before starting animation
          if (mounted && !_isDisposed) {
            _startAnimationCycle();
          }
        });
      });
    }
  }

  void _startAnimationCycle() {
    if (_ownsController) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    PerformanceLogger.logAnimation(_performanceId, 'Disposing Enhanced Version');
    
    // GUARD: Mark as disposed to prevent animation operations
    _isDisposed = true;
    
    // GUARD: Ensure animation controller is disposed properly
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget performanceBuild(BuildContext context) {
    // Use smart caching - only rebuild if menu state actually changed
    if (_lastMenuOpenState == widget.isMenuOpen && _cachedWidget != null) {
      return _cachedWidget!;
    }

    _lastMenuOpenState = widget.isMenuOpen;
    
    // Build with performance optimizations
    _cachedWidget = PerformanceBoost.withMemoryOptimization(
      child: RepaintBoundary(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800), // Smooth transition timing
          switchInCurve: Curves.easeInOutCubic, // Smoother curve
          switchOutCurve: Curves.easeInOutCubic, // Smoother curve
          transitionBuilder: (child, animation) {
            // Smooth cross-fade transition
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.05), // Subtle slide effect
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: widget.isMenuOpen
              ? _buildInnerWidget(
                  key: 'menu',
                  children: menuList,
                )
              : _buildInnerWidget(
                  key: 'background',
                  children: backgroundList,
                ),
        ),
      ),
    );

    return _cachedWidget!;
  }

  Widget _buildInnerWidget({required String key, required List<Widget> children}) {
    return PerformanceBoost.withCache(
      SizedBox(
        key: Key(key),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Optimized amplitude calculation
            final amplitude = constraints.maxWidth * 0.04; // Slightly reduced for smoother effect
            
            // Use performance-optimized AnimatedBuilder
            return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // Optimized animation calculation
                  final t = _animation.value;
                  final centered = (t - 0.5) * 2.0;
                  final directionSign = widget.reverse ? -1.0 : 1.0;
                  final dx = directionSign * amplitude * centered;
                  
                  // GPU-accelerated Transform
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  );
                },
                child: RepaintBoundary(
                  child: ClipRect(
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: OverflowBox(
                        alignment: Alignment.centerLeft,
                        minWidth: 0,
                        maxWidth: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: children,
                        ),
                      ),
                    ),
                  ),
                ),
              );
          },
        ),
      ),
      cacheKey: '$key-${widget.isMenuOpen}',
    );
  }
}