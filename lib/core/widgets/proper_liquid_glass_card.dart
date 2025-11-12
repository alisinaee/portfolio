import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../effects/liquid_glass/liquid_glass_lens_shader.dart';
import '../effects/liquid_glass/shader_painter.dart';

/// A proper liquid glass card using the original shader system
class ProperLiquidGlassCard extends StatefulWidget {
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
  
  /// Effect size for the shader
  final double effectSize;
  
  /// Blur intensity for the shader
  final double blurIntensity;
  
  /// Dispersion strength for the shader
  final double dispersionStrength;
  
  /// Padding inside the card
  final EdgeInsetsGeometry padding;
  
  /// Margin around the card
  final EdgeInsetsGeometry margin;
  
  /// Whether the card is draggable
  final bool isDraggable;
  
  /// Initial position for draggable cards
  final Offset? initialPosition;

  const ProperLiquidGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 15.0,
    this.borderColor = const Color(0xFF404040),
    this.borderWidth = 1.0,
    this.backgroundKey,
    this.glassIntensity = 0.3,
    this.effectSize = 2.0,
    this.blurIntensity = 0.5,
    this.dispersionStrength = 0.1,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.isDraggable = false,
    this.initialPosition,
  });

  @override
  State<ProperLiquidGlassCard> createState() => _ProperLiquidGlassCardState();
}

class _ProperLiquidGlassCardState extends State<ProperLiquidGlassCard> with TickerProviderStateMixin {
  late LiquidGlassLensShader _shader;
  ui.Image? _capturedBackground;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _shader = LiquidGlassLensShader();
    _initializeShader();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
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

  Future<void> _initializeShader() async {
    try {
      await _shader.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing shader: $e');
    }
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
            // Proper liquid glass effect using shaders
            if (_shader.isLoaded && _capturedBackground != null)
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
        // Update shader uniforms with animation
        _shader.updateShaderUniforms(
          width: (widget.width ?? 300) - (widget.padding.horizontal),
          height: (widget.height ?? 200) - (widget.padding.vertical),
          backgroundImage: _capturedBackground!,
        );
        
        return CustomPaint(
          size: Size(
            (widget.width ?? 300) - (widget.padding.horizontal),
            (widget.height ?? 200) - (widget.padding.vertical),
          ),
          painter: ShaderPainter(_shader.shader),
        );
      },
    );
  }
}

/// Predefined proper liquid glass card styles
class ProperLiquidGlassCardStyles {
  /// A small card for icons or small content
  static Widget small({
    required Widget child,
    required GlobalKey backgroundKey,
    Color? borderColor,
    double glassIntensity = 0.2,
    double effectSize = 1.5,
  }) {
    return ProperLiquidGlassCard(
      width: 80,
      height: 80,
      borderRadius: 12.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      backgroundKey: backgroundKey,
      glassIntensity: glassIntensity,
      effectSize: effectSize,
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
    double effectSize = 2.0,
  }) {
    return ProperLiquidGlassCard(
      width: width ?? 200,
      height: height ?? 120,
      borderRadius: 15.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      backgroundKey: backgroundKey,
      glassIntensity: glassIntensity,
      effectSize: effectSize,
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
    double effectSize = 2.5,
  }) {
    return ProperLiquidGlassCard(
      width: width ?? 300,
      height: height ?? 200,
      borderRadius: 20.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      backgroundKey: backgroundKey,
      glassIntensity: glassIntensity,
      effectSize: effectSize,
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
    double effectSize = 2.0,
    double blurIntensity = 0.5,
    double dispersionStrength = 0.1,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    bool isDraggable = false,
  }) {
    return ProperLiquidGlassCard(
      width: width,
      height: height,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundKey: backgroundKey,
      glassIntensity: glassIntensity,
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
