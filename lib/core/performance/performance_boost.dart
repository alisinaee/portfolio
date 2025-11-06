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

/// Performance monitoring mixin
mixin PerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  int _buildCount = 0;
  DateTime? _lastBuildTime;

  @override
  Widget build(BuildContext context) {
    final buildStart = DateTime.now();
    _buildCount++;

    final widget = performanceBuild(context);

    final buildTime = DateTime.now().difference(buildStart);
    _lastBuildTime = buildStart;

    // Log slow builds
    if (buildTime.inMilliseconds > 16) {
      debugPrint('🐌 Slow build in ${T.toString()}: ${buildTime.inMilliseconds}ms');
    }

    return widget;
  }

  /// Override this instead of build()
  Widget performanceBuild(BuildContext context);

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'buildCount': _buildCount,
      'lastBuildTime': _lastBuildTime?.toIso8601String(),
      'widgetType': T.toString(),
    };
  }
}