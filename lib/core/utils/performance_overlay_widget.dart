import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as ui;
import 'performance_logger.dart';

/// Performance monitoring widget that displays FPS, frame time, and memory usage
/// This widget is optimized to have minimal performance impact
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool showOverlay;
  final bool enablePauseOnHidden;

  const PerformanceMonitor({
    super.key,
    required this.child,
    this.showOverlay = false,
    this.enablePauseOnHidden = true,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> 
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final List<Duration> _frameTimes = [];
  double _fps = 0.0;
  double _avgFrameTime = 0.0;
  Duration _lastTimestamp = Duration.zero;
  bool _isPaused = false;
  
  static const int _maxSamples = 60; // Track last 60 frames

  @override
  void initState() {
    super.initState();
    if (widget.enablePauseOnHidden) {
      WidgetsBinding.instance.addObserver(this);
    }
    if (widget.showOverlay) {
      _startMonitoring();
    }
  }

  @override
  void didUpdateWidget(PerformanceMonitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showOverlay && !oldWidget.showOverlay) {
      _startMonitoring();
    } else if (!widget.showOverlay && oldWidget.showOverlay) {
      _stopMonitoring();
    }
  }

  void _startMonitoring() {
    int frameCount = 0;
    
    _ticker = createTicker((elapsed) {
      if (_lastTimestamp != Duration.zero) {
        final frameDuration = elapsed - _lastTimestamp;
        
        // Add to list
        _frameTimes.add(frameDuration);
        
        // Keep only last N samples
        if (_frameTimes.length > _maxSamples) {
          _frameTimes.removeAt(0);
        }
        
        // Calculate FPS and average frame time
        if (_frameTimes.isNotEmpty) {
          final totalMicroseconds = _frameTimes.fold<int>(
            0,
            (sum, duration) => sum + duration.inMicroseconds,
          );
          _avgFrameTime = totalMicroseconds / _frameTimes.length / 1000; // Convert to ms
          _fps = 1000000 / (totalMicroseconds / _frameTimes.length); // FPS
        }
      }
      
      _lastTimestamp = elapsed;
      frameCount++;
      
      // Update UI every 30 frames (~500ms at 60fps) to avoid excessive rebuilds
      if (frameCount >= 30) {
        frameCount = 0;
        if (mounted) {
          setState(() {});
        }
      }
    })..start();
  }

  void _stopMonitoring() {
    _ticker?.dispose();
    _ticker = null;
    _frameTimes.clear();
    _lastTimestamp = Duration.zero;
  }

  @override
  void dispose() {
    if (widget.enablePauseOnHidden) {
      WidgetsBinding.instance.removeObserver(this);
    }
    if (widget.showOverlay) {
      _ticker?.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enablePauseOnHidden) return;
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if (!_isPaused) {
          _pauseMonitoring();
        }
        break;
      case AppLifecycleState.resumed:
        if (_isPaused && widget.showOverlay) {
          _resumeMonitoring();
        }
        break;
      case AppLifecycleState.detached:
        _stopMonitoring();
        break;
      case AppLifecycleState.hidden:
        if (!_isPaused) {
          _pauseMonitoring();
        }
        break;
    }
  }

  void _pauseMonitoring() {
    if (!_isPaused && widget.showOverlay && _ticker?.isActive == true) {
      _isPaused = true;
      _ticker?.stop();
    }
  }

  void _resumeMonitoring() {
    if (_isPaused && widget.showOverlay && _ticker?.isActive == false) {
      _isPaused = false;
      _ticker?.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay) ...[
          Positioned(
            top: 50,
            right: 20,
            child: _buildPerformancePanel(),
          ),
          Positioned(
            top: 200,
            right: 20,
            child: _buildDebugButton(),
          ),
        ],
      ],
    );
  }
  
  Widget _buildDebugButton() {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            PerformanceLogger.printSummary();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 0, 0, 0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.summarize, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Print Log',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformancePanel() {
    final fpsColor = _getFpsColor(_fps);
    final frameTimeColor = _getFrameTimeColor(_avgFrameTime);
    
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⚡ PERFORMANCE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildMetricRow(
              'FPS:',
              _fps.toStringAsFixed(1),
              fpsColor,
            ),
            _buildMetricRow(
              'Frame:',
              '${_avgFrameTime.toStringAsFixed(2)} ms',
              frameTimeColor,
            ),
            const SizedBox(height: 4),
            _buildFpsBar(_fps),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFeatures: const [ui.FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFpsBar(double fps) {
    final normalizedFps = (fps / 60).clamp(0.0, 1.0);
    final barColor = _getFpsColor(fps);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Container(
          width: 150,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: normalizedFps,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getFpsColor(double fps) {
    if (fps >= 55) return Colors.greenAccent;
    if (fps >= 45) return Colors.yellowAccent;
    if (fps >= 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  Color _getFrameTimeColor(double frameTime) {
    if (frameTime <= 16.7) return Colors.greenAccent; // 60 FPS
    if (frameTime <= 22.2) return Colors.yellowAccent; // 45 FPS
    if (frameTime <= 33.3) return Colors.orangeAccent; // 30 FPS
    return Colors.redAccent;
  }
}

