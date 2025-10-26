import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Custom painter that renders the liquid glass effect on the captured background
class ShaderPainter extends CustomPainter {
  ShaderPainter(
    this.shader, {
    this.leftMargin = 50.0,
    this.rightMargin = 5.0,
    this.topMargin = 8.0,
    this.bottomMargin = 8.0,
    this.borderRadius = 35.0,
    this.showRedBorder = false,
  });

  final ui.FragmentShader shader;
  final double leftMargin;
  final double rightMargin;
  final double topMargin;
  final double bottomMargin;
  final double borderRadius;
  final bool showRedBorder;

  @override
  void paint(Canvas canvas, Size size) {
    try {
      if (size.width <= 0 || size.height <= 0) {
        return;
      }

      // Use dynamic values from debug panel
      final rect = Rect.fromLTRB(
        leftMargin, 
        topMargin, 
        size.width - rightMargin, 
        size.height - bottomMargin
      );
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
      
      // Save the canvas state
      canvas.save();
      
      // Clip to the rounded rectangle - this will contain the shader effect
      canvas.clipRRect(rrect);
      
      // Apply the shader only within the clipped area
      final paint = Paint()..shader = shader;
      canvas.drawRect(Offset.zero & size, paint);
      
      // Restore the canvas state
      canvas.restore();
      
      // Red border when debug panel is visible
      if (showRedBorder) {
        final borderPaint = Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawRRect(rrect, borderPaint);
      }
    } catch (e) {
      final paint = Paint()..color = Colors.transparent;
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}