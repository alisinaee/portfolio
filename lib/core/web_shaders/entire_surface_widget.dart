import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Entire surface liquid glass widget
class EntireSurfaceWidget extends StatefulWidget {
  final Widget child;
  final double? width;
  final double height;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final double effectSize;
  final double blurIntensity;
  final double dispersionStrength;
  final double glassIntensity;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final bool isDraggable;
  final bool realTimeEffect;
  final GlobalKey backgroundKey;

  const EntireSurfaceWidget({
    super.key,
    required this.child,
    required this.backgroundKey,
    this.width,
    this.height = 200,
    this.borderRadius = 12.0,
    this.borderColor = const Color(0xFF404040),
    this.borderWidth = 1.0,
    this.effectSize = 2.0,
    this.blurIntensity = 0.5,
    this.dispersionStrength = 0.1,
    this.glassIntensity = 0.3,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.isDraggable = false,
    this.realTimeEffect = true,
  });

  @override
  State<EntireSurfaceWidget> createState() => _EntireSurfaceWidgetState();
}

class _EntireSurfaceWidgetState extends State<EntireSurfaceWidget> 
    with TickerProviderStateMixin {
  ui.FragmentShader? _shader;
  ui.Image? _capturedBackground;
  bool _isInitialized = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Offset _mousePosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializeWebShader();
    _setupAnimation();
    
    // Capture background after shader is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureBackground();
    });
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.realTimeEffect) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shader?.dispose();
    _capturedBackground?.dispose();
    super.dispose();
  }

  Future<void> _initializeWebShader() async {
    if (!kIsWeb) return;

    try {
      debugPrint('🔍 [EntireSurface] Loading entire surface shader...');
      final program = await ui.FragmentProgram.fromAsset('shaders/entire_surface_glass.frag');
      _shader = program.fragmentShader();
      debugPrint('🔍 [EntireSurface] Shader loaded successfully');

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('❌ [EntireSurface] Error loading shader: $e');
    }
  }

  Future<void> _captureBackground() async {
    if (!_isInitialized || widget.backgroundKey.currentContext == null) {
      debugPrint('🔍 [EntireSurface] Skipping background capture - not ready');
      return;
    }

    try {
      debugPrint('🔍 [EntireSurface] Capturing background...');
      final boundary = widget.backgroundKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !boundary.attached) return;

      final ui.Image backgroundImage = await boundary.toImage(pixelRatio: 1.0);
      debugPrint('🔍 [EntireSurface] Background captured successfully');

      if (mounted) {
        setState(() {
          _capturedBackground?.dispose();
          _capturedBackground = backgroundImage;
        });
      }
    } catch (e) {
      debugPrint('❌ [EntireSurface] Error capturing background: $e');
    }
  }

  void _updateMousePosition(Offset position) {
    setState(() {
      _mousePosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final widgetContent = Container(
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
            if (_shader != null && _capturedBackground != null)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return _buildLiquidGlassEffect();
                  },
                ),
              )
            else
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            Positioned.fill(
              child: widget.child,
            ),
          ],
        ),
      ),
    );

    final mouseRegionContent = MouseRegion(
      onHover: (event) {
        _updateMousePosition(event.localPosition);
      },
      child: widgetContent,
    );

    if (widget.isDraggable) {
      return Draggable(
        feedback: mouseRegionContent,
        childWhenDragging: mouseRegionContent,
        onDragUpdate: (details) {
          _updateMousePosition(details.globalPosition);
        },
        child: GestureDetector(
          onPanUpdate: (details) {
            _updateMousePosition(details.globalPosition);
          },
          child: mouseRegionContent,
        ),
      );
    } else {
      return mouseRegionContent;
    }
  }

  Widget _buildLiquidGlassEffect() {
    final width = (widget.width ?? 300) - (widget.padding.horizontal);
    final height = widget.height - (widget.padding.vertical);

    return CustomPaint(
      size: Size(width, height),
      painter: _EntireSurfacePainter(
        shader: _shader!,
        animationValue: _animation.value,
        width: width,
        height: height,
        mousePosition: _mousePosition,
        effectSize: widget.effectSize,
        blurIntensity: widget.blurIntensity,
        dispersionStrength: widget.dispersionStrength,
        glassIntensity: widget.glassIntensity,
        backgroundImage: _capturedBackground!,
      ),
    );
  }
}

