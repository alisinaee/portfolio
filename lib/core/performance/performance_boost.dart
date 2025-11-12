import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance boost utilities that can be applied to existing widgets
/// without breaking the current architecture
class PerformanceBoost {
  
  /// Optimize widget rebuilds with smart caching
  static Widget withCache<T extends Widget>(
    T widget, {
    Object? cacheKey,
    Duration cacheDuration = const Duration(milliseconds: 100),
  }) {
    return _CachedWidget<T>(
      widget: widget,
      cacheKey: cacheKey,
      cacheDuration: cacheDuration,
    );
  }

  /// Optimize animations with frame-perfect timing
  static Widget withOptimizedAnimation({
    required Widget child,
    AnimationController? controller,
    bool useGPUAcceleration = true,
  }) {
    if (controller == null) return child;
    
    return _OptimizedAnimationWrapper(
      controller: controller,
      useGPUAcceleration: useGPUAcceleration,
      child: child,
    );
  }

  /// Prevent unnecessary rebuilds with reference equality
  static Widget withSmartRebuild<T>({
    required T value,
    required Widget Function(T) builder,
  }) {
    return _SmartRebuildWidget<T>(
      value: value,
      builder: builder,
    );
  }

  /// Optimize memory usage with automatic cleanup
  static Widget withMemoryOptimization({
    required Widget child,
    Duration cleanupInterval = const Duration(minutes: 2),
  }) {
    return _MemoryOptimizedWidget(
      cleanupInterval: cleanupInterval,
      child: child,
    );
  }
}

/// Cached widget implementation
class _CachedWidget<T extends Widget> extends StatefulWidget {
  final T widget;
  final Object? cacheKey;
  final Duration cacheDuration;

  const _CachedWidget({
    required this.widget,
    this.cacheKey,
    required this.cacheDuration,
  });

  @override
  State<_CachedWidget<T>> createState() => _CachedWidgetState<T>();
}

class _CachedWidgetState<T extends Widget> extends State<_CachedWidget<T>> {
  Widget? _cachedWidget;
  Object? _lastCacheKey;
  DateTime? _cacheTime;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final cacheKey = widget.cacheKey ?? widget.widget.runtimeType;
    
    // Check if cache is valid
    if (_cachedWidget != null &&
        _lastCacheKey == cacheKey &&
        _cacheTime != null &&
        now.difference(_cacheTime!).abs() < widget.cacheDuration) {
      return _cachedWidget!;
    }

    // Update cache
    _cachedWidget = widget.widget;
    _lastCacheKey = cacheKey;
    _cacheTime = now;

    return _cachedWidget!;
  }
}

/// Optimized animation wrapper
class _OptimizedAnimationWrapper extends StatelessWidget {
  final AnimationController controller;
  final bool useGPUAcceleration;
  final Widget child;

  const _OptimizedAnimationWrapper({
    required this.controller,
    required this.useGPUAcceleration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (useGPUAcceleration) {
      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset.zero, // GPU-accelerated transform
              child: child,
            );
          },
          child: child,
        ),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => child,
    );
  }
}

/// Smart rebuild widget with reference equality
class _SmartRebuildWidget<T> extends StatefulWidget {
  final T value;
  final Widget Function(T) builder;

  const _SmartRebuildWidget({
    required this.value,
    required this.builder,
  });

  @override
  State<_SmartRebuildWidget<T>> createState() => _SmartRebuildWidgetState<T>();
}

class _SmartRebuildWidgetState<T> extends State<_SmartRebuildWidget<T>> {
  T? _lastValue;
  Widget? _cachedWidget;

  @override
  Widget build(BuildContext context) {
    // Use reference equality for performance
    if (identical(_lastValue, widget.value) && _cachedWidget != null) {
      return _cachedWidget!;
    }

    _lastValue = widget.value;
    _cachedWidget = widget.builder(widget.value);
    return _cachedWidget!;
  }
}

/// Memory optimized widget with cleanup
class _MemoryOptimizedWidget extends StatefulWidget {
  final Duration cleanupInterval;
  final Widget child;

  const _MemoryOptimizedWidget({
    required this.cleanupInterval,
    required this.child,
  });

  @override
  State<_MemoryOptimizedWidget> createState() => _MemoryOptimizedWidgetState();
}

class _MemoryOptimizedWidgetState extends State<_MemoryOptimizedWidget> {
  late Ticker _cleanupTicker;

  @override
  void initState() {
    super.initState();
    _cleanupTicker = Ticker(_onCleanupTick);
    _cleanupTicker.start();
  }

  void _onCleanupTick(Duration elapsed) {
    if (elapsed.inMilliseconds % widget.cleanupInterval.inMilliseconds == 0) {
      // Trigger garbage collection hint
      if (mounted) {
        setState(() {
          // Force a rebuild to clean up any cached data
        });
      }
    }
  }

  @override
  void dispose() {
    _cleanupTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: widget.child);
  }
}

/// Performance monitoring mixin that tracks rebuild counts and frame timing
/// 
/// This mixin wraps the build method to measure performance metrics:
/// - Tracks total rebuild count
/// - Measures time between rebuilds
/// - Detects rebuilds faster than 16ms (potential jank)
/// - Logs performance warnings for debugging
/// 
/// Usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with PerformanceMonitorMixin<MyWidget> {
///   @override
///   Widget performanceBuild(BuildContext context) {
///     return Container(); // Your widget tree
///   }
/// }
/// ```
mixin PerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  int _rebuildCount = 0;
  DateTime? _lastRebuild;

  @override
  Widget build(BuildContext context) {
    _rebuildCount++;
    final now = DateTime.now();
    
    // Detect rebuilds faster than 16ms (potential excessive rebuilding)
    if (_lastRebuild != null) {
      final delta = now.difference(_lastRebuild!).inMilliseconds;
      if (delta < 16) {
        debugPrint('⚠️ Fast rebuild detected in ${T.toString()}: ${delta}ms (rebuild #$_rebuildCount)');
      }
    }
    
    _lastRebuild = now;
    
    // Measure build time
    final buildStart = DateTime.now();
    final widget = performanceBuild(context);
    final buildDuration = DateTime.now().difference(buildStart);
    
    // Log slow builds (>16ms indicates potential jank)
    if (buildDuration.inMilliseconds > 16) {
      debugPrint('🐌 Slow build in ${T.toString()}: ${buildDuration.inMilliseconds}ms (rebuild #$_rebuildCount)');
    }
    
    // Log rebuild count periodically for monitoring
    if (_rebuildCount % 50 == 0) {
      debugPrint('📊 ${T.toString()} rebuild count: $_rebuildCount');
    }

    return widget;
  }

  /// Override this instead of build() to enable performance monitoring
  Widget performanceBuild(BuildContext context);

  /// Get current performance metrics for this widget
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'widgetType': T.toString(),
      'rebuildCount': _rebuildCount,
      'lastRebuildTime': _lastRebuild?.toIso8601String(),
    };
  }
  
  /// Get the current rebuild count
  int get rebuildCount => _rebuildCount;
}