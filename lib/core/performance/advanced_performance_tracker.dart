import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Advanced Performance Tracker for granular performance monitoring
/// 
/// Tracks:
/// - Frame timing (FPS, jank detection)
/// - Widget rebuild counts
/// - Animation performance
/// - Memory usage patterns
/// - Shader compilation time
/// - State management overhead
class AdvancedPerformanceTracker {
  static final AdvancedPerformanceTracker _instance = AdvancedPerformanceTracker._();
  static AdvancedPerformanceTracker get instance => _instance;
  
  AdvancedPerformanceTracker._();
  
  // Frame timing metrics
  final List<FrameMetrics> _frameHistory = [];
  int _totalFrames = 0;
  int _jankFrames = 0;
  double _averageFps = 60.0;
  DateTime? _lastFrameTime;
  
  // Widget rebuild tracking
  final Map<String, WidgetMetrics> _widgetMetrics = {};
  
  // Animation tracking
  final Map<String, AnimationMetrics> _animationMetrics = {};
  
  // Shader tracking
  final Map<String, ShaderMetrics> _shaderMetrics = {};
  
  // State management tracking
  final Map<String, StateMetrics> _stateMetrics = {};
  
  // Performance thresholds
  static const double _jankThresholdMs = 16.7; // 60fps target
  static const int _maxHistorySize = 300; // Keep last 5 seconds at 60fps
  
  bool _isMonitoring = false;
  Timer? _reportTimer;
  
  /// Start performance monitoring
  void startMonitoring({Duration reportInterval = const Duration(seconds: 10)}) {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    debugPrint('📊 [PerformanceTracker] Monitoring started');
    
    // Start frame timing callback
    SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);
    
