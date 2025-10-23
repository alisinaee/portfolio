import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../../domain/entities/menu_entity.dart';

class MenuButtonWidget extends StatelessWidget {
  const MenuButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // Use Selector for more granular updates
      child: Selector<AppMenuController, MenuState>(
        selector: (_, controller) => controller.menuState,
        builder: (context, menuState, child) {
          // Use RepaintBoundary to isolate button repaints
          return RepaintBoundary(
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white54,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    menuState == MenuState.close 
                        ? Icons.menu 
                        : Icons.close,
                    color: Colors.white, // ✅ WHITE icon (visible on black background)
                    size: 28,
                  ),
                  onPressed: () => context.read<AppMenuController>().onMenuButtonTap(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
