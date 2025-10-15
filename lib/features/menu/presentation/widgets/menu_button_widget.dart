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
            child: IconButton(
              icon: Icon(
                menuState == MenuState.close 
                    ? Icons.menu_outlined 
                    : Icons.close,
                color: Colors.black,
              ),
              style: IconButton.styleFrom(
                shape: const CircleBorder(),
                // Use const color with opacity
                backgroundColor: const Color.fromRGBO(255, 255, 255, 0.7),
              ),
              onPressed: () => context.read<AppMenuController>().onMenuButtonTap(),
            ),
          );
        },
      ),
    );
  }
}
