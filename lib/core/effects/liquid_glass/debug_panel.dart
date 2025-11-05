import 'package:flutter/material.dart';

class LiquidGlassDebugPanel extends StatefulWidget {
  final Function(double leftMargin, double rightMargin, double topMargin, double bottomMargin, double borderRadius) onValuesChanged;
  final double initialLeftMargin;
  final double initialRightMargin;
  final double initialTopMargin;
  final double initialBottomMargin;
  final double initialBorderRadius;

  const LiquidGlassDebugPanel({
    Key? key,
    required this.onValuesChanged,
    this.initialLeftMargin = 50.0,
    this.initialRightMargin = 5.0,
    this.initialTopMargin = 8.0,
    this.initialBottomMargin = 8.0,
    this.initialBorderRadius = 35.0,
  }) : super(key: key);

  @override
  State<LiquidGlassDebugPanel> createState() => _LiquidGlassDebugPanelState();
}

class _LiquidGlassDebugPanelState extends State<LiquidGlassDebugPanel> {
  late double leftMargin;
  late double rightMargin;
  late double topMargin;
  late double bottomMargin;
  late double borderRadius;

  @override
  void initState() {
    super.initState();
    leftMargin = widget.initialLeftMargin;
    rightMargin = widget.initialRightMargin;
    topMargin = widget.initialTopMargin;
    bottomMargin = widget.initialBottomMargin;
    borderRadius = widget.initialBorderRadius;
  }

  void _updateValues() {
    widget.onValuesChanged(leftMargin, rightMargin, topMargin, bottomMargin, borderRadius);
    print('🔧 Debug Panel Values:');
    print('   Left Margin: $leftMargin');
    print('   Right Margin: $rightMargin');
    print('   Top Margin: $topMargin');
    print('   Bottom Margin: $bottomMargin');
    print('   Border Radius: $borderRadius');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        width: screenWidth - 40,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔧 Liquid Glass Debug Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Left Margin - Extended range
            _buildSlider(
              'Left Margin',
              leftMargin,
              -200.0,
              900.0,
              (value) {
                setState(() {
                  leftMargin = value;
                });
                _updateValues();
              },
            ),
            
            // Right Margin - Extended range
            _buildSlider(
              'Right Margin',
              rightMargin,
              -200.0,
              850.0,
              (value) {
                setState(() {
                  rightMargin = value;
                });
                _updateValues();
              },
            ),
            
            // Top Margin - Extended range
            _buildSlider(
              'Top Margin',
              topMargin,
              -200.0,
              850.0,
              (value) {
                setState(() {
                  topMargin = value;
                });
                _updateValues();
              },
            ),
            
            // Bottom Margin - Extended range
            _buildSlider(
              'Bottom Margin',
              bottomMargin,
              -200.0,
              850.0,
              (value) {
                setState(() {
                  bottomMargin = value;
                });
                _updateValues();
              },
            ),
            
            // Border Radius - Extended range
            _buildSlider(
              'Border Radius',
              borderRadius,
              -190.0,
              950.0,
              (value) {
                setState(() {
                  borderRadius = value;
                });
                _updateValues();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Current Values Display
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Left: ${leftMargin.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Text('Right: ${rightMargin.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Text('Top: ${topMargin.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Text('Bottom: ${bottomMargin.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Text('Radius: ${borderRadius.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: ((max - min) / 0.5).round(),
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                value.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
