import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../../domain/entities/menu_entity.dart';
import 'menu_item_widget.dart';
import '../../../../core/animations/menu/diagonal_widget.dart';
import '../../../../core/performance/performance_boost.dart';

/// Enhanced BackgroundAnimationWidget with smooth fade transitions
class EnhancedBackgroundAnimationWidget extends StatefulWidget {
  const EnhancedBackgroundAnimationWidget({super.key});

  @override
  State<EnhancedBackgroundAnimationWidget> createState() => _EnhancedBackgroundAnimationWidgetState();
}

class _EnhancedBackgroundAnimationWidgetState extends State<EnhancedBackgroundAnimationWidget> 
    with TickerProviderStateMixin, PerformanceMonitorMixin {
  
  late final AnimationController _controller;
  late final Animation<double> _animA;
  late final Animation<double> _animB;
  
  // Transition state management for smooth menu->background transition
  bool _isInTransition = false;
  bool _shouldShowMenu = false; // Start with background rows

  @override
  void initState() {
    super.initState();
    
    // PERFORMANCE: Optimized animation controller
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 25) // ⚡ OPTIMIZED: Reduced from 30s to 25s
    );
    _animA = CurvedAnimation(parent: _controller, curve: Curves.linear); // Linear is fastest
    _animB = ReverseAnimation(_animA);
    
    // Start with performance optimization
    PerformanceBoost.withOptimizedAnimation(
      controller: _controller,
      child: Container(),
    );
    
    _controller.repeat(reverse: true);
  }
  
  void _handleMenuTransition(MenuState currentState) {
    if (currentState == MenuState.open && !_shouldShowMenu && !_isInTransition) {
      // Menu is opening - start smooth transition from background rows to menu
      debugPrint('🎬 [EnhancedMenu] Menu opening - starting SMOOTH background->menu fade');
      _isInTransition = true;
      
      // PERFORMANCE: Optimized transitions
      Future.delayed(const Duration(milliseconds: 288), () { // ⚡ OPTIMIZED: 18 frames (288ms)
        // GUARD: Check mounted before setState
        if (!mounted || currentState != MenuState.open) return;
        
        debugPrint('🎬 [EnhancedMenu] Card fully faded - beginning smooth menu fade-in');
        setState(() {
          _shouldShowMenu = true;
        });
        
        // Complete transition with optimized timing
        Future.delayed(const Duration(milliseconds: 272), () { // ⚡ OPTIMIZED: 17 frames (272ms)
          // GUARD: Check mounted before setState
          if (!mounted || currentState != MenuState.open) return;
          
          debugPrint('🎬 [EnhancedMenu] Menu fade-in complete');
          setState(() {
            _isInTransition = false;
          });
        });
      });
    } else if (currentState == MenuState.close && _shouldShowMenu && !_isInTransition) {
      // Menu is closing - start smooth fade-out transition
      debugPrint('🎬 [EnhancedMenu] Menu closing - starting smooth fade-out');
      _isInTransition = true;
      
      // PERFORMANCE: Optimized close transition
      Future.delayed(const Duration(milliseconds: 288), () { // ⚡ OPTIMIZED: 18 frames (288ms)
        // GUARD: Check mounted before setState
        if (!mounted || currentState != MenuState.close) return;
        
        debugPrint('🎬 [EnhancedMenu] Smooth fade-out complete - hiding menu items');
        setState(() {
          _shouldShowMenu = false;
          _isInTransition = false;
        });
      });
    }
  }

  @override
  void dispose() {
    // GUARD: Ensure animation controller is disposed properly
    _controller.dispose();
    super.dispose();
  }

  Tween<double> _tweenManager({
    required MenuState menuState,
    required double flex,
    required bool isOnHover,
  }) {
    if (menuState == MenuState.open) {
      // ⚡ OPTIMIZED: Smoother hover - only 15% increase instead of 50%
      return Tween<double>(begin: 1000, end: isOnHover ? 1150 : 1000);
    } else {
      return Tween<double>(begin: 1000, end: flex * 100);
    }
  }

  @override
  Widget performanceBuild(BuildContext context) {
    return Selector<AppMenuController, ({MenuState state, List<MenuEntity> items})>(
      selector: (_, controller) => (
        state: controller.menuState,
        items: controller.menuItems,
      ),
      shouldRebuild: (previous, next) {
        final shouldRebuild = previous.state != next.state || 
                             !identical(previous.items, next.items);
        return shouldRebuild;
      },
      builder: (context, data, child) {
        // Use smart caching for performance
        return PerformanceBoost.withSmartRebuild<({MenuState state, List<MenuEntity> items})>(
          value: data,
          builder: (data) {
            // Smart menu visibility with transition handling
            _handleMenuTransition(data.state);
            
            // Show background rows when closed, menu items when opening/open
            final isMenuOpen = data.state == MenuState.open || _shouldShowMenu;
            final isInteractive = _shouldShowMenu;
            final isTransitioning = _isInTransition;
            
            return PerformanceBoost.withMemoryOptimization(
              child: RepaintBoundary( // ⚡ OPTIMIZED: Isolate repaints
                child: AnimatedOpacity(
                  opacity: isTransitioning ? 0.85 : 1.0, // ⚡ OPTIMIZED: Less dramatic fade
                  duration: const Duration(milliseconds: 224), // ⚡ OPTIMIZED: 14 frames (224ms)
                  curve: Curves.easeOut,
                  child: DiagonalWidget(
                  child: Column(
                    children: data.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final menuItem = entry.value;
                      final isGroupB = index % 2 == 1;
                      final shared = isGroupB ? _animB : _animA;
                      
                      return PerformanceBoost.withCache(
                        _EnhancedMenuItem(
                          key: ValueKey(menuItem.id),
                          menuItem: menuItem,
                          isMenuOpen: isMenuOpen,
                          isInteractive: isInteractive,
                          isTransitioning: isTransitioning,
                          tweenManager: _tweenManager,
                          sharedAnimation: shared,
                          groupReverse: isGroupB,
                        ),
                        cacheKey: '${menuItem.id}-$isMenuOpen-$isInteractive-$isTransitioning',
                      );
                    }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Enhanced MenuItem with smooth fade transitions - FIXED STRUCTURE
class _EnhancedMenuItem extends StatefulWidget {
  final MenuEntity menuItem;
  final bool isMenuOpen;
  final bool isInteractive;
  final bool isTransitioning;
  final Tween<double> Function({
    required MenuState menuState,
    required double flex,
    required bool isOnHover,
  }) tweenManager;
  final Animation<double> sharedAnimation;
  final bool groupReverse;

  const _EnhancedMenuItem({
    super.key,
    required this.menuItem,
    required this.isMenuOpen,
    required this.isInteractive,
    required this.isTransitioning,
    required this.tweenManager,
    required this.sharedAnimation,
    required this.groupReverse,
  });

  @override
  State<_EnhancedMenuItem> createState() => _EnhancedMenuItemState();
}

class _EnhancedMenuItemState extends State<_EnhancedMenuItem> with PerformanceMonitorMixin {

  @override
  Widget performanceBuild(BuildContext context) {
    return Selector<AppMenuController, ({MenuState state, bool isHover, bool isSelected})>(
      selector: (_, controller) => (
        state: controller.menuState,
        isHover: widget.menuItem.isOnHover,
        isSelected: controller.isItemSelected(widget.menuItem.id),
      ),
      shouldRebuild: (previous, next) =>
          previous.state != next.state ||
          previous.isHover != next.isHover ||
          previous.isSelected != next.isSelected,
      builder: (context, data, child) {
        return PerformanceBoost.withSmartRebuild<({MenuState state, bool isHover, bool isSelected})>(
          value: data,
          builder: (data) {
            // ⚡ OPTIMIZED: Smooth hover animations
            return TweenAnimationBuilder(
              duration: widget.isMenuOpen 
                  ? const Duration(milliseconds: 800) // ⚡ OPTIMIZED: Slower for smooth hover (50 frames)
                  : const Duration(seconds: 7), // ⚡ OPTIMIZED: Faster background animation
              tween: widget.tweenManager(
                menuState: data.state,
                flex: widget.menuItem.flexSize, 
                isOnHover: data.isHover,
              ),
              curve: Curves.easeInOut, // ⚡ OPTIMIZED: Smoother curve for hover
              builder: (context, value, child) {
                return Expanded(
                  flex: value.toInt(), 
                  child: AnimatedOpacity(
                    opacity: widget.isTransitioning ? 0.92 : 1.0, // ⚡ OPTIMIZED: Less dramatic fade
                    duration: const Duration(milliseconds: 176), // ⚡ OPTIMIZED: 11 frames (176ms)
                    curve: Curves.easeOut,
                    child: child!,
                  ),
                );
              },
              child: Column(
                children: [
                  Expanded(
                    child: PerformanceBoost.withMemoryOptimization(
                      child: RepaintBoundary(
                        child: MouseRegion(
                          onHover: (_) {
                            context.read<AppMenuController>()
                                .updateMenuItemHover(widget.menuItem.id, true);
                          },
                          onExit: (_) {
                            context.read<AppMenuController>()
                                .updateMenuItemHover(widget.menuItem.id, false);
                          },
                          child: GestureDetector(
                            onTap: () {
                              if (widget.isInteractive) {
                                final tapTime = DateTime.now();
                                debugPrint('🎯 [MenuItem] TAP on ${widget.menuItem.id.name} at ${tapTime.toString().substring(11, 23)}');
                                context.read<AppMenuController>().onSelectItem(widget.menuItem.id);
                              } else {
                                debugPrint('🚫 [MenuItem] TAP IGNORED - Menu not interactive');
                              }
                            },
                            child: PerformanceBoost.withCache(
                              MenuItemWidget(
                                menuItem: widget.menuItem,
                                isSelected: data.isSelected,
                                isMenuOpen: widget.isMenuOpen,
                                sharedAnimation: widget.sharedAnimation,
                                groupReverse: widget.groupReverse,
                              ),
                              cacheKey: '${widget.menuItem.id}-${data.isSelected}-${widget.isMenuOpen}',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.menuItem.id != MenuItems.contact) 
                    const _EnhancedMenuSeparator(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// ⚡ OPTIMIZED: Enhanced separator with performance optimization
class _EnhancedMenuSeparator extends StatelessWidget {
  const _EnhancedMenuSeparator();

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: SizedBox(
        width: double.infinity,
        height: 0.2,
        child: ColoredBox(color: Colors.white54),
      ),
    );
  }
}