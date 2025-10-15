import 'package:flutter/material.dart';
import '../../core/utils/performance_logger.dart';

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

class _MovingRowState extends State<MovingRow> {
  late final List<Widget> menuList;
  late final List<Widget> backgroundList;
  late final String _performanceId;
  bool start = false;
  bool _isDisposed = false;
  bool _isAnimating = false;
  int _buildCount = 0;
  int _toggleCount = 0;

  @override
  void initState() {
    super.initState();
    _performanceId = 'MovingRow_delay${widget.delaySec}_${widget.isMenuOpen ? "menu" : "bg"}';
    
    PerformanceLogger.logAnimation(_performanceId, 'Initializing', data: {
      'delay': widget.delaySec,
      'reverse': widget.reverse,
      'isMenuOpen': widget.isMenuOpen,
    });
    
    start = widget.reverse;
    
    // Make lists const/final to prevent unnecessary rebuilds
    menuList = List.generate(5, (index) => widget.childMenu);
    backgroundList = List.generate(3, (index) => widget.childBackground);
    
    PerformanceLogger.logAnimation(_performanceId, 'Generated widget lists', data: {
      'menuCount': menuList.length,
      'backgroundCount': backgroundList.length,
    });
    
    // Start animation after delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: widget.delaySec)).then((value) {
        if (mounted && !_isDisposed) {
          PerformanceLogger.logAnimation(_performanceId, 'Starting animation loop');
          _startAnimation();
        }
      });
    });
  }

  // Optimized animation loop with smart pausing
  void _startAnimation() async {
    while (mounted && !_isDisposed) {
      // Toggle direction
      if (mounted && !_isDisposed) {
        _toggleCount++;
        PerformanceLogger.logSetState(_performanceId, 'Toggle direction #$_toggleCount');
        
        setState(() {
          start = !start;
          _isAnimating = true; // Mark as animating
        });
        
        PerformanceLogger.logAnimation(_performanceId, 'Direction toggled', data: {
          'start': start,
          'toggle_count': _toggleCount,
        });
        
        // Wait for animation to complete (30 seconds)
        await Future.delayed(const Duration(seconds: 30));
        
        // Stop animating - this prevents unnecessary rebuilds
        if (mounted && !_isDisposed) {
          setState(() {
            _isAnimating = false;
          });
        }
        
        // Wait before next animation
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  @override
  void dispose() {
    PerformanceLogger.logAnimation(_performanceId, 'Disposing', data: {
      'total_builds': _buildCount,
      'total_toggles': _toggleCount,
    });
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    PerformanceLogger.startBuild(_performanceId);
    
    // Wrap with RepaintBoundary to isolate repaints
    final builtWidget = RepaintBoundary(
      child: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        transitionBuilder: (child, animation) {
          return SizeTransition(
            sizeFactor: animation,
            axis: Axis.vertical,
            child: child,
          );
        },
        child: widget.isMenuOpen
            ? innerWidget(
                key: 'm',
                children: menuList,
              )
            : innerWidget(
                key: 'b',
                children: backgroundList,
              ),
      ),
    );
    
    PerformanceLogger.endBuild(_performanceId);
    return builtWidget;
  }

  Widget innerWidget({required String key, required List<Widget> children}) {
    return SizedBox(
      key: Key(key),
      child: LayoutBuilder(builder: (context, sizer) {
        // Cache the calculated position to avoid recalculation
        final leftPosition = !start ? 0.0 : sizer.maxWidth / 5;
        
        return Stack(
          fit: StackFit.expand,
          children: [
            // Only use AnimatedPositioned when actively animating
            // This prevents constant rebuilds when animation is paused
            _isAnimating
                ? AnimatedPositioned(
                    top: 0,
                    bottom: 0,
                    duration: const Duration(seconds: 30),
                    left: leftPosition,
                    right: 0,
                    curve: Curves.linear,
                    onEnd: () {
                      // Animation completed - mark as not animating
                      if (mounted && !_isDisposed) {
                        setState(() {
                          _isAnimating = false;
                        });
                      }
                    },
                    child: RepaintBoundary(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Row(
                          children: children,
                        ),
                      ),
                    ),
                  )
                : Positioned(
                    // When not animating, use static Positioned (no rebuilds!)
                    top: 0,
                    bottom: 0,
                    left: leftPosition,
                    right: 0,
                    child: RepaintBoundary(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Row(
                          children: children,
                        ),
                      ),
                    ),
                  ),
          ],
        );
      }),
    );
  }
}

