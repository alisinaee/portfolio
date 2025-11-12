import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A real liquid glass card that captures the background and creates actual distortion effects
class RealLiquidGlassCard extends StatefulWidget {
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
  
  /// Background key for capturing the background
  final GlobalKey? backgroundKey;
  
  /// Glass effect intensity (0.0 to 1.0)
  final double glassIntensity;
  
  /// Distortion strength
  final double distortionStrength;
  
  /// Padding inside the card
  final EdgeInsetsGeometry padding;
  
  /// Margin around the card
  final EdgeInsetsGeometry margin;
  
  /// Whether the card is draggable
  final bool isDraggable;
  
  /// Initial position for draggable cards
  final Offset? initialPosition;

  const RealLiquidGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 15.0,
    this.borderColor = const Color(0xFF404040),
    this.borderWidth = 1.0,
    this.backgroundKey,
    this.glassIntensity = 0.3,
    this.distortionStrength = 0.5,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.isDraggable = false,
    this.initialPosition,
  });

  @override
  State<RealLiquidGlassCard> createState() => _RealLiquidGlassCardState();
}

class _RealLiquidGlassCardState extends State<RealLiquidGlassCard> with TickerProviderStateMixin {
  ui.Image? _capturedBackground;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
    
    // Capture background after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // GUARD: Check mounted before capturing background
      if (!mounted) return;
      _captureBackground();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _capturedBackground?.dispose();
    super.dispose();
  }

  Future<void> _captureBackground() async {
    if (widget.backgroundKey?.currentContext == null) return;
    
    try {
      final boundary = widget.backgroundKey!.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !boundary.attached) return;
      
      final image = await boundary.toImage(pixelRatio: 1.0);
      if (mounted) {
        setState(() {
          _capturedBackground?.dispose();
          _capturedBackground = image;
        });
      }
    } catch (e) {
      debugPrint('Error capturing background: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      margin: widget.margin,
      decoration: BoxDecoration(
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
            // Real liquid glass effect
            if (_capturedBackground != null)
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(
            (widget.width ?? 300) - (widget.padding.horizontal),
            (widget.height ?? 200) - (widget.padding.vertical),
          ),
          painter: _LiquidGlassPainter(
            backgroundImage: _capturedBackground!,
            animationValue: _animation.value,
            glassIntensity: widget.glassIntensity,
            distortionStrength: widget.distortionStrength,
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

/// Custom painter for real liquid glass effect
class _LiquidGlassPainter extends CustomPainter {
  final ui.Image backgroundImage;
  final double animationValue;
  final double glassIntensity;
  final double distortionStrength;
  final double borderRadius;

  _LiquidGlassPainter({
    required this.backgroundImage,
    required this.animationValue,
    required this.glassIntensity,
    required this.distortionStrength,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    // Create liquid glass distortion effect
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = _createLiquidGlassShader(size);

    // Draw the distorted background
    canvas.drawRRect(rrect, paint);
    
    // Add glass reflection highlights
    _drawGlassHighlights(canvas, size);
  }

  ui.Shader _createLiquidGlassShader(Size size) {
    // Create a simple distortion effect using the background image
    final matrix = Matrix4.identity();
    
    // Add some distortion based on animation
    final distortion = (animationValue - 0.5) * distortionStrength * 0.1;
    matrix.setEntry(0, 0, 1.0 + distortion);
    matrix.setEntry(1, 1, 1.0 - distortion);
    
    return ImageShader(
      backgroundImage,
      TileMode.clamp,
      TileMode.clamp,
      matrix.storage,
    );
  }

  void _drawGlassHighlights(Canvas canvas, Size size) {
    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: glassIntensity * 0.3),
          Colors.transparent,
          Colors.white.withValues(alpha: glassIntensity * 0.1),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    canvas.drawRRect(rrect, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Predefined real liquid glass card styles
class RealLiquidGlassCardStyles {
  /// A small card for icons or small content
  static Widget small({
    required Widget child,
    required GlobalKey backgroundKey,
    Color? borderColor,
    double glassIntensity = 0.2,
  }) {
    return RealLiquidGlassCard(
      width: 80,
      height: 80,
      borderRadius: 12.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      backgroundKey: backgroundKey,
      glassIntensity: glassIntensity,
      child: child,
    );
  }

  /// A medium card for text content or buttons
  static Widget medium({
    required Widget child,
    required GlobalKey backgroundKey,
    Color? borderColor,
    double? width,
    double? height,
    double glassIntensity = 0.3,
  }) {
    return RealLiquidGlassCard(
      width: width ?? 200,
      height: height ?? 120,
      borderRadius: 15.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      backgroundKey: backgroundKey,
      glassIntensity: glassIntensity,
      child: child,
    );
  }

  /// A large card for main content areas
  static Widget large({
    required Widget child,
    required GlobalKey backgroundKey,
    Color? borderColor,
    double? width,
    double? height,
    double glassIntensity = 0.4,
  }) {
    return RealLiquidGlassCard(
      width: width ?? 300,
      height: height ?? 200,
      borderRadius: 20.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      backgroundKey: backgroundKey,
      glassIntensity: glassIntensity,
      child: child,
    );
  }

  /// A card with custom styling for special effects
  static Widget custom({
    required Widget child,
    required GlobalKey backgroundKey,
    double borderRadius = 15.0,
    Color borderColor = const Color(0xFF404040),
    double borderWidth = 1.0,
    double glassIntensity = 0.3,
    double distortionStrength = 0.5,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    bool isDraggable = false,
  }) {
    return RealLiquidGlassCard(
      width: width,
      height: height,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundKey: backgroundKey,
      glassIntensity: glassIntensity,
      distortionStrength: distortionStrength,
      padding: padding,
      margin: margin,
      isDraggable: isDraggable,
      child: child,
    );
  }
}
