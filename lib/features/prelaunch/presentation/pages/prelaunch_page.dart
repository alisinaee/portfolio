import 'package:flutter/material.dart';
import '../../../../features/menu/presentation/pages/landing_page.dart';
import '../../../../features/liquid_glass_test/presentation/pages/liquid_glass_test_page.dart';

class PrelaunchPage extends StatelessWidget {
  const PrelaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Title
            Text(
              'Moving Text Background',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Ganyme',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Choose your experience',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontFamily: 'Ganyme',
              ),
            ),
            SizedBox(height: 60),
            
            // Landing Page Button
            _buildButton(
              context: context,
              title: 'Landing Page',
              subtitle: 'Background Animation + Menu',
              icon: Icons.home,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LandingPage(),
                  ),
                );
              },
            ),
            
            SizedBox(height: 30),
            
            // Liquid Glass Test Button
            _buildButton(
              context: context,
              title: 'Liquid Glass Test',
              subtitle: 'Test the liquid glass effect',
              icon: Icons.visibility,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LiquidGlassTestPage(),
                  ),
                );
              },
            ),
            
            
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 300,
      height: 80,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1a1a1a),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Color(0xFF404040), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF404040),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Ganyme',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontFamily: 'Ganyme',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF404040),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
