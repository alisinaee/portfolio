import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring utility for tracking animation performance
class PerformanceMonitor {
  static final Map<String, int> _frameCounts = {};
  static final Map<String, Duration> _totalTimes = {};
  static final Map<String, DateTime> _startTimes = {};
  
  /// Start monitoring performance for a specific operation
  static void startMonitoring(String operationId) {
    _startTimes[operationId] = DateTime.now();
    _frameCounts[operationId] = 0;
    _totalTimes[operationId] = Duration.zero;
    
    if (kDebugMode) {
      debugPrint('🔍 [Performance] Started monitoring: $operationId');
    }
  }
  
  /// Stop monitoring and report results
  static void stopMonitoring(String operationId) {
    final startTime = _startTimes[operationId];
    if (startTime == null) return;
    
    final totalTime = DateTime.now().difference(startTime);
    final frameCount = _frameCounts[operationId] ?? 0;
    final avgFrameTime = frameCount > 0 ? totalTime.inMicroseconds / frameCount : 0;
    
    if (kDebugMode) {
      debugPrint('📊 [Performance] $operationId Results:');
      debugPrint('   Total Time: ${totalTime.inMilliseconds}ms');
      debugPrint('   Frame Count: $frameCount');
      debugPrint('   Avg Frame Time: ${avgFrameTime.toStringAsFixed(2)}μs');
      debugPrint('   FPS: ${frameCount > 0 ? (1000000 / avgFrameTime).toStringAsFixed(1) : 'N/A'}');
    }
    
    // Clean up
    _startTimes.remove(operationId);
    _frameCounts.remove(operationId);
    _totalTimes.remove(operationId);
  }
  
  /// Record a frame for the given operation
  static void recordFrame(String operationId) {
    if (_startTimes.containsKey(operationId)) {
      _frameCounts[operationId] = (_frameCounts[operationId] ?? 0) + 1;
    }
  }
  
  /// Monitor widget build performance
  static T monitorBuild<T>(String widgetName, T Function() buildFunction) {
    final startTime = DateTime.now();
    final result = buildFunction();
    final buildTime = DateTime.now().difference(startTime);
    
    if (kDebugMode && buildTime.inMilliseconds > 16) { // Flag builds > 16ms (60fps threshold)
      debugPrint('⚠️ [Performance] Slow build detected: $widgetName took ${buildTime.inMilliseconds}ms');
    }
    
    return result;
  }
  
  /// Check if current frame rate is acceptable
  static bool get isPerformanceGood {
    return SchedulerBinding.instance.currentFrameTimeStamp.inMilliseconds < 16;
  }
}

/// Mixin for widgets to easily monitor their performance
mixin PerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  String get performanceId => widget.runtimeType.toString();
  
  @override
  void initState() {
    super.initState();
    PerformanceMonitor.startMonitoring(performanceId);
  }
  
  @override
  void dispose() {
    PerformanceMonitor.stopMonitoring(performanceId);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return PerformanceMonitor.monitorBuild(performanceId, () => performanceBuild(context));
  }
  
  /// Override this instead of build() to get automatic performance monitoring
  Widget performanceBuild(BuildContext context);
}