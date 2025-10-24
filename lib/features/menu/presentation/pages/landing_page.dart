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
          
          // Medium box (120x120)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 120,
            height: 120,
            initialPosition: Offset(450, 150),
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
          
          // Large box (200x200)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 200,
            height: 200,
            initialPosition: Offset(200, 300),
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
          
          // Extra large box (300x150)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 300,
            height: 150,
            initialPosition: Offset(500, 350),
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
          
          // Tiny box (60x60)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 60,
            height: 60,
            initialPosition: Offset(100, 300),
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
          
          // Rounded examples with different border radius
          // Small rounded (80x80, radius 20)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 80,
            height: 80,
            initialPosition: Offset(400, 100),
            borderRadius: 20.0,
            child: const Center(
              child: Text(
                'R20',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Medium rounded (100x100, radius 40)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 100,
            height: 100,
            initialPosition: Offset(500, 200),
            borderRadius: 40.0,
            child: const Center(
              child: Text(
                'R40',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Large rounded (120x120, radius 60)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 120,
            height: 120,
            initialPosition: Offset(300, 400),
            borderRadius: 60.0,
            child: const Center(
              child: Text(
                'R60',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Very rounded (100x100, radius 50 - almost circle)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 100,
            height: 100,
            initialPosition: Offset(150, 500),
            borderRadius: 50.0,
            child: const Center(
              child: Text(
                'R50',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Pill shape (200x80, radius 40)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 200,
            height: 80,
            initialPosition: Offset(400, 500),
            borderRadius: 40.0,
            child: const Center(
              child: Text(
                'Pill',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Square with small radius (120x120, radius 10)
          LiquidGlassBoxWidget(
            backgroundKey: backgroundKey,
            width: 120,
            height: 120,
            initialPosition: Offset(600, 300),
            borderRadius: 10.0,
            child: const Center(
              child: Text(
                'R10',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
