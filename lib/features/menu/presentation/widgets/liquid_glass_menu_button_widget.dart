import 'package:flutter/material.dart';
import '../../../../core/effects/liquid_glass/liquid_glass_lens_shader.dart';
import '../../../../core/effects/liquid_glass/background_capture_widget.dart';

class LiquidGlassMenuButtonWidget extends StatefulWidget {
  final GlobalKey? backgroundKey;
  final VoidCallback? onTap;

  const LiquidGlassMenuButtonWidget({
    super.key,
    this.backgroundKey,
    this.onTap,
  });

  @override
  State<LiquidGlassMenuButtonWidget> createState() => _LiquidGlassMenuButtonWidgetState();
}

class _LiquidGlassMenuButtonWidgetState extends State<LiquidGlassMenuButtonWidget> {
  late LiquidGlassLensShader _liquidGlassShader;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackgroundCaptureWidget(
          width: 50,
          height: 50,
          initialPosition: Offset.zero,
          backgroundKey: widget.backgroundKey,
          shader: _liquidGlassShader,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.2),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.menu,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
