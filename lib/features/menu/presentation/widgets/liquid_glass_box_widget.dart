import 'package:flutter/material.dart';
import '../../../../core/effects/liquid_glass/liquid_glass_lens_shader.dart'; // Back to original shader
import '../../../../core/effects/liquid_glass/background_capture_widget.dart';

/// A reusable liquid glass box widget with customizable size and position
class LiquidGlassBoxWidget extends StatefulWidget {
  final GlobalKey? backgroundKey;
  final double width;
  final double height;
  final Offset initialPosition;
  final double borderRadius;
  final Widget? child;
  final double leftMargin;
  final double rightMargin;
  final double topMargin;
  final double bottomMargin;
  final double debugBorderRadius;
  
  const LiquidGlassBoxWidget({
    super.key,
    this.backgroundKey,
    required this.width,
    required this.height,
    required this.initialPosition,
    this.borderRadius = 6.0,
    this.child,
    this.leftMargin = 50.0,
    this.rightMargin = 5.0,
    this.topMargin = 8.0,
    this.bottomMargin = 8.0,
    this.debugBorderRadius = 35.0,
  });

  @override
  State<LiquidGlassBoxWidget> createState() => LiquidGlassBoxWidgetState();
}

// Public state class to allow access from outside
class LiquidGlassBoxWidgetState extends State<LiquidGlassBoxWidget> {
  late LiquidGlassLensShader _liquidGlassShader;
  final GlobalKey<State<BackgroundCaptureWidget>> _backgroundCaptureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _liquidGlassShader = LiquidGlassLensShader();
    _initializeShader();
  }

  Future<void> _initializeShader() async {
    await _liquidGlassShader.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to trigger background capture
  void triggerBackgroundCapture() {
    final backgroundCaptureState = _backgroundCaptureKey.currentState;
    if (backgroundCaptureState != null) {
      (backgroundCaptureState as dynamic).triggerBackgroundCapture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundCaptureWidget(
            key: _backgroundCaptureKey,
            width: widget.width, // Use full width without padding reduction
            height: widget.height, // Use full height without padding reduction
            initialPosition: widget.initialPosition,
            backgroundKey: widget.backgroundKey,
            shader: _liquidGlassShader,
            leftMargin: widget.leftMargin,
            rightMargin: widget.rightMargin,
            topMargin: widget.topMargin,
            bottomMargin: widget.bottomMargin,
            borderRadius: widget.debugBorderRadius,
            child: widget.child ?? const SizedBox.shrink(),
          );
  }
}
