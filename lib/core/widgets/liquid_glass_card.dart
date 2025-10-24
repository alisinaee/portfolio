import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../effects/liquid_glass/liquid_glass_lens_shader.dart';
import '../effects/liquid_glass/shader_painter.dart';

/// A reusable liquid glass card widget that works like a Container
/// but with customizable liquid glass background effects
class LiquidGlassCard extends StatefulWidget {
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
  
  /// Background key for capturing the background
  final GlobalKey? backgroundKey;
  
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

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 15.0,
    this.borderColor = const Color(0xFF404040),
    this.borderWidth = 1.0,
    this.backgroundColor = Colors.transparent,
    this.backgroundKey,
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
  State<LiquidGlassCard> createState() => _LiquidGlassCardState();
}

class _LiquidGlassCardState extends State<LiquidGlassCard> {
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

  Widget _buildLiquidGlassEffect() {
    return FutureBuilder<ui.Image?>(
      future: _captureBackgroundImage(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _shader.updateShaderUniforms(
            width: (widget.width ?? 300) - (widget.padding.horizontal),
            height: (widget.height ?? 200) - (widget.padding.vertical),
            backgroundImage: snapshot.data,
          );
          
          return CustomPaint(
            size: Size(
              (widget.width ?? 300) - (widget.padding.horizontal),
              (widget.height ?? 200) - (widget.padding.vertical),
            ),
            painter: ShaderPainter(_shader.shader),
          );
        }
        
        // Fallback to transparent container
        return Container(
          width: (widget.width ?? 300) - (widget.padding.horizontal),
          height: (widget.height ?? 200) - (widget.padding.vertical),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }

  Future<ui.Image?> _captureBackgroundImage() async {
    if (widget.backgroundKey?.currentContext == null) return null;
    
    try {
      final boundary = widget.backgroundKey!.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !boundary.attached) return null;
      
      final image = await boundary.toImage(pixelRatio: 1.0);
      return image;
    } catch (e) {
      debugPrint('Error capturing background: $e');
      return null;
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
            // Liquid Glass Background Effect - Full Coverage
            if (_shader.isLoaded && widget.backgroundKey != null)
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
}

/// Predefined liquid glass card styles for common use cases
class LiquidGlassCardStyles {
  /// A small card for icons or small content
  static Widget small({
    required Widget child,
    GlobalKey? backgroundKey,
    Color? borderColor,
  }) {
    return LiquidGlassCard(
      width: 80,
      height: 80,
      borderRadius: 12.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      backgroundKey: backgroundKey,
      effectIntensity: 0.2,
      effectSize: 1.5,
      child: child,
    );
  }

  /// A medium card for text content or buttons
  static Widget medium({
    required Widget child,
    GlobalKey? backgroundKey,
    Color? borderColor,
    double? width,
    double? height,
  }) {
    return LiquidGlassCard(
      width: width ?? 200,
      height: height ?? 120,
      borderRadius: 15.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      backgroundKey: backgroundKey,
      effectIntensity: 0.3,
      effectSize: 2.0,
      child: child,
    );
  }

  /// A large card for main content areas
  static Widget large({
    required Widget child,
    GlobalKey? backgroundKey,
    Color? borderColor,
    double? width,
    double? height,
  }) {
    return LiquidGlassCard(
      width: width ?? 300,
      height: height ?? 200,
      borderRadius: 20.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      backgroundKey: backgroundKey,
      effectIntensity: 0.4,
      effectSize: 2.5,
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
    double effectIntensity = 0.3,
    double effectSize = 2.0,
    double blurIntensity = 0.5,
    double dispersionStrength = 0.1,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    bool isDraggable = false,
  }) {
    return LiquidGlassCard(
      width: width,
      height: height,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundKey: backgroundKey,
      effectIntensity: effectIntensity,
      effectSize: effectSize,
      blurIntensity: blurIntensity,
      dispersionStrength: dispersionStrength,
      padding: padding,
      margin: margin,
      isDraggable: isDraggable,
      child: child,
    );
  }
}
