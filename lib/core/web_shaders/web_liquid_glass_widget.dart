import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Web-optimized liquid glass widget using Flutter's built-in shader system
class WebLiquidGlassWidget extends StatefulWidget {
  /// The child widget to display on top of the liquid glass effect
  final Widget child;
  
  /// Width of the glass effect area
  final double? width;
  
  /// Height of the glass effect area
  final double? height;
  
  /// Border radius of the glass effect
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
  
  /// Padding inside the widget
  final EdgeInsetsGeometry padding;
  
  /// Margin around the widget
  final EdgeInsetsGeometry margin;
  
  /// Whether the widget is draggable
  final bool isDraggable;
  
  /// Initial position for draggable widgets
  final Offset? initialPosition;
  
  /// Whether to use real-time effect updates
  final bool realTimeEffect;

  const WebLiquidGlassWidget({
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
    this.realTimeEffect = true,
  });

  @override
  State<WebLiquidGlassWidget> createState() => _WebLiquidGlassWidgetState();
}

class _WebLiquidGlassWidgetState extends State<WebLiquidGlassWidget> 
    with TickerProviderStateMixin {
  ui.FragmentShader? _shader;
  ui.Image? _capturedBackground;
  bool _isInitialized = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Offset _mousePosition = Offset.zero;
  Timer? _backgroundCaptureTimer;

  @override
  void initState() {
    super.initState();
    _initializeWebShader();
    
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
    
    // Capture background after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureAndProcessBackground();
    });

    // Also try to capture background after shader initialization
    _initializeWebShader().then((_) {
      if (mounted) {
        _captureAndProcessBackground();
        // Start continuous background capture
        _startContinuousBackgroundCapture();
      }
    });

    // Periodic retry to capture background
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _capturedBackground == null) {
        debugPrint('🔍 [WebLiquidGlass] Retrying background capture...');
        _captureAndProcessBackground();
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && _capturedBackground == null) {
        debugPrint('🔍 [WebLiquidGlass] Retrying background capture again...');
        _captureAndProcessBackground();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _capturedBackground?.dispose();
    _shader?.dispose();
    _backgroundCaptureTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeWebShader() async {
    if (!kIsWeb) {
      debugPrint('🔍 [WebLiquidGlass] Not on web platform, skipping shader initialization');
      return;
    }
    
    debugPrint('🔍 [WebLiquidGlass] Starting web shader initialization...');
    
    try {
      debugPrint('🔍 [WebLiquidGlass] Loading shader from asset: shaders/web_liquid_glass.frag');
      // Load the web-optimized shader
      final program = await ui.FragmentProgram.fromAsset('shaders/web_liquid_glass.frag');
      debugPrint('🔍 [WebLiquidGlass] Shader program loaded successfully');
      
      _shader = program.fragmentShader();
      debugPrint('🔍 [WebLiquidGlass] Fragment shader created successfully');
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        debugPrint('🔍 [WebLiquidGlass] Shader initialization completed successfully');
      }
    } catch (e) {
      debugPrint('❌ [WebLiquidGlass] Error initializing web shader: $e');
      debugPrint('❌ [WebLiquidGlass] Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _captureAndProcessBackground() async {
    if (!_isInitialized || widget.backgroundKey?.currentContext == null) {
      return; // Skip logging for continuous captures
    }
    
    try {
      // Get the background boundary
      final boundary = widget.backgroundKey!.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !boundary.attached) return;
      
      // Get our widget's position and size
      final ourBox = context.findRenderObject() as RenderBox?;
      if (ourBox == null || !ourBox.hasSize) return;
      
      // Calculate the region to capture (just behind our widget)
      final boundaryBox = boundary as RenderBox;
      final widgetRectInBoundary = Rect.fromPoints(
        boundaryBox.globalToLocal(ourBox.localToGlobal(Offset.zero)),
        boundaryBox.globalToLocal(ourBox.localToGlobal(ourBox.size.bottomRight(Offset.zero))),
      );
      
      final boundaryRect = Rect.fromLTWH(0, 0, boundaryBox.size.width, boundaryBox.size.height);
      final regionToCapture = widgetRectInBoundary.intersect(boundaryRect);
      
      if (regionToCapture.isEmpty) return;
      
      // Capture the full background and crop it to our region
      final ui.Image fullBackground = await boundary.toImage(pixelRatio: 1.0);
      
      // Create a cropped image from the full background
      final ui.Image backgroundImage = await _cropImage(fullBackground, regionToCapture);
      
      if (mounted) {
        setState(() {
          _capturedBackground?.dispose();
          _capturedBackground = backgroundImage;
        });
      }
    } catch (e) {
      // Skip error logging for continuous captures to avoid spam
    }
  }

  void _updateMousePosition(Offset position) {
    debugPrint('🔍 [WebLiquidGlass] Mouse position updated: $position');
    setState(() {
      _mousePosition = position;
    });
  }

  Future<ui.Image> _cropImage(ui.Image image, Rect cropRect) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    canvas.drawImageRect(
      image,
      cropRect,
      Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
      Paint(),
    );
    
    final picture = recorder.endRecording();
    return await picture.toImage(
      cropRect.width.toInt(),
      cropRect.height.toInt(),
    );
  }

  void _startContinuousBackgroundCapture() {
    debugPrint('🔍 [WebLiquidGlass] Starting continuous background capture...');
    _backgroundCaptureTimer?.cancel();
    // Use 33ms intervals (30 FPS) for better performance
    _backgroundCaptureTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (mounted && _isInitialized) {
        _captureAndProcessBackground();
      } else {
        timer.cancel();
      }
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
            // Web liquid glass effect
            if (_shader != null && _capturedBackground != null)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    debugPrint('🔍 [WebLiquidGlass] Rendering liquid glass effect');
                    return _buildWebLiquidGlassEffect();
                  },
                ),
              )
            else
              Builder(
                builder: (context) {
                  debugPrint('🔍 [WebLiquidGlass] Not rendering liquid glass effect');
                  debugPrint('🔍 [WebLiquidGlass] _shader: $_shader');
                  debugPrint('🔍 [WebLiquidGlass] _capturedBackground: $_capturedBackground');
                  return const SizedBox.shrink();
                },
              ),
            
            // Child content on top
            Positioned.fill(
              child: widget.child,
            ),
          ],
        ),
      ),
    );

    // Wrap with MouseRegion for hover tracking
    final mouseRegionContent = MouseRegion(
      onHover: (event) {
        _updateMousePosition(event.localPosition);
      },
      child: widgetContent,
    );

    // Return draggable or static version
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

  Widget _buildWebLiquidGlassEffect() {
    final width = (widget.width ?? 300) - (widget.padding.horizontal);
    final height = (widget.height ?? 200) - (widget.padding.vertical);
    
    return CustomPaint(
      size: Size(width, height),
      painter: _WebLiquidGlassPainter(
        shader: _shader!,
        animationValue: _animation.value,
        width: width,
        height: height,
        mousePosition: _mousePosition,
        effectSize: widget.effectSize,
        blurIntensity: widget.blurIntensity,
        dispersionStrength: widget.dispersionStrength,
        glassIntensity: widget.glassIntensity,
        backgroundImage: _capturedBackground,
      ),
    );
  }
}

