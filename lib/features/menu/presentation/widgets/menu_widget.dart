import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../../domain/entities/menu_entity.dart';
import 'menu_item_widget.dart';
import '../../../../core/animations/menu/diagonal_widget.dart';

/// Optimized MenuWidget with Selector for granular rebuilds
/// 
/// Performance Improvements:
/// - Uses Selector instead of Consumer (only rebuilds when menuState/items change)
/// - Isolated menu item hover events (doesn't trigger full menu rebuild)
/// - RepaintBoundary for separators
/// - Const widgets where possible
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
    // Use Selector instead of Consumer for granular rebuilds
    // Only rebuilds when menuState or menuItems actually change
    return Selector<AppMenuController, ({MenuState state, List<MenuEntity> items})>(
      selector: (_, controller) => (
        state: controller.menuState,
        items: controller.menuItems,
      ),
      // shouldRebuild only when state or items reference changes
      shouldRebuild: (previous, next) => 
          previous.state != next.state || 
          previous.items != next.items,
      builder: (context, data, child) {
        final isMenuOpen = data.state == MenuState.open;
        
        return DiagonalWidget(
          child: Column(
            children: data.items.map((menuItem) {
              return _MenuItem(
                key: ValueKey(menuItem.id),
                menuItem: menuItem,
                isMenuOpen: isMenuOpen,
                tweenManager: _tweenManager,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Isolated MenuItem widget to prevent full menu rebuilds on hover
class _MenuItem extends StatelessWidget {
  final MenuEntity menuItem;
  final bool isMenuOpen;
  final Tween<double> Function({
    required MenuState menuState,
    required double flex,
    required bool isOnHover,
  }) tweenManager;

  const _MenuItem({
    super.key,
    required this.menuItem,
    required this.isMenuOpen,
    required this.tweenManager,
  });

  @override
  Widget build(BuildContext context) {
    // Use Selector to only rebuild when THIS item's hover state changes
    return Selector<AppMenuController, ({MenuState state, bool isHover, bool isSelected})>(
      selector: (_, controller) => (
        state: controller.menuState,
        isHover: menuItem.isOnHover,
        isSelected: controller.isItemSelected(menuItem.id),
      ),
      shouldRebuild: (previous, next) =>
          previous.state != next.state ||
          previous.isHover != next.isHover ||
          previous.isSelected != next.isSelected,
      builder: (context, data, child) {
        return TweenAnimationBuilder(
          duration: isMenuOpen 
              ? const Duration(milliseconds: 2000) 
              : const Duration(seconds: 10),
          tween: tweenManager(
            menuState: data.state,
            flex: menuItem.flexSize, 
            isOnHover: data.isHover,
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
                // RepaintBoundary to isolate this menu item
                child: RepaintBoundary(
                  child: MouseRegion(
                    // Use read() instead of watch() to avoid rebuilds
                    onHover: (_) {
                      context.read<AppMenuController>()
                          .updateMenuItemHover(menuItem.id, true);
                    },
                    onExit: (_) {
                      context.read<AppMenuController>()
                          .updateMenuItemHover(menuItem.id, false);
                    },
                    child: GestureDetector(
                      onTap: () => isMenuOpen 
                          ? context.read<AppMenuController>()
                              .onSelectItem(menuItem.id) 
                          : null,
                      child: MenuItemWidget(
                        menuItem: menuItem,
                        isSelected: data.isSelected,
                        isMenuOpen: isMenuOpen,
                      ),
                    ),
                  ),
                ),
              ),
              // Only show separator if not last item
              if (menuItem.id != MenuItems.contact) 
                const _MenuSeparator(),
            ],
          ),
        );
      },
    );
  }
}

/// Const separator widget with RepaintBoundary
class _MenuSeparator extends StatelessWidget {
  const _MenuSeparator();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: Colors.white54,
        width: double.infinity,
        height: 0.2,
      ),
    );
  }
}
