import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/optimized_menu_controller.dart';
import '../../../../core/performance/immutable_state.dart';
import '../../../../core/animations/optimized_moving_text.dart';
import '../../../../core/animations/menu/diagonal_widget.dart';

/// Ultra-optimized background animation widget
/// Uses Canvas-based animations and immutable state for maximum performance
class OptimizedBackgroundAnimationWidget extends StatefulWidget {
  const OptimizedBackgroundAnimationWidget({super.key});

  @override
  State<OptimizedBackgroundAnimationWidget> createState() => _OptimizedBackgroundAnimationWidgetState();
}

class _OptimizedBackgroundAnimationWidgetState extends State<OptimizedBackgroundAnimationWidget>
    with TickerProviderStateMixin, OptimizedMenuMixin {
  
  late AnimationController _masterController;
  late Animation<double> _animationA;
  late Animation<double> _animationB;
  
  // Cache for performance
  ImmutableMenuState? _cachedState;
  Widget? _cachedWidget;

  @override
  void initState() {
    super.initState();
    
    // Single master animation controller for all animations
    _masterController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    
    _animationA = CurvedAnimation(
      parent: _masterController,
      curve: Curves.easeInOut,
    );
    
    _animationB = ReverseAnimation(_animationA);
    
    // Start the master animation
    _masterController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedMenuController>(
      builder: (context, controller, child) {
        // Use reference equality for ultra-fast change detection
        if (identical(_cachedState, controller.state) && _cachedWidget != null) {
          return _cachedWidget!;
        }

        _cachedState = controller.state;
        _cachedWidget = _buildOptimizedMenu(controller);
        
        return _cachedWidget!;
      },
    );
  }

  Widget _buildOptimizedMenu(OptimizedMenuController controller) {
    final isMenuOpen = controller.menuState == MenuStateEnum.open;
    
    return DiagonalWidget(
      child: Column(
        children: controller.menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isGroupB = index % 2 == 1;
          
          return _OptimizedMenuItem(
            key: ValueKey(item.id),
            item: item,
            isMenuOpen: isMenuOpen,
            animation: isGroupB ? _animationB : _animationA,
            groupReverse: isGroupB,
          );
        }).toList(),
      ),
    );
  }
}

/// Ultra-optimized menu item widget
class _OptimizedMenuItem extends StatefulWidget {
  final ImmutableMenuItem item;
  final bool isMenuOpen;
  final Animation<double> animation;
  final bool groupReverse;

  const _OptimizedMenuItem({
    super.key,
    required this.item,
    required this.isMenuOpen,
    required this.animation,
    required this.groupReverse,
  });

  @override
  State<_OptimizedMenuItem> createState() => _OptimizedMenuItemState();
}

class _OptimizedMenuItemState extends State<_OptimizedMenuItem> with OptimizedMenuMixin {
  // Cache for performance
  Widget? _cachedMenuContent;
  bool? _lastMenuOpenState;
  bool? _lastHoverState;
  bool? _lastSelectedState;

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedMenuController>(
      builder: (context, controller, child) {
        final isHovered = controller.isItemHovered(widget.item.id);
        final isSelected = controller.isItemSelected(widget.item.id);
        
        // Check if we can use cached content
        if (_lastMenuOpenState == widget.isMenuOpen &&
            _lastHoverState == isHovered &&
            _lastSelectedState == isSelected &&
            _cachedMenuContent != null) {
          return _buildWithCachedContent();
        }

        // Update cache
        _lastMenuOpenState = widget.isMenuOpen;
        _lastHoverState = isHovered;
        _lastSelectedState = isSelected;
        _cachedMenuContent = _buildMenuContent(controller, isHovered, isSelected);

        return _buildWithCachedContent();
      },
    );
  }

  Widget _buildWithCachedContent() {
    return TweenAnimationBuilder<double>(
      duration: widget.isMenuOpen 
          ? const Duration(milliseconds: 1500) 
          : const Duration(seconds: 8),
      tween: Tween(
        begin: 1000.0,
        end: widget.isMenuOpen 
            ? (_lastHoverState == true ? 1500.0 : 1000.0)
            : widget.item.flexSize * 100,
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
            child: RepaintBoundary(
              child: MouseRegion(
                onHover: (_) => _updateHover(true),
                onExit: (_) => _updateHover(false),
                child: GestureDetector(
                  onTap: widget.isMenuOpen ? _onTap : null,
                  child: OptimizedMovingTextFactory.create(
                    backgroundText: widget.item.text,
                    menuContent: _cachedMenuContent!,
                    isMenuOpen: widget.isMenuOpen,
                    delay: widget.item.delaySec,
                    reverse: widget.groupReverse ? !widget.item.reverse : widget.item.reverse,
                  ),
                ),
              ),
            ),
          ),
          if (widget.item.id != 'contact') const _OptimizedSeparator(),
        ],
      ),
    );
  }

  Widget _buildMenuContent(OptimizedMenuController controller, bool isHovered, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1500),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: isSelected ? Colors.white : Colors.transparent,
        ),
        color: isSelected 
            ? Colors.white 
            : Color.fromRGBO(255, 255, 255, _getTuneValue(controller) / 10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.item.iconPath != null) ...[
                Icon(
                  _getIconData(widget.item.iconPath!),
                  size: 40,
                  color: isSelected 
                      ? Colors.black 
                      : const Color.fromRGBO(255, 255, 255, 0.3),
                ),
                const SizedBox(width: 16),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 1500),
                    style: TextStyle(
                      fontSize: 100,
                      fontFamily: 'Avalon',
                      color: isSelected 
                          ? Colors.black 
                          : const Color.fromRGBO(255, 255, 255, 0.3),
                    ),
                    child: Text(
                      widget.item.title,
                      textScaler: const TextScaler.linear(1.2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getTuneValue(OptimizedMenuController controller) {
    final selectedIndex = controller.menuItems.indexWhere((item) => item.id == controller.selectedItemId);
    final currentIndex = controller.menuItems.indexWhere((item) => item.id == widget.item.id);
    return 1 - ((currentIndex - selectedIndex).abs() / controller.menuItems.length);
  }

  IconData _getIconData(String iconPath) {
    // Map icon paths to IconData
    switch (iconPath) {
      case 'assets/icons/home.svg':
        return Icons.home;
      case 'assets/icons/work.svg':
        return Icons.work;
      case 'assets/icons/apps.svg':
        return Icons.apps;
      case 'assets/icons/person.svg':
        return Icons.person;
      case 'assets/icons/contact_mail.svg':
        return Icons.contact_mail;
      default:
        return Icons.circle;
    }
  }

  void _updateHover(bool isHover) {
    context.read<OptimizedMenuController>().updateHover(widget.item.id, isHover);
  }

  void _onTap() {
    context.read<OptimizedMenuController>().selectItem(widget.item.id);
  }
}

/// Optimized separator widget
class _OptimizedSeparator extends StatelessWidget {
  const _OptimizedSeparator();

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