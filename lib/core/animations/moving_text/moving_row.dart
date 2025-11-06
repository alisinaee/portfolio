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
  final Animation<double>? sharedAnimation;

  const MovingRow({
    super.key,
    required this.delaySec,
    required this.childMenu,
    required this.childBackground,
    required this.isMenuOpen,
    this.reverse = false,
    this.sharedAnimation,
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
  bool _ownsController = false;
  
  bool _isDisposed = false;
  int _buildCount = 0;
  final int _cycleCount = 0;

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
    // Use multiple background units to ensure coverage and avoid edge gaps
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
    
    PerformanceLogger.logAnimation(_performanceId, 'Controller initialized', data: {
      'menuCount': menuList.length,
      'backgroundCount': backgroundList.length,
    });
    
    // Start animation after initial delay (only if we own the controller)
    if (_ownsController) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(seconds: widget.delaySec)).then((_) {
          if (mounted && !_isDisposed) {
            PerformanceLogger.logAnimation(_performanceId, 'Starting animation loop');
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
    PerformanceLogger.logAnimation(_performanceId, 'Disposing', data: {
      'total_builds': _buildCount,
      'total_cycles': _cycleCount,
    });
    
    _isDisposed = true;
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  bool? _lastMenuOpenState;
  
  @override
  Widget build(BuildContext context) {
    _buildCount++;
    
    // Only rebuild if menu state actually changed
    if (_lastMenuOpenState == widget.isMenuOpen) {
      // Return cached widget if state hasn't changed
      return _cachedWidget ?? _buildWidget();
    }
    
    _lastMenuOpenState = widget.isMenuOpen;
    debugPrint('🏗️ [${_performanceId}] Build #${_buildCount} - Menu state changed to: ${widget.isMenuOpen}');
    
    return _buildWidget();
  }
  
  Widget? _cachedWidget;
  
  Widget _buildWidget() {
    final buildStartTime = DateTime.now();
    
    // RepaintBoundary to isolate widget repaints
    final builtWidget = RepaintBoundary(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600), // Faster transition
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          // Use FadeTransition for smooth menu/background transitions
          return FadeTransition(
            opacity: animation,
            child: child,
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
    );
    
    final buildTime = DateTime.now().difference(buildStartTime).inMilliseconds;
    
    if (buildTime > 16) {
      debugPrint('🐌 [${_performanceId}] SLOW BUILD #${_buildCount}: ${buildTime}ms (>16ms target)');
    } else {
      debugPrint('⚡ [${_performanceId}] Build #${_buildCount} took: ${buildTime}ms');
    }
    
    // Cache the widget for potential reuse
    _cachedWidget = builtWidget;
    return builtWidget;
  }

  Widget _buildInnerWidget({required String key, required List<Widget> children}) {
    return SizedBox(
      key: Key(key),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Smaller amplitude to avoid revealing gaps at edges
          final amplitude = constraints.maxWidth * 0.05;
          
          // Use AnimatedBuilder to only rebuild the Transform widget
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Map 0..1..0 to symmetric range [-amplitude, +amplitude]
              final t = _animation.value; // 0..1..0 with reverse:true
              final centered = (t - 0.5) * 2.0; // -1..0..+1
              final directionSign = widget.reverse ? -1.0 : 1.0; // flip for group B
              final dx = directionSign * amplitude * centered;
              
              // Transform.translate is GPU-accelerated (no layout recalculation!)
              return Transform.translate(
                offset: Offset(dx, 0),
                child: child,
              );
            },
            // Child is not rebuilt, only the Transform changes
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
    );
  }
}

