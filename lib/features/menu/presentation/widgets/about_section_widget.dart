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
    return Stack(
      children: [
        // EMPTY card - just a transparent container
        Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.transparent, // Completely transparent
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Color(0xFF404040), width: 1),
          ),
          // NO content inside - completely empty
        ),
        
        // Liquid Glass Lens Effect - exactly like the reference
        BackgroundCaptureWidget(
          width: 160,
          height: 160,
          initialPosition: Offset(100, 50),
          backgroundKey: widget.backgroundKey,
          shader: _liquidGlassShader,
          child: Center(
            child: Image.asset(
              'assets/images/photo.png',
              width: 72,
              height: 72,
            ),
          ),
        ),
      ],
    );
  }
}
