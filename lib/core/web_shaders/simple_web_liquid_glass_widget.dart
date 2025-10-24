import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Simple web liquid glass widget for testing shader functionality
class SimpleWebLiquidGlassWidget extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;

  const SimpleWebLiquidGlassWidget({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 15.0,
    this.borderColor = const Color(0xFF404040),
    this.borderWidth = 1.0,
  });

  @override
  State<SimpleWebLiquidGlassWidget> createState() => _SimpleWebLiquidGlassWidgetState();
}

class _SimpleWebLiquidGlassWidgetState extends State<SimpleWebLiquidGlassWidget> 
    with TickerProviderStateMixin {
  ui.FragmentShader? _shader;
  bool _isInitialized = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Offset _mousePosition = Offset.zero;

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
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shader?.dispose();
    super.dispose();
  }

  Future<void> _initializeWebShader() async {
    if (!kIsWeb) {
      debugPrint('🔍 [SimpleWebLiquidGlass] Not on web platform, skipping shader initialization');
      return;
    }
    
    debugPrint('🔍 [SimpleWebLiquidGlass] Starting web shader initialization...');
    
    try {
      debugPrint('🔍 [SimpleWebLiquidGlass] Loading shader from asset: shaders/simple_test.frag');
      final program = await ui.FragmentProgram.fromAsset('shaders/simple_test.frag');
      debugPrint('🔍 [SimpleWebLiquidGlass] Shader program loaded successfully');
      
      _shader = program.fragmentShader();
      debugPrint('🔍 [SimpleWebLiquidGlass] Fragment shader created successfully');
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        debugPrint('🔍 [SimpleWebLiquidGlass] Shader initialization completed successfully');
      }
    } catch (e) {
      debugPrint('❌ [SimpleWebLiquidGlass] Error initializing web shader: $e');
      debugPrint('❌ [SimpleWebLiquidGlass] Stack trace: ${StackTrace.current}');
    }
  }

  void _updateMousePosition(Offset position) {
    debugPrint('🔍 [SimpleWebLiquidGlass] Mouse position updated: $position');
    setState(() {
      _mousePosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final widgetContent = Container(
      width: widget.width,
      height: widget.height,
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
            // Simple liquid glass effect without background capture
            if (_shader != null)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    debugPrint('🔍 [SimpleWebLiquidGlass] Rendering simple liquid glass effect');
                    return _buildSimpleLiquidGlassEffect();
                  },
                ),
              )
            else
              Builder(
                builder: (context) {
                  debugPrint('🔍 [SimpleWebLiquidGlass] Not rendering liquid glass effect');
                  debugPrint('🔍 [SimpleWebLiquidGlass] _shader: $_shader');
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

    return MouseRegion(
      onHover: (event) {
        _updateMousePosition(event.localPosition);
      },
      child: GestureDetector(
        onPanUpdate: (details) {
          _updateMousePosition(details.globalPosition);
        },
        child: widgetContent,
      ),
    );
  }

  Widget _buildSimpleLiquidGlassEffect() {
    debugPrint('🔍 [SimpleWebLiquidGlass] Building simple liquid glass effect');
    debugPrint('🔍 [SimpleWebLiquidGlass] Widget size: ${widget.width}x${widget.height}');
    debugPrint('🔍 [SimpleWebLiquidGlass] Mouse position: $_mousePosition');
    
    // Update shader uniforms
    final width = widget.width ?? 300;
    final height = widget.height ?? 200;
    
    debugPrint('🔍 [SimpleWebLiquidGlass] Setting shader uniforms...');
    debugPrint('🔍 [SimpleWebLiquidGlass] Resolution: ${width}x${height}');
    debugPrint('🔍 [SimpleWebLiquidGlass] Mouse: ${_mousePosition.dx}, ${_mousePosition.dy}');
    
    _shader!.setFloat(0, width.toDouble());
    _shader!.setFloat(1, height.toDouble());
    _shader!.setFloat(2, _mousePosition.dx);
    _shader!.setFloat(3, _mousePosition.dy);
    _shader!.setFloat(4, 2.0); // effectSize
    _shader!.setFloat(5, 0.5); // blurIntensity
    _shader!.setFloat(6, 0.1); // dispersionStrength
    _shader!.setFloat(7, 0.3); // glassIntensity
    
    debugPrint('🔍 [SimpleWebLiquidGlass] Shader uniforms set successfully');
    debugPrint('🔍 [SimpleWebLiquidGlass] Creating CustomPaint with size: ${width}x${height}');
    
    return CustomPaint(
      size: Size(width.toDouble(), height.toDouble()),
      painter: _SimpleWebLiquidGlassPainter(
        shader: _shader!,
        animationValue: _animation.value,
        width: width.toDouble(),
        height: height.toDouble(),
      ),
    );
  }
}

/// Custom painter for simple web liquid glass effect
class _SimpleWebLiquidGlassPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double animationValue;
  final double width;
  final double height;

  _SimpleWebLiquidGlassPainter({
    required this.shader,
    required this.animationValue,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('🔍 [SimpleWebLiquidGlassPainter] Painting with size: ${size.width}x${size.height}');
    debugPrint('🔍 [SimpleWebLiquidGlassPainter] Animation value: $animationValue');
    
    // Apply the liquid glass shader directly
    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    debugPrint('🔍 [SimpleWebLiquidGlassPainter] Paint completed');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
