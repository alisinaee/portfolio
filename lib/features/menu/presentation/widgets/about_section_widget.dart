import 'package:flutter/material.dart';
import '../../../../core/effects/liquid_glass/liquid_glass_lens_shader.dart';
import '../../../../core/effects/liquid_glass/background_capture_widget.dart';

class AboutSectionWidget extends StatefulWidget {
  final GlobalKey? backgroundKey;
  
  const AboutSectionWidget({super.key, this.backgroundKey});

  @override
  State<AboutSectionWidget> createState() => _AboutSectionWidgetState();
}

class _AboutSectionWidgetState extends State<AboutSectionWidget> {
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
    return BackgroundCaptureWidget(
      width: 160,
      height: 160,
      initialPosition: Offset(100, 50),
      backgroundKey: widget.backgroundKey,
      shader: _liquidGlassShader,
      child: const SizedBox.shrink(),
    );
  }
}
