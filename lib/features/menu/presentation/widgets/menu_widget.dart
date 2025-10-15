import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../../domain/entities/menu_entity.dart';
import 'menu_item_widget.dart';
import '../../../../core/animations/menu/diagonal_widget.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  Tween<double> _tweenManager({
    required MenuState menuState,
    required double flex,
    required bool isOnHover,
  }) {
    if (menuState == MenuState.open) {
      return Tween<double>(begin: 1000, end: isOnHover ? 1500 : 1000);
    } else {
      return Tween<double>(begin: 1000, end: flex * 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppMenuController>(
      builder: (context, menuController, child) {
        final isMenuOpen = menuController.menuState == MenuState.open;
        
        return DiagonalWidget(
          child: Column(
            children: menuController.menuItems.map((menuItem) {
              return TweenAnimationBuilder(
                duration: isMenuOpen 
                    ? const Duration(milliseconds: 2000) 
                    : const Duration(seconds: 10),
                tween: _tweenManager(
                  menuState: menuController.menuState,
                  flex: menuItem.flexSize, 
                  isOnHover: menuItem.isOnHover,
                ),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Expanded(
                    flex: value.toInt(), 
                    child: child!,
                  );
                },
                child: Column(
                  children: [
                    Expanded(
                      child: MouseRegion(
                        onHover: (_) {
                          menuController.updateMenuItemHover(menuItem.id, true);
                        },
                        onExit: (_) {
                          menuController.updateMenuItemHover(menuItem.id, false);
                        },
                        child: GestureDetector(
                          onTap: () => isMenuOpen 
                              ? menuController.onSelectItem(menuItem.id) 
                              : null,
                          child: MenuItemWidget(
                            menuItem: menuItem,
                            isSelected: menuController.isItemSelected(menuItem.id),
                            isMenuOpen: isMenuOpen,
                          ),
                        ),
                      ),
                    ),
                    if (menuController.menuItems.last != menuItem) _lineWidget(),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _lineWidget() {
    return Container(
      color: Colors.white54,
      width: double.infinity,
      height: 0.2,
    );
  }
}
