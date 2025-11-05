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
      
      // ENHANCED CLIPPING FOR WEB - Multiple layers of containment
      // 1. First clip to the exact widget bounds
      canvas.clipRect(Offset.zero & size);
      
      // 2. Then clip to the rounded rectangle with additional padding for web safety
      final webSafeRect = Rect.fromLTRB(
        leftMargin + 1.0, 
        topMargin + 1.0, 
        size.width - rightMargin - 1.0, 
        size.height - bottomMargin - 1.0
      );
      final webSafeRRect = RRect.fromRectAndRadius(webSafeRect, Radius.circular(borderRadius));
      canvas.clipRRect(webSafeRRect);
      
      // 3. Apply the shader only within the clipped area
      final paint = Paint()
        ..shader = shader
        ..isAntiAlias = true; // Enable anti-aliasing for smoother edges
      
      // Draw only within the safe clipped area
      canvas.drawRRect(webSafeRRect, paint);
      
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
      // Fallback: draw transparent rectangle
      final paint = Paint()..color = Colors.transparent;
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}