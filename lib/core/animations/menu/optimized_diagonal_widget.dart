import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../utils/performance_logger.dart';

class OptimizedDiagonalWidget extends StatelessWidget {
  final Widget child;
  static const String _performanceId = 'OptimizedDiagonalWidget';

  const OptimizedDiagonalWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    PerformanceLogger.startBuild(_performanceId);
    
    final builtWidget = LayoutBuilder(
      builder: (context, constraints) {
        final angle = math.atan(constraints.maxWidth / constraints.maxHeight) * (180 / math.pi);
        final scale = math.sqrt(constraints.maxWidth * constraints.maxWidth + constraints.maxHeight * constraints.maxHeight) / 
                     math.max(constraints.maxWidth, constraints.maxHeight) / math.cos(angle * (math.pi / 180));
        
        return RepaintBoundary(
          child: Stack(
            children: [
              // Use CustomPaint for static diagonal background
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: DiagonalBackgroundPainter(
                  angle: angle,
                  scale: scale,
                ),
              ),
              // Center the child with rotation
              Center(
                child: Transform.rotate(
                  angle: (90 - angle) * (math.pi / 180),
                  child: child,
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
}

class DiagonalBackgroundPainter extends CustomPainter {
  final double angle;
  final double scale;
  static const String _performanceId = 'DiagonalBackgroundPainter';

  DiagonalBackgroundPainter({required this.angle, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    PerformanceLogger.logAnimation(_performanceId, 'Painting diagonal background');
    
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate((90 - angle) * (math.pi / 180));
    canvas.scale(scale);
    canvas.translate(-size.width / 2, -size.height / 2);
    
    // Draw borders and placeholder texts
    _drawBorders(canvas, size);
    _drawPlaceholderTexts(canvas, size);
    
    canvas.restore();
  }

  void _drawBorders(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw top border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.16),
      paint,
    );

    // Draw bottom border
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.84, size.width, size.height * 0.16),
      paint,
    );
  }

  void _drawPlaceholderTexts(Canvas canvas, Size size) {
    final textStyle = ui.TextStyle(
      color: Colors.white54,
      fontSize: 12,
    );

    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.center,
    );

    // Top section texts
    final topTexts = [
      'Made By LOvE ...',
      '© 2024 Ali Sianee',
      'ali.sianee@gmail.com',
    ];

    for (int i = 0; i < topTexts.length; i++) {
      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText(topTexts[i]);
      
      final paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: size.width));

      canvas.drawParagraph(
        paragraph,
        Offset(0, (size.height * 0.16 / 4) * (i + 1)),
      );
    }

    // Bottom section texts
    final bottomTexts = [
      'Responsive Design',
      'Flutter Web',
      'Performance Optimized',
    ];

    for (int i = 0; i < bottomTexts.length; i++) {
      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText(bottomTexts[i]);
      
      final paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: size.width));

      canvas.drawParagraph(
        paragraph,
        Offset(0, size.height * 0.84 + (size.height * 0.16 / 4) * (i + 1)),
      );
    }

    // Draw passive items (repeating text)
    _drawPassiveItems(canvas, size);
  }

  void _drawPassiveItems(Canvas canvas, Size size) {
    final passiveItems = [
      'PORTFOLIO',
      'DEVELOPER',
      'DESIGNER',
      'CREATIVE',
      'INNOVATIVE',
    ];

    final textStyle = ui.TextStyle(
      color: Colors.white24,
      fontSize: 10,
    );

    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.center,
    );

    // Draw repeating passive items
    for (int i = 0; i < 5; i++) {
      final item = passiveItems[i % passiveItems.length];
      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText(item);
      
      final paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: size.width));

      canvas.drawParagraph(
        paragraph,
        Offset(0, size.height * 0.2 + (i * 20)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Static background - no repaint needed
    return false;
  }
}