/// Custom painter for web liquid glass effect
class _WebLiquidGlassPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double animationValue;
  final double width;
  final double height;
  final Offset mousePosition;
  final double effectSize;
  final double blurIntensity;
  final double dispersionStrength;
  final double glassIntensity;
  final ui.Image? backgroundImage;

  _WebLiquidGlassPainter({
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
    // Set shader uniforms every time we paint (like the working implementation)
    shader.setFloat(0, width);
    shader.setFloat(1, height);
    shader.setFloat(2, mousePosition.dx);
    shader.setFloat(3, mousePosition.dy);
    shader.setFloat(4, effectSize);
    shader.setFloat(5, blurIntensity);
    shader.setFloat(6, dispersionStrength);
    shader.setFloat(7, glassIntensity);
    
    if (backgroundImage != null) {
      try {
        shader.setImageSampler(0, backgroundImage!);
      } catch (e) {
        // Skip error logging for performance
      }
    }
    
    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Predefined web liquid glass widget styles
class WebLiquidGlassStyles {
  /// A small widget for icons or small content
  static Widget small({
    required Widget child,
    required GlobalKey backgroundKey,
    Color? borderColor,
    double glassIntensity = 0.2,
    double effectSize = 1.5,
  }) {
    return WebLiquidGlassWidget(
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

  /// A medium widget for text content or buttons
  static Widget medium({
    required Widget child,
    required GlobalKey backgroundKey,
    Color? borderColor,
    double? width,
    double? height,
    double glassIntensity = 0.3,
    double effectSize = 2.0,
  }) {
    return WebLiquidGlassWidget(
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

  /// A large widget for main content areas
  static Widget large({
    required Widget child,
    required GlobalKey backgroundKey,
    Color? borderColor,
    double? width,
    double? height,
    double glassIntensity = 0.4,
    double effectSize = 2.5,
  }) {
    return WebLiquidGlassWidget(
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

  /// A widget with custom styling for special effects
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
    bool realTimeEffect = true,
  }) {
    return WebLiquidGlassWidget(
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
      realTimeEffect: realTimeEffect,
      child: child,
    );
  }
}
