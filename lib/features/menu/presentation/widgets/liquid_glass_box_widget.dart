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
  
  const LiquidGlassBoxWidget({
    super.key,
    this.backgroundKey,
    required this.width,
    required this.height,
    required this.initialPosition,
    this.borderRadius = 6.0,
    this.child,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackgroundCaptureWidget(
        key: _backgroundCaptureKey,
        width: widget.width,
        height: widget.height,
        initialPosition: widget.initialPosition,
        backgroundKey: widget.backgroundKey,
        shader: _liquidGlassShader,
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );
  }
}
