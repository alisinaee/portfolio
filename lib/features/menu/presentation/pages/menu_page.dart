import 'package:flutter/material.dart';
import '../widgets/menu_widget.dart';
import '../widgets/menu_button_widget.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(child: MenuWidget()),
          const Positioned(
            top: 0,
            left: 0,
            child: MenuButtonWidget(),
          ),
        ],
      ),
    );
  }
}
