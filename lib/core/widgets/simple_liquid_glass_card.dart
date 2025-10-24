import 'package:flutter/material.dart';
import '../effects/liquid_glass/liquid_glass_lens_shader.dart';

/// A simple liquid glass card that creates a full-coverage liquid glass effect
/// without background capture - just a beautiful glass-like appearance
class SimpleLiquidGlassCard extends StatefulWidget {
  /// The child widget to display on top of the liquid glass effect
  final Widget child;
  
  /// Width of the card
  final double? width;
  
  /// Height of the card
  final double? height;
  
  /// Border radius of the card
  final double borderRadius;
  
  /// Border color
  final Color borderColor;
  
  /// Border width
  final double borderWidth;
  
  /// Background color (behind the liquid glass effect)
  final Color backgroundColor;
  
  /// Liquid glass effect intensity (0.0 to 1.0)
  final double effectIntensity;
  
  /// Liquid glass effect size multiplier
  final double effectSize;
  
  /// Liquid glass blur intensity
  final double blurIntensity;
  
  /// Liquid glass dispersion strength
  final double dispersionStrength;
  
  /// Padding inside the card
  final EdgeInsetsGeometry padding;
  
  /// Margin around the card
  final EdgeInsetsGeometry margin;
  
  /// Whether the card is draggable
  final bool isDraggable;
  
  /// Initial position for draggable cards
  final Offset? initialPosition;

  const SimpleLiquidGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 15.0,
    this.borderColor = const Color(0xFF404040),
    this.borderWidth = 1.0,
    this.backgroundColor = Colors.transparent,
    this.effectIntensity = 0.3,
    this.effectSize = 2.0,
    this.blurIntensity = 0.5,
    this.dispersionStrength = 0.1,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.isDraggable = false,
    this.initialPosition,
  });

  @override
  State<SimpleLiquidGlassCard> createState() => _SimpleLiquidGlassCardState();
}

class _SimpleLiquidGlassCardState extends State<SimpleLiquidGlassCard> {
  late LiquidGlassLensShader _shader;

  @override
  void initState() {
    super.initState();
    _shader = LiquidGlassLensShader();
    _initializeShader();
  }

  Future<void> _initializeShader() async {
    await _shader.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          children: [
            // Full-coverage liquid glass effect
            if (_shader.isLoaded)
              Positioned.fill(
                child: _buildLiquidGlassEffect(),
              ),
            
            // Child content on top
            Positioned.fill(
              child: widget.child,
            ),
          ],
        ),
      ),
    );

    // Return draggable or static version
    if (widget.isDraggable) {
      return Draggable(
        feedback: cardContent,
        childWhenDragging: cardContent,
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }

  Widget _buildLiquidGlassEffect() {
    // Create a simple gradient background for the liquid glass effect
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        size: Size(
          (widget.width ?? 300) - (widget.padding.horizontal),
          (widget.height ?? 200) - (widget.padding.vertical),
        ),
        painter: _LiquidGlassPainter(
          shader: _shader,
          effectSize: widget.effectSize,
          blurIntensity: widget.blurIntensity,
          dispersionStrength: widget.dispersionStrength,
        ),
      ),
    );
  }
}

/// Custom painter for liquid glass effect
class _LiquidGlassPainter extends CustomPainter {
  final LiquidGlassLensShader shader;
  final double effectSize;
  final double blurIntensity;
  final double dispersionStrength;

  _LiquidGlassPainter({
    required this.shader,
    required this.effectSize,
    required this.blurIntensity,
    required this.dispersionStrength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!shader.isLoaded) return;

    // Create a simple glass-like effect
    final paint = Paint()
      ..shader = shader.shader
      ..style = PaintingStyle.fill;

    // Draw glass-like shapes
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(15));
    
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
