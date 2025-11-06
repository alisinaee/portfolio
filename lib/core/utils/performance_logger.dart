import 'package:flutter/material.dart';

/// Performance logging utility for tracking animation performance
/// Set kDebugPerformance to true for debugging performance issues
const bool kDebugPerformance = true; // 🔍 Enabled for debugging

class PerformanceLogger {
  static final Map<String, _PerformanceMetrics> _metrics = {};
  static final Map<String, int> _buildCounts = {};
  static final Map<String, DateTime> _lastLog = {};
  static _JankMonitor? _jankMonitor;
  
  static const int _maxMetricsSize = 100; // Limit stored metrics to prevent memory buildup
  
  /// Log when a widget starts building
  static void startBuild(String widgetName) {
    if (!kDebugPerformance) return;
    
    _metrics[widgetName] = _PerformanceMetrics(
      widgetName: widgetName,
      startTime: DateTime.now(),
    );
  }
  
  /// Log when a widget finishes building
  static void endBuild(String widgetName) {
    if (!kDebugPerformance) return;
    
    final metrics = _metrics[widgetName];
    if (metrics == null) return;
    
    final duration = DateTime.now().difference(metrics.startTime);
    _buildCounts[widgetName] = (_buildCounts[widgetName] ?? 0) + 1;
    
    // Log every 60 builds or if build takes > 16ms
    if (_buildCounts[widgetName]! % 60 == 0 || duration.inMilliseconds > 16) {
      _log(
        widgetName,
        '🏗️  Build #${_buildCounts[widgetName]} took ${duration.inMilliseconds}ms',
        duration.inMilliseconds > 16 ? LogLevel.warning : LogLevel.info,
      );
    }
  }
  
  /// Log animation state changes
  static void logAnimation(String widgetName, String action, {Map<String, dynamic>? data}) {
    if (!kDebugPerformance) return;
    
    final dataStr = data != null ? ' | ${data.entries.map((e) => '${e.key}: ${e.value}').join(', ')}' : '';
    _log(widgetName, '🎬 $action$dataStr', LogLevel.info);
  }
  
  /// Log performance warnings
  static void logWarning(String widgetName, String message) {
    if (!kDebugPerformance) return;
    _log(widgetName, '⚠️  $message', LogLevel.warning);
  }
  
  /// Log performance errors
  static void logError(String widgetName, String message) {
    if (!kDebugPerformance) return;
    _log(widgetName, '❌ $message', LogLevel.error);
  }
  
  /// Log frame timing
  static void logFrame(String widgetName, Duration frameDuration) {
    if (!kDebugPerformance) return;
    
    final frameMs = frameDuration.inMicroseconds / 1000;
    if (frameMs > 16.7) {
      _log(
        widgetName,
        '🐌 Slow frame: ${frameMs.toStringAsFixed(2)}ms (target: 16.7ms)',
        LogLevel.warning,
      );
    }
  }
  
  /// Log setState calls
  static void logSetState(String widgetName, String reason) {
    if (!kDebugPerformance) return;
    
    _buildCounts[widgetName] = (_buildCounts[widgetName] ?? 0) + 1;
    
    // Throttle setState logs - only log every 30 calls
    if (_buildCounts[widgetName]! % 30 == 0) {
      _log(
        widgetName,
        '🔄 setState called (total: ${_buildCounts[widgetName]}) - $reason',
        LogLevel.info,
      );
    }
  }
  
  /// Get build count for a widget
  static int getBuildCount(String widgetName) {
    return _buildCounts[widgetName] ?? 0;
  }
  
  /// Reset all metrics
  static void reset() {
    _metrics.clear();
    _buildCounts.clear();
    _lastLog.clear();
    _jankMonitor?.dispose();
    _jankMonitor = null;
  }
  
  /// Clean old metrics to prevent memory buildup
  static void _cleanOldMetrics() {
    if (_metrics.length > _maxMetricsSize) {
      // Remove oldest 20% of metrics
      final toRemove = (_maxMetricsSize * 0.2).toInt();
      final keys = _metrics.keys.take(toRemove).toList();
      for (final key in keys) {
        _metrics.remove(key);
        _lastLog.remove(key);
      }
    }
  }
  
