import 'package:flutter/material.dart';
import '../../../../core/effects/liquid_glass/background_capture_widget.dart';
import '../../../../core/effects/liquid_glass/liquid_glass_lens_shader.dart';

class LiquidGlassTestPage extends StatefulWidget {
  const LiquidGlassTestPage({super.key});

  @override
  State<LiquidGlassTestPage> createState() => _LiquidGlassTestPageState();
}

class _LiquidGlassTestPageState extends State<LiquidGlassTestPage>
    with TickerProviderStateMixin {
  final GlobalKey backgroundKey = GlobalKey();
  late LiquidGlassLensShader liquidGlassLensShader;

  @override
  void initState() {
    super.initState();
    liquidGlassLensShader = LiquidGlassLensShader();
    _initializeShader();
  }

  Future<void> _initializeShader() async {
    await liquidGlassLensShader.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildStaticImageBackground(),
    );
  }

  Widget _buildStaticImageBackground() {
    return Stack(
      children: [
        RepaintBoundary(
          key: backgroundKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/sample_1.png',
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/images/sample_2.jpg',
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/images/sample_3.jpg',
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
        BackgroundCaptureWidget(
          width: 160,
          height: 160,
          initialPosition: Offset(0, 0),
          backgroundKey: backgroundKey,
          shader: liquidGlassLensShader,
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