    // Start periodic reporting
    _reportTimer = Timer.periodic(reportInterval, (_) => printReport());
  }
  
  /// Stop performance monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _reportTimer?.cancel();
    debugPrint('📊 [PerformanceTracker] Monitoring stopped');
  }
  
  /// Track frame timing
  void _onFrameTiming(List<FrameTiming> timings) {
    if (!_isMonitoring) return;
    
    for (final timing in timings) {
      final buildMs = timing.buildDuration.inMicroseconds / 1000;
      final rasterMs = timing.rasterDuration.inMicroseconds / 1000;
      final totalMs = timing.totalSpan.inMicroseconds / 1000;
      
      _totalFrames++;
      
      // Detect jank
      if (totalMs > _jankThresholdMs) {
        _jankFrames++;
      }
      
      // Store frame metrics
      final frameMetric = FrameMetrics(
        timestamp: DateTime.now(),
        buildMs: buildMs,
        rasterMs: rasterMs,
        totalMs: totalMs,
        isJank: totalMs > _jankThresholdMs,
      );
      
      _frameHistory.add(frameMetric);
      
      // Limit history size
      if (_frameHistory.length > _maxHistorySize) {
        _frameHistory.removeAt(0);
      }
      
      // Calculate average FPS
      _calculateAverageFps();
    }
  }
  
  void _calculateAverageFps() {
    if (_frameHistory.length < 2) return;
    
    final recentFrames = _frameHistory.length > 60 
        ? _frameHistory.sublist(_frameHistory.length - 60) 
        : _frameHistory;
    
    final avgFrameTime = recentFrames
        .map((f) => f.totalMs)
        .reduce((a, b) => a + b) / recentFrames.length;
    
    _averageFps = avgFrameTime > 0 ? 1000 / avgFrameTime : 60.0;
  }
  
  /// Track widget rebuild
  void trackWidgetRebuild(String widgetName, {
    required Duration buildDuration,
    String? reason,
  }) {
    if (!_isMonitoring) return;
    
    final metrics = _widgetMetrics.putIfAbsent(
      widgetName,
      () => WidgetMetrics(widgetName: widgetName),
    );
    
    metrics.rebuildCount++;
    metrics.totalBuildTime += buildDuration;
    metrics.lastRebuildTime = DateTime.now();
    
    if (buildDuration.inMilliseconds > _jankThresholdMs) {
      metrics.slowBuilds++;
    }
    
    if (reason != null) {
      metrics.rebuildReasons[reason] = (metrics.rebuildReasons[reason] ?? 0) + 1;
    }
  }
  
  /// Track animation performance
  void trackAnimation(String animationName, {
    required Duration duration,
    required int frameCount,
    bool completed = false,
  }) {
    if (!_isMonitoring) return;
    
    final metrics = _animationMetrics.putIfAbsent(
      animationName,
      () => AnimationMetrics(animationName: animationName),
    );
    
    metrics.executionCount++;
    metrics.totalDuration += duration;
    metrics.totalFrames += frameCount;
    
    if (completed) {
      metrics.completionCount++;
    }
  }
  
  /// Track shader compilation/execution
  void trackShader(String shaderName, {
    required Duration compilationTime,
    required Duration executionTime,
  }) {
    if (!_isMonitoring) return;
    
    final metrics = _shaderMetrics.putIfAbsent(
      shaderName,
      () => ShaderMetrics(shaderName: shaderName),
    );
    
    metrics.executionCount++;
    metrics.totalCompilationTime += compilationTime;
    metrics.totalExecutionTime += executionTime;
  }
  
  /// Track state management operations
  void trackStateChange(String stateName, {
    required Duration processingTime,
    required int listenerCount,
  }) {
    if (!_isMonitoring) return;
    
    final metrics = _stateMetrics.putIfAbsent(
      stateName,
      () => StateMetrics(stateName: stateName),
    );
    
    metrics.changeCount++;
    metrics.totalProcessingTime += processingTime;
    metrics.maxListenerCount = metrics.maxListenerCount > listenerCount 
        ? metrics.maxListenerCount 
        : listenerCount;
  }
  
  /// Get current performance snapshot
  PerformanceSnapshot getSnapshot() {
    return PerformanceSnapshot(
      timestamp: DateTime.now(),
      averageFps: _averageFps,
      totalFrames: _totalFrames,
      jankFrames: _jankFrames,
      jankPercentage: _totalFrames > 0 ? (_jankFrames / _totalFrames * 100) : 0,
      widgetMetrics: Map.from(_widgetMetrics),
      animationMetrics: Map.from(_animationMetrics),
      shaderMetrics: Map.from(_shaderMetrics),
      stateMetrics: Map.from(_stateMetrics),
    );
  }
  
  /// Print detailed performance report
  void printReport() {
    final snapshot = getSnapshot();
    
    debugPrint('\n╔════════════════════════════════════════════════════════════╗');
    debugPrint('║         ADVANCED PERFORMANCE REPORT                       ║');
    debugPrint('╠════════════════════════════════════════════════════════════╣');
    debugPrint('║ FRAME METRICS                                              ║');
    debugPrint('║ Average FPS: ${snapshot.averageFps.toStringAsFixed(1).padLeft(6)} fps                                    ║');
    debugPrint('║ Total Frames: ${snapshot.totalFrames.toString().padLeft(6)}                                      ║');
    debugPrint('║ Jank Frames: ${snapshot.jankFrames.toString().padLeft(6)} (${snapshot.jankPercentage.toStringAsFixed(1)}%)                          ║');
    debugPrint('╠════════════════════════════════════════════════════════════╣');
    
    // Widget metrics
    if (snapshot.widgetMetrics.isNotEmpty) {
      debugPrint('║ TOP 5 MOST REBUILT WIDGETS                                ║');
      final sortedWidgets = snapshot.widgetMetrics.values.toList()
        ..sort((a, b) => b.rebuildCount.compareTo(a.rebuildCount));
      
      for (var i = 0; i < sortedWidgets.length && i < 5; i++) {
        final widget = sortedWidgets[i];
        final avgBuildMs = widget.averageBuildTime.inMicroseconds / 1000;
        debugPrint('║ ${(i + 1)}. ${widget.widgetName.padRight(35)} ${widget.rebuildCount.toString().padLeft(6)} (${avgBuildMs.toStringAsFixed(1)}ms avg) ║');
      }
      debugPrint('╠════════════════════════════════════════════════════════════╣');
    }
    
    // Animation metrics
    if (snapshot.animationMetrics.isNotEmpty) {
      debugPrint('║ ANIMATION PERFORMANCE                                      ║');
      snapshot.animationMetrics.forEach((name, metrics) {
        final avgDuration = metrics.averageDuration.inMilliseconds;
        final avgFps = metrics.averageFrameRate;
        debugPrint('║ ${name.padRight(30)} ${avgDuration.toString().padLeft(5)}ms ${avgFps.toStringAsFixed(1).padLeft(6)}fps ║');
      });
      debugPrint('╠════════════════════════════════════════════════════════════╣');
    }
    
    // Shader metrics
    if (snapshot.shaderMetrics.isNotEmpty) {
      debugPrint('║ SHADER PERFORMANCE                                         ║');
      snapshot.shaderMetrics.forEach((name, metrics) {
        final avgExecMs = metrics.averageExecutionTime.inMicroseconds / 1000;
        debugPrint('║ ${name.padRight(35)} ${avgExecMs.toStringAsFixed(2).padLeft(8)}ms avg ║');
      });
      debugPrint('╠════════════════════════════════════════════════════════════╣');
    }
    
    // State metrics
    if (snapshot.stateMetrics.isNotEmpty) {
      debugPrint('║ STATE MANAGEMENT OVERHEAD                                  ║');
      snapshot.stateMetrics.forEach((name, metrics) {
        final avgProcessMs = metrics.averageProcessingTime.inMicroseconds / 1000;
        debugPrint('║ ${name.padRight(30)} ${metrics.changeCount.toString().padLeft(6)} changes ${avgProcessMs.toStringAsFixed(2).padLeft(6)}ms ║');
      });
    }
    
    debugPrint('╚════════════════════════════════════════════════════════════╝\n');
  }
  
  /// Reset all metrics
  void reset() {
    _frameHistory.clear();
    _totalFrames = 0;
    _jankFrames = 0;
    _averageFps = 60.0;
    _widgetMetrics.clear();
    _animationMetrics.clear();
    _shaderMetrics.clear();
    _stateMetrics.clear();
    debugPrint('📊 [PerformanceTracker] Metrics reset');
  }
}