  /// Print summary of all tracked widgets
  static void printSummary() {
    if (!kDebugPerformance) return;
    
    debugPrint('\n╔════════════════════════════════════════════════════════════╗');
    debugPrint('║         PERFORMANCE SUMMARY                                ║');
    debugPrint('╠════════════════════════════════════════════════════════════╣');
    
    final sortedWidgets = _buildCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final entry in sortedWidgets) {
      debugPrint('║ ${entry.key.padRight(40)} : ${entry.value.toString().padLeft(6)} builds');
    }
    
    debugPrint('╚════════════════════════════════════════════════════════════╝\n');
    if (_jankMonitor != null) {
      final stats = _jankMonitor!;
      debugPrint('FPS: ${stats.currentFps.toStringAsFixed(1)} | Jank>16.7ms: ${stats.jankCount} | worst: ${stats.worstFrameMs.toStringAsFixed(2)}ms');
    }
  }

  /// Public API to start the jank monitor (works on web via sampling)
  static void startJankMonitor() {
    if (!kDebugPerformance) return;
    _jankMonitor ??= _JankMonitor();
    _jankMonitor!.start();
  }
  
  static void _log(String widgetName, String message, LogLevel level) {
    // Throttle logs to avoid spam - max 1 per second per widget
    final now = DateTime.now();
    final lastLogTime = _lastLog[widgetName];
    
    if (lastLogTime != null && now.difference(lastLogTime).inMilliseconds < 1000) {
      return;
    }
    
    _lastLog[widgetName] = now;
    
    // Periodically clean old metrics
    _cleanOldMetrics();
    
    final prefix = level == LogLevel.error
        ? '🔴'
        : level == LogLevel.warning
            ? '🟡'
            : '🟢';
    
    final timestamp = now.toString().substring(11, 23);
    debugPrint('$prefix [$timestamp] [$widgetName] $message');
  }
}

enum LogLevel {
  info,
  warning,
  error,
}

class _PerformanceMetrics {
  final String widgetName;
  final DateTime startTime;
  
  _PerformanceMetrics({
    required this.widgetName,
    required this.startTime,
  });
}

/// Lightweight jank monitor that works on web by sampling frame intervals
class _JankMonitor {
  bool _running = false;
  int _frames = 0;
  int jankCount = 0;
  double worstFrameMs = 0;
  double currentFps = 0;
  DateTime? _lastStamp;

  void start() {
    if (_running) return;
    _running = true;
    _tick();
  }

  void _tick() {
    if (!_running) return;
    final now = DateTime.now();
    if (_lastStamp != null) {
      final delta = now.difference(_lastStamp!).inMicroseconds / 1000.0;
      _frames++;
      if (delta > 16.7) {
        jankCount++;
        if (delta > worstFrameMs) worstFrameMs = delta;
      }
      // Recompute FPS every 30 frames
      if (_frames % 30 == 0) {
        currentFps = 1000.0 / delta;
      }
    }
    _lastStamp = now;
    WidgetsBinding.instance.scheduleFrameCallback((_) => _tick());
  }

  void dispose() {
    _running = false;
  }
}

/// Mixin to add performance tracking to StatefulWidgets
mixin PerformanceTrackingMixin<T extends StatefulWidget> on State<T> {
  String get performanceId;
  
  @override
  void initState() {
    super.initState();
    PerformanceLogger.logAnimation(performanceId, 'Widget initialized');
  }
  
  @override
  void dispose() {
    PerformanceLogger.logAnimation(performanceId, 'Widget disposed');
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    PerformanceLogger.startBuild(performanceId);
    final widget = buildWithTracking(context);
    PerformanceLogger.endBuild(performanceId);
    return widget;
  }
  
  /// Override this instead of build()
  Widget buildWithTracking(BuildContext context);
}

