import 'package:flutter/material.dart';
import '../widgets/background_animation_widget.dart';
import '../widgets/menu_button_widget.dart';
import '../widgets/about_section_widget.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey backgroundKey = GlobalKey();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background animation with RepaintBoundary for liquid glass capture
          RepaintBoundary(
            key: backgroundKey,
            child: const BackgroundAnimationWidget(),
          ),
          
          // Menu button
          const Positioned(
            top: 20,
            left: 20,
            child: MenuButtonWidget(),
          ),
          
          // Single about section with liquid glass effect
          Positioned(
            top: 80,
            left: 20,
            child: AboutSectionWidget(backgroundKey: backgroundKey),
          ),
        ],
      ),
    );
  }
}
