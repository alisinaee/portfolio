import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/performance_logger.dart';

class DiagonalWidget extends StatefulWidget {
  final Widget child;

  const DiagonalWidget({super.key, required this.child});

  @override
  State<DiagonalWidget> createState() => _DiagonalWidgetState();
}

class _DiagonalWidgetState extends State<DiagonalWidget> {
  static const String _performanceId = 'DiagonalWidget';
  
  // Cache the last calculated values to avoid recalculation
  double? _cachedWidth;
  double? _cachedHeight;
  double? _cachedAngle;
  double? _cachedScaleFactor;
  int _recalculationCount = 0;

  double calculateAngle(double width, double length) {
    // Calculate the angle in radians
    double angleRadians = atan(width / length);
    // Convert the angle to degrees
    double angleDegrees = angleRadians * (180 / pi);
    return angleDegrees.clamp(0, 45);
  }

  double calculateScaleFactor(double parentWidth, double parentHeight, double rotationAngle) {
    // Convert rotation angle to radians
    double radians = rotationAngle * (pi / 180);
    // Calculate the diagonal length of the parent
    double diagonal = sqrt(parentWidth * parentWidth + parentHeight * parentHeight);
    // Calculate the required scale factor to ensure the rotated child fills the parent
    double scaleFactor = diagonal / max(parentWidth, parentHeight);
    // Adjust the scale factor based on the rotation angle
    scaleFactor /= cos(radians.abs());
    return scaleFactor.clamp(1.2, 2);
  }

  @override
  Widget build(BuildContext context) {
    PerformanceLogger.startBuild(_performanceId);
    
    final builtWidget = LayoutBuilder(
      builder: (context, constraints) {
        // Cache calculations - only recalculate if dimensions changed
        bool needsRecalculation = _cachedWidth != constraints.maxWidth || 
                                   _cachedHeight != constraints.maxHeight;
        
        if (needsRecalculation) {
          _recalculationCount++;
          
          PerformanceLogger.logAnimation(_performanceId, 'Recalculating layout', data: {
            'width': constraints.maxWidth.toStringAsFixed(1),
            'height': constraints.maxHeight.toStringAsFixed(1),
            'recalculation_count': _recalculationCount,
          });
          
          _cachedWidth = constraints.maxWidth;
          _cachedHeight = constraints.maxHeight;
          _cachedAngle = calculateAngle(constraints.maxWidth, constraints.maxHeight);
          _cachedScaleFactor = calculateScaleFactor(
            constraints.maxWidth,
            constraints.maxHeight,
            _cachedAngle!,
          );
          
          PerformanceLogger.logAnimation(_performanceId, 'Calculation complete', data: {
            'angle': _cachedAngle!.toStringAsFixed(2),
            'scaleFactor': _cachedScaleFactor!.toStringAsFixed(2),
          });
        }
        
        final angle = _cachedAngle!;
        final scaleFactor = _cachedScaleFactor!;
        
        // Use RepaintBoundary to isolate the entire diagonal transformation
        return RepaintBoundary(
          child: Stack(
            children: [
              Positioned(
                left: -constraints.maxWidth / 2,
                right: -constraints.maxWidth / 2,
                top: -constraints.maxWidth / 8,
                bottom: -constraints.maxWidth / 8,
                child: Transform.scale(
                  scaleX: scaleFactor,
                  // Transform is GPU-accelerated
                  child: RotationTransition(
                    turns: AlwaysStoppedAnimation((90 - angle) / 360),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            flex: 16,
                            child: _passiveBuilder(items: _passiveItems.sublist(0, 3)),
                          ),
                          Expanded(flex: 50, child: widget.child),
                          Expanded(
                            flex: 16,
                            child: _passiveBuilder(items: _passiveItems.sublist(2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    
    PerformanceLogger.endBuild(_performanceId);
    return builtWidget;
  }

  Widget _passiveBuilder({required List<String> items}) {
    // Wrap in RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (index) => _placeholderWidget(txt: items[index]),
        ),
      ),
    );
  }

  Widget _placeholderWidget({required String txt}) {
    return Expanded(
      // RepaintBoundary must be INSIDE Expanded, not wrapping it
      child: RepaintBoundary(
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white54, width: 0.5),
              bottom: BorderSide(color: Colors.white54, width: 0.5),
              left: BorderSide(color: Colors.white54, width: 0.5),
              right: BorderSide(color: Colors.white54, width: 0.5),
            ),
          ),
          child: Center(
            child: Text(
              txt,
              // Optimize text rendering
              style: const TextStyle(
                color: Colors.white54,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

List<String> _passiveItems = [
  'Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE',
  '  Copyright © 2024 Ali Sianee. All rights reserved.  Copyright © 2024 Ali Sianee. All rights reserved.  Copyright © 2024 Ali Sianee. All rights reserved.  Copyright © 2024 Ali Sianee. All rights reserved.  Copyright © 2024 Ali Sianee. All rights reserved. ',
  '  alsisinaiasl@gmail.com  alsisinaiasl@gmail.com  alsisinaiasl@gmail.com  alsisinaiasl@gmail.com  alsisinaiasl@gmail.com  alsisinaiasl@gmail.com  alsisinaiasl@gmail.com',
  '  Copyright © 2024 Ali Sianee. All rights reserved.  Copyright © 2024 Ali Sianee. All rights reserved.  Copyright © 2024 Ali Sianee. All rights reserved.  Copyright © 2024 Ali Sianee. All rights reserved.  Copyright © 2024 Ali Sianee. All rights reserved. ',
  '  This web app is fully responsive, ensuring an optimal viewing and interactive experience across various devices and screen sizes.  This web app is fully responsive, ensuring an optimal viewing and interactive experience across various devices and screen sizes.   ',
  'Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE  Made By LOvE',
];
