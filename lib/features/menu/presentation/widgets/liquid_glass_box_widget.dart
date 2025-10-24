import 'package:flutter/material.dart';
import '../../../../core/effects/liquid_glass/rounded_liquid_glass_shader.dart';
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
  State<LiquidGlassBoxWidget> createState() => _LiquidGlassBoxWidgetState();
}

class _LiquidGlassBoxWidgetState extends State<LiquidGlassBoxWidget> {
  late RoundedLiquidGlassShader _liquidGlassShader;

  @override
  void initState() {
    super.initState();
    _liquidGlassShader = RoundedLiquidGlassShader();
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

  @override
  Widget build(BuildContext context) {
    return BackgroundCaptureWidget(
      width: widget.width,
      height: widget.height,
      initialPosition: widget.initialPosition,
      backgroundKey: widget.backgroundKey,
      shader: _liquidGlassShader,
      borderRadius: widget.borderRadius,
      child: widget.child ?? const SizedBox.shrink(),
    );
  }
}
