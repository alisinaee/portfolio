import 'package:flutter/material.dart';
import '../widgets/background_animation_widget.dart';
import '../widgets/menu_button_widget.dart';
import '../widgets/about_section_widget.dart';
import '../widgets/liquid_glass_box_widget.dart';

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
          
          // Original about section with liquid glass effect
          AboutSectionWidget(backgroundKey: backgroundKey),
          
          // Multiple liquid glass boxes of different sizes
          // Small box (80x80)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 80,
            height: 80,
            initialPosition: Offset(300, 100),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: const Center(
                child: Text(
                  'Small',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // Medium box (120x120)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 120,
            height: 120,
            initialPosition: Offset(450, 150),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: const Center(
                child: Text(
                  'Medium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // Large box (200x200)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 200,
            height: 200,
            initialPosition: Offset(200, 300),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: const Center(
                child: Text(
                  'Large',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // Extra large box (300x150)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 300,
            height: 150,
            initialPosition: Offset(500, 350),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: const Center(
                child: Text(
                  'Extra Large',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // Tiny box (60x60)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 60,
            height: 60,
            initialPosition: Offset(100, 300),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: const Center(
                child: Text(
                  'Tiny',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
