import 'package:flutter/material.dart';
import 'advanced_performance_tracker.dart';

/// Enhanced performance tracking mixin with detailed metrics
mixin EnhancedPerformanceTracking<T extends StatefulWidget> on State<T> {
  String get trackingId;
  
  DateTime? _buildStartTime;
  int _buildCount = 0;
  
  @override
  void initState() {
    super.initState();
    debugPrint('🎬 [$trackingId] Widget initialized');
  }
  
  @override
  Widget build(BuildContext context) {
    _buildStartTime = DateTime.now();
    _buildCount++;
    
    final widget = buildWithTracking(context);
    
    final buildDuration = DateTime.now().difference(_buildStartTime!);
    
    // Track in performance system
    AdvancedPerformanceTracker.instance.trackWidgetRebuild(
      trackingId,
      buildDuration: buildDuration,
      reason: 'build #$_buildCount',
    );
    
    // Log slow builds
    if (buildDuration.inMilliseconds > 16) {
      debugPrint('🐌 [$trackingId] Slow build: ${buildDuration.inMilliseconds}ms');
    }
    
    return widget;
  }
  
  @override
  void dispose() {
    debugPrint('🗑️ [$trackingId] Widget disposed (total builds: $_buildCount)');
    super.dispose();
  }
  
  /// Override this instead of build()
  Widget buildWithTracking(BuildContext context);
}

/// Animation performance tracking mixin
mixin AnimationPerformanceTracking<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  String get animationId;
  
  DateTime? _animationStartTime;
  int _frameCount = 0;
  
  /// Wrap your animation controller creation with this
  AnimationController createTrackedController({
    required Duration duration,
    Duration? reverseDuration,
    String? debugLabel,
    double value = 0.0,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
  }) {
    final controller = AnimationController(
      vsync: this,
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel ?? animationId,
      value: value,
      lowerBound: lowerBound,
      upperBound: upperBound,
      animationBehavior: animationBehavior,
    );
    
    // Track animation lifecycle
    controller.addStatusListener((status) {
      if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
        _animationStartTime = DateTime.now();
        _frameCount = 0;
      } else if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        if (_animationStartTime != null) {
          final animDuration = DateTime.now().difference(_animationStartTime!);
          AdvancedPerformanceTracker.instance.trackAnimation(
            animationId,
            duration: animDuration,
            frameCount: _frameCount,
            completed: true,
          );
        }
      }
    });
    
    // Track frames
    controller.addListener(() {
      _frameCount++;
    });
    
    return controller;
  }
}

/// State management performance tracking mixin
mixin StatePerformanceTracking on ChangeNotifier {
  String get stateId;
  
  int _listenerCount = 0;
  
  @override
  void addListener(VoidCallback listener) {
    _listenerCount++;
    super.addListener(listener);
  }
  
  @override
  void removeListener(VoidCallback listener) {
    _listenerCount--;
    super.removeListener(listener);
  }
  
  @override
  void notifyListeners() {
    final startTime = DateTime.now();
    super.notifyListeners();
    final processingTime = DateTime.now().difference(startTime);
    
    AdvancedPerformanceTracker.instance.trackStateChange(
      stateId,
      processingTime: processingTime,
      listenerCount: _listenerCount,
    );
    
    // Warn about expensive state updates
    if (processingTime.inMilliseconds > 5) {
      debugPrint('⚠️ [$stateId] Expensive state update: ${processingTime.inMilliseconds}ms with $_listenerCount listeners');
    }
  }
}

/// Shader performance tracking helper
class ShaderPerformanceTracker {
  static void trackShaderExecution(
    String shaderName,
    VoidCallback execution, {
    Duration? compilationTime,
  }) {
    final startTime = DateTime.now();
    execution();
    final executionTime = DateTime.now().difference(startTime);
    
    AdvancedPerformanceTracker.instance.trackShader(
      shaderName,
      compilationTime: compilationTime ?? Duration.zero,
      executionTime: executionTime,
    );
  }
}
