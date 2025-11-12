import 'package:flutter/material.dart';
import 'dart:async';
import 'advanced_performance_tracker.dart';

/// Real-time performance overlay widget
/// Shows FPS, jank count, and widget rebuild stats
class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;
  
  const PerformanceOverlay({
    super.key,
    required this.child,
    this.enabled = true,
  });
  
  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> {
  Timer? _updateTimer;
  PerformanceSnapshot? _snapshot;
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      AdvancedPerformanceTracker.instance.startMonitoring();
      _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (mounted) {
          setState(() {
            _snapshot = AdvancedPerformanceTracker.instance.getSnapshot();
          });
        }
      });
    }
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
  
  Color _getFpsColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 45) return Colors.orange;
    return Colors.red;
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || _snapshot == null) {
      return widget.child;
    }
    
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 80,
          right: 20,
          child: GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: _isExpanded ? _buildExpandedView() : _buildCompactView(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompactView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_snapshot!.averageFps.toStringAsFixed(1)} FPS',
              style: TextStyle(
                color: _getFpsColor(_snapshot!.averageFps),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
        if (_snapshot!.jankFrames > 0)
          Text(
            'Jank: ${_snapshot!.jankFrames} (${_snapshot!.jankPercentage.toStringAsFixed(1)}%)',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
  
  Widget _buildExpandedView() {
    final topWidgets = _snapshot!.widgetMetrics.values.toList()
      ..sort((a, b) => b.rebuildCount.compareTo(a.rebuildCount));
    
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Monitor',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.expand_less,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          
          // FPS
          _buildMetricRow(
            'FPS',
            '${_snapshot!.averageFps.toStringAsFixed(1)}',
            _getFpsColor(_snapshot!.averageFps),
          ),
          
          // Frames
          _buildMetricRow(
            'Frames',
            '${_snapshot!.totalFrames}',
            Colors.white70,
          ),
          
          // Jank
          if (_snapshot!.jankFrames > 0)
            _buildMetricRow(
              'Jank',
              '${_snapshot!.jankFrames} (${_snapshot!.jankPercentage.toStringAsFixed(1)}%)',
              Colors.orange,
            ),
          
          // Top rebuilt widgets
          if (topWidgets.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Top Rebuilds:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...topWidgets.take(3).map((widget) {
              final avgMs = widget.averageBuildTime.inMicroseconds / 1000;
              return Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  '${widget.widgetName}: ${widget.rebuildCount} (${avgMs.toStringAsFixed(1)}ms)',
                  style: TextStyle(
                    color: avgMs > 16 ? Colors.orange : Colors.white60,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          
          // Animations
          if (_snapshot!.animationMetrics.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Animations:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            ..._snapshot!.animationMetrics.entries.take(2).map((entry) {
              final fps = entry.value.averageFrameRate;
              return Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  '${entry.key}: ${fps.toStringAsFixed(1)} fps',
                  style: TextStyle(
                    color: fps >= 55 ? Colors.green : Colors.orange,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
  
  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
