import 'package:flutter/material.dart';

class ContentPositionDebugPanel extends StatefulWidget {
  final Function(double offsetX, double offsetY) onPositionChanged;
  final double initialOffsetX;
  final double initialOffsetY;

  const ContentPositionDebugPanel({
    super.key,
    required this.onPositionChanged,
    this.initialOffsetX = 0.0,
    this.initialOffsetY = 0.0,
  });

  @override
  State<ContentPositionDebugPanel> createState() => _ContentPositionDebugPanelState();
}

class _ContentPositionDebugPanelState extends State<ContentPositionDebugPanel> {
  late double _offsetX;
  late double _offsetY;

  @override
  void initState() {
    super.initState();
    _offsetX = widget.initialOffsetX;
    _offsetY = widget.initialOffsetY;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Content Position',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // X Offset
            Row(
              children: [
                const Text(
                  'X Offset:',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _offsetX,
                    min: -200.0,
                    max: 200.0,
                    divisions: 200,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    onChanged: (value) {
                      setState(() {
                        _offsetX = value;
                      });
                      widget.onPositionChanged(_offsetX, _offsetY);
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    _offsetX.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            
            // Y Offset
            Row(
              children: [
                const Text(
                  'Y Offset:',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _offsetY,
                    min: -200.0,
                    max: 200.0,
                    divisions: 200,
                    activeColor: Colors.green,
                    inactiveColor: Colors.grey,
                    onChanged: (value) {
                      setState(() {
                        _offsetY = value;
                      });
                      widget.onPositionChanged(_offsetX, _offsetY);
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    _offsetY.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Reset button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _offsetX = 0.0;
                    _offsetY = 0.0;
                  });
                  widget.onPositionChanged(_offsetX, _offsetY);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.7),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reset'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