// Data classes for metrics

class FrameMetrics {
  final DateTime timestamp;
  final double buildMs;
  final double rasterMs;
  final double totalMs;
  final bool isJank;
  
  FrameMetrics({
    required this.timestamp,
    required this.buildMs,
    required this.rasterMs,
    required this.totalMs,
    required this.isJank,
  });
}

class WidgetMetrics {
  final String widgetName;
  int rebuildCount = 0;
  int slowBuilds = 0;
  Duration totalBuildTime = Duration.zero;
  DateTime? lastRebuildTime;
  Map<String, int> rebuildReasons = {};
  
  WidgetMetrics({required this.widgetName});
  
  Duration get averageBuildTime => rebuildCount > 0 
      ? Duration(microseconds: totalBuildTime.inMicroseconds ~/ rebuildCount)
      : Duration.zero;
}

class AnimationMetrics {
  final String animationName;
  int executionCount = 0;
  int completionCount = 0;
  Duration totalDuration = Duration.zero;
  int totalFrames = 0;
  
  AnimationMetrics({required this.animationName});
  
  Duration get averageDuration => executionCount > 0
      ? Duration(microseconds: totalDuration.inMicroseconds ~/ executionCount)
      : Duration.zero;
  
  double get averageFrameRate => totalDuration.inMilliseconds > 0
      ? (totalFrames / (totalDuration.inMilliseconds / 1000))
      : 0.0;
}

class ShaderMetrics {
  final String shaderName;
  int executionCount = 0;
  Duration totalCompilationTime = Duration.zero;
  Duration totalExecutionTime = Duration.zero;
  
  ShaderMetrics({required this.shaderName});
  
  Duration get averageCompilationTime => executionCount > 0
      ? Duration(microseconds: totalCompilationTime.inMicroseconds ~/ executionCount)
      : Duration.zero;
  
  Duration get averageExecutionTime => executionCount > 0
      ? Duration(microseconds: totalExecutionTime.inMicroseconds ~/ executionCount)
      : Duration.zero;
}

class StateMetrics {
  final String stateName;
  int changeCount = 0;
  Duration totalProcessingTime = Duration.zero;
  int maxListenerCount = 0;
  
  StateMetrics({required this.stateName});
  
  Duration get averageProcessingTime => changeCount > 0
      ? Duration(microseconds: totalProcessingTime.inMicroseconds ~/ changeCount)
      : Duration.zero;
}

class PerformanceSnapshot {
  final DateTime timestamp;
  final double averageFps;
  final int totalFrames;
  final int jankFrames;
  final double jankPercentage;
  final Map<String, WidgetMetrics> widgetMetrics;
  final Map<String, AnimationMetrics> animationMetrics;
  final Map<String, ShaderMetrics> shaderMetrics;
  final Map<String, StateMetrics> stateMetrics;
  
  PerformanceSnapshot({
    required this.timestamp,
    required this.averageFps,
    required this.totalFrames,
    required this.jankFrames,
    required this.jankPercentage,
    required this.widgetMetrics,
    required this.animationMetrics,
    required this.shaderMetrics,
    required this.stateMetrics,
  });
}