/// Custom painter for entire surface liquid glass effect
class _EntireSurfacePainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double animationValue;
  final double width;
  final double height;
  final Offset mousePosition;
  final double effectSize;
  final double blurIntensity;
  final double dispersionStrength;
  final double glassIntensity;
  final ui.Image backgroundImage;

  _EntireSurfacePainter({
    required this.shader,
    required this.animationValue,
    required this.width,
    required this.height,
    required this.mousePosition,
    required this.effectSize,
    required this.blurIntensity,
    required this.dispersionStrength,
    required this.glassIntensity,
    required this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('🔍 [EntireSurface] Painting entire surface effect');
    
    // Set shader uniforms
    shader.setFloat(0, width);
    shader.setFloat(1, height);
    shader.setFloat(2, mousePosition.dx);
    shader.setFloat(3, mousePosition.dy);
    shader.setFloat(4, effectSize);
    shader.setFloat(5, blurIntensity);
    shader.setFloat(6, dispersionStrength);
    shader.setFloat(7, glassIntensity);
    
    // Set the background texture
    shader.setImageSampler(0, backgroundImage);
    
    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Predefined entire surface styles
class EntireSurfaceStyles {
  static Widget small({
    required Widget child,
    required GlobalKey backgroundKey,
    Color? borderColor,
    double glassIntensity = 0.2,
    double effectSize = 1.5,
  }) {
    return EntireSurfaceWidget(
      width: 80,
      height: 80,
      borderRadius: 12.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      borderWidth: 1.0,
      effectSize: effectSize,
      blurIntensity: 0.5,
      dispersionStrength: 0.1,
      glassIntensity: glassIntensity,
      backgroundKey: backgroundKey,
      child: child,
    );
  }

  static Widget medium({
    required Widget child,
    required GlobalKey backgroundKey,
    Color? borderColor,
    double glassIntensity = 0.3,
    double effectSize = 2.0,
  }) {
    return EntireSurfaceWidget(
      width: 200,
      height: 80,
      borderRadius: 16.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      borderWidth: 1.5,
      effectSize: effectSize,
      blurIntensity: 0.5,
      dispersionStrength: 0.1,
      glassIntensity: glassIntensity,
      backgroundKey: backgroundKey,
      child: child,
    );
  }

  static Widget large({
    required Widget child,
    required GlobalKey backgroundKey,
    Color? borderColor,
    double glassIntensity = 0.7,
    double effectSize = 3.0,
  }) {
    return EntireSurfaceWidget(
      width: 300,
      height: 150,
      borderRadius: 20.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      borderWidth: 2.0,
      effectSize: effectSize,
      blurIntensity: 0.8,
      dispersionStrength: 0.3,
      glassIntensity: glassIntensity,
      backgroundKey: backgroundKey,
      child: child,
    );
  }

  static Widget custom({
    required Widget child,
    required GlobalKey backgroundKey,
    double? width,
    double? height,
    double borderRadius = 12.0,
    Color borderColor = const Color(0xFF404040),
    double borderWidth = 1.0,
    double effectSize = 2.0,
    double blurIntensity = 0.5,
    double dispersionStrength = 0.1,
    double glassIntensity = 0.3,
    EdgeInsets padding = const EdgeInsets.all(16),
    EdgeInsets margin = EdgeInsets.zero,
    bool isDraggable = false,
    bool realTimeEffect = true,
  }) {
    return EntireSurfaceWidget(
      width: width,
      height: height ?? 200,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      effectSize: effectSize,
      blurIntensity: blurIntensity,
      dispersionStrength: dispersionStrength,
      glassIntensity: glassIntensity,
      padding: padding,
      margin: margin,
      isDraggable: isDraggable,
      realTimeEffect: realTimeEffect,
      backgroundKey: backgroundKey,
      child: child,
    );
  }
}
