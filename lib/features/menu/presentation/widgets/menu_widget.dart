import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../../domain/entities/menu_entity.dart';
import 'menu_item_widget.dart';
import '../../../../core/animations/menu/diagonal_widget.dart';

/// Optimized BackgroundAnimationWidget with Selector for granular rebuilds
/// 
/// Performance Improvements:
/// - Uses Selector instead of Consumer (only rebuilds when menuState/items change)
/// - Isolated menu item hover events (doesn't trigger full menu rebuild)
/// - RepaintBoundary for separators
/// - Const widgets where possible
class BackgroundAnimationWidget extends StatefulWidget {
  const BackgroundAnimationWidget({super.key});

  @override
  State<BackgroundAnimationWidget> createState() => _BackgroundAnimationWidgetState();
}

class _BackgroundAnimationWidgetState extends State<BackgroundAnimationWidget> with TickerProviderStateMixin {
  late final AnimationController _controller; // shared clock
  late final Animation<double> _animA; // direct
  late final Animation<double> _animB; // reverse of A
  bool _isAnimationActive = true;

  @override
  void initState() {
    super.initState();
    // One clock; B is exact reverse of A → always opposite direction
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 45));
    _animA = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _animB = ReverseAnimation(_animA);
    _startAnimation();
  }

  void _startAnimation() {
    if (_isAnimationActive && mounted) {
      _controller.repeat(reverse: true);
    }
  }

  void _pauseAnimation() {
    if (mounted) {
      _controller.stop();
      _isAnimationActive = false;
    }
  }

  void _resumeAnimation() {
    if (mounted && !_isAnimationActive) {
      _isAnimationActive = true;
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _isAnimationActive = false;
    _controller.dispose();
    super.dispose();
  }
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
      shouldRebuild: (previous, next) {
        final shouldRebuild = previous.state != next.state || previous.items != next.items;
        if (shouldRebuild) {
          debugPrint('🔄 [BackgroundAnimationWidget] State: ${previous.state} -> ${next.state}');
        }
        return shouldRebuild;
      },
      builder: (context, data, child) {
        final isMenuOpen = data.state == MenuState.open;
        
        return DiagonalWidget(
          child: Column(
            children: data.items.asMap().entries.map((entry) {
              final index = entry.key;
              final menuItem = entry.value;
              final isGroupB = index % 2 == 1; // 0,2,4 -> group A; 1,3 -> group B
              final shared = isGroupB ? _animB : _animA;
              return _MenuItem(
                key: ValueKey(menuItem.id),
                menuItem: menuItem,
                isMenuOpen: isMenuOpen,
                tweenManager: _tweenManager,
                sharedAnimation: shared,
                groupReverse: isGroupB, // make groups move in opposite directions
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
  final Animation<double> sharedAnimation;
  final bool groupReverse;

  const _MenuItem({
    super.key,
    required this.menuItem,
    required this.isMenuOpen,
    required this.tweenManager,
    required this.sharedAnimation,
    required this.groupReverse,
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
                        sharedAnimation: sharedAnimation,
                        groupReverse: groupReverse,
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
