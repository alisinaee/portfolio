import 'package:flutter/material.dart';
import '../../../../core/widgets/liquid_glass_card.dart';

class LiquidGlassDemoPage extends StatelessWidget {
  const LiquidGlassDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey backgroundKey = GlobalKey();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: RepaintBoundary(
        key: backgroundKey,
        child: Stack(
          children: [
            // Background with moving text
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple, Colors.blue, Colors.green],
                ),
              ),
              child: const Center(
                child: Text(
                  'BACKGROUND TEXT',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white30,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
            
            // Demo cards showing different styles
            Positioned(
              top: 50,
              left: 50,
              child: LiquidGlassCardStyles.small(
                backgroundKey: backgroundKey,
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            
            Positioned(
              top: 50,
              right: 50,
              child: LiquidGlassCardStyles.medium(
                backgroundKey: backgroundKey,
                width: 250,
                height: 100,
                child: const Center(
                  child: Text(
                    'Medium Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            Positioned(
              bottom: 50,
              left: 50,
              child: LiquidGlassCardStyles.large(
                backgroundKey: backgroundKey,
                width: 300,
                height: 200,
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Large Card',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'With liquid glass effect',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Positioned(
              bottom: 50,
              right: 50,
              child: LiquidGlassCardStyles.custom(
                backgroundKey: backgroundKey,
                borderRadius: 25.0,
                borderColor: Colors.orange,
                borderWidth: 2.0,
                effectIntensity: 0.5,
                effectSize: 3.0,
                blurIntensity: 0.8,
                dispersionStrength: 0.2,
                width: 200,
                height: 150,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.red],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Custom\nCard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Center card with draggable feature
            Center(
              child: LiquidGlassCard(
                width: 250,
                height: 150,
                borderRadius: 20.0,
                borderColor: Colors.cyan,
                borderWidth: 2.0,
                backgroundKey: backgroundKey,
                effectIntensity: 0.4,
                effectSize: 2.5,
                blurIntensity: 0.6,
                dispersionStrength: 0.15,
                isDraggable: true,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Colors.cyan, Colors.blue],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Drag me!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
