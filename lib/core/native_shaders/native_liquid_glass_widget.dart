import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'liquid_glass_platform_channel.dart';

/// Native liquid glass widget using platform channels for maximum performance
class NativeLiquidGlassWidget extends StatefulWidget {
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
  
  /// Effect size for the native shader
  final double effectSize;
  
  /// Blur intensity for the native shader
  final double blurIntensity;
  
  /// Dispersion strength for the native shader
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

  const NativeLiquidGlassWidget({
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
  State<NativeLiquidGlassWidget> createState() => _NativeLiquidGlassWidgetState();
}

class _NativeLiquidGlassWidgetState extends State<NativeLiquidGlassWidget> 
    with TickerProviderStateMixin {
  ui.Image? _processedImage;
  bool _isInitialized = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Offset _mousePosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializeNativeShader();
    
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _processedImage?.dispose();
    LiquidGlassPlatformChannel.dispose();
    super.dispose();
  }

  Future<void> _initializeNativeShader() async {
    try {
      final bool success = await LiquidGlassPlatformChannel.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = success;
        });
      }
    } catch (e) {
      debugPrint('Error initializing native shader: $e');
    }
  }

  Future<void> _captureAndProcessBackground() async {
    if (!_isInitialized || widget.backgroundKey?.currentContext == null) return;
    
    try {
      final boundary = widget.backgroundKey!.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !boundary.attached) return;
      
      final ui.Image backgroundImage = await boundary.toImage(pixelRatio: 1.0);
      
      // Process with native shader
      final ui.Image? processedImage = await LiquidGlassPlatformChannel.applyLiquidGlassEffect(
        backgroundImage: backgroundImage,
        width: (widget.width ?? 300) - (widget.padding.horizontal),
        height: (widget.height ?? 200) - (widget.padding.vertical),
        effectSize: widget.effectSize,
        blurIntensity: widget.blurIntensity,
        dispersionStrength: widget.dispersionStrength,
        glassIntensity: widget.glassIntensity,
        mousePosition: _mousePosition,
      );
      
      if (mounted && processedImage != null) {
        setState(() {
          _processedImage?.dispose();
          _processedImage = processedImage;
        });
      }
      
      backgroundImage.dispose();
    } catch (e) {
      debugPrint('Error capturing and processing background: $e');
    }
  }

  void _updateMousePosition(Offset position) {
    setState(() {
      _mousePosition = position;
    });
    
    if (widget.realTimeEffect) {
      _updateRealTimeEffect();
    }
  }

  Future<void> _updateRealTimeEffect() async {
    if (!_isInitialized) return;
    
    try {
      await LiquidGlassPlatformChannel.updateLiquidGlassParameters(
        effectSize: widget.effectSize,
        blurIntensity: widget.blurIntensity,
        dispersionStrength: widget.dispersionStrength,
        glassIntensity: widget.glassIntensity,
        mousePosition: _mousePosition,
      );
    } catch (e) {
      debugPrint('Error updating real-time effect: $e');
    }
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
            // Native liquid glass effect
            if (_processedImage != null)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(
                        (widget.width ?? 300) - (widget.padding.horizontal),
                        (widget.height ?? 200) - (widget.padding.vertical),
                      ),
                      painter: _NativeLiquidGlassPainter(
                        image: _processedImage!,
                        animationValue: _animation.value,
                      ),
                    );
                  },
                ),
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
        feedback: widgetContent,
        childWhenDragging: widgetContent,
        onDragUpdate: (details) {
          _updateMousePosition(details.globalPosition);
        },
        child: GestureDetector(
          onPanUpdate: (details) {
            _updateMousePosition(details.globalPosition);
          },
          child: widgetContent,
        ),
      );
    } else {
      return GestureDetector(
        onPanUpdate: (details) {
          _updateMousePosition(details.globalPosition);
        },
        child: widgetContent,
      );
    }
  }
}

/// Custom painter for native liquid glass effect
class _NativeLiquidGlassPainter extends CustomPainter {
  final ui.Image image;
  final double animationValue;

  _NativeLiquidGlassPainter({
    required this.image,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Draw the processed image from native shader
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      rect,
      Paint()..filterQuality = FilterQuality.high,
    );
    
    // Add subtle animation-based effects
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.1 * animationValue),
          Colors.transparent,
          Colors.white.withValues(alpha: 0.05 * animationValue),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Predefined native liquid glass widget styles
class NativeLiquidGlassStyles {
  /// A small widget for icons or small content
  static Widget small({
    required Widget child,
    required GlobalKey backgroundKey,
    Color? borderColor,
    double glassIntensity = 0.2,
    double effectSize = 1.5,
  }) {
    return NativeLiquidGlassWidget(
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
    return NativeLiquidGlassWidget(
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
    return NativeLiquidGlassWidget(
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
    return NativeLiquidGlassWidget(
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
