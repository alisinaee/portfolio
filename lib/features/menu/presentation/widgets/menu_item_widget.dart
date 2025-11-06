import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../../domain/entities/menu_entity.dart';
import 'app_icon_widget.dart';
import '../../../../core/animations/moving_text/enhanced_moving_row.dart';
import '../../../../core/animations/menu/flip_animation.dart';

class MenuItemWidget extends StatelessWidget {
  final MenuEntity menuItem;
  final bool isSelected;
  final bool isMenuOpen;
  final Animation<double> sharedAnimation;
  final bool groupReverse;

  const MenuItemWidget({
    super.key,
    required this.menuItem,
    required this.isSelected,
    required this.isMenuOpen,
    required this.sharedAnimation,
    required this.groupReverse,
  });

  @override
  Widget build(BuildContext context) {
    return FlipAnimation(
      id: menuItem.id,
      child: EnhancedMovingRow(
        delaySec: menuItem.delaySec,
        reverse: groupReverse ? !menuItem.reverse : menuItem.reverse,
        isMenuOpen: isMenuOpen,
        sharedAnimation: sharedAnimation,
        childBackground: _buildBackground(),
        childMenu: _buildMenu(context),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Selector<AppMenuController, ({bool isSelected, double tune})>(
      selector: (_, controller) => (
        isSelected: controller.isItemSelected(menuItem.id),
        tune: controller.getTune(menuItem.id),
      ),
      builder: (context, data, child) {
        // Use RepaintBoundary to isolate this widget's repaints
        return RepaintBoundary(
          child: AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: data.isSelected 
                    ? Colors.white 
                    : Colors.transparent,
              ),
              // Use color with opacity directly instead of Opacity widget
              color: data.isSelected 
                  ? Colors.white 
                  : Color.fromRGBO(255, 255, 255, data.tune / 10),
            ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with RepaintBoundary
                if (menuItem.iconPath != null) ...[
                  RepaintBoundary(
                    child: AppIconWidget(
                      iconPath: menuItem.iconPath!,
                      width: 40,
                      height: 40,
                      color: data.isSelected 
                          ? Colors.black 
                          : const Color.fromRGBO(255, 255, 255, 0.3),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                // Title with RepaintBoundary
                RepaintBoundary(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(seconds: 2),
                      style: TextStyle(
                        fontSize: 100,
                        fontFamily: 'Avalon',
                        color: data.isSelected 
                            ? Colors.black 
                            : const Color.fromRGBO(255, 255, 255, 0.3),
                      ),
                      child: Text(
                        menuItem.title,
                        textScaler: const TextScaler.linear(1.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    // Use RepaintBoundary to isolate background text repaints
    return RepaintBoundary(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 1, color: Colors.transparent),
            bottom: BorderSide(width: 1, color: Colors.transparent),
            left: BorderSide(width: 1, color: Colors.transparent),
            right: BorderSide(width: 1, color: Colors.transparent),
          ),
          color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                menuItem.text,
                style: const TextStyle(
                  fontSize: 500,
                  fontFamily: 'Ganyme',
                  // Use solid color for better performance
                  color: Color(0xFF262626),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
