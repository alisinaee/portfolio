import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/performance/immutable_state.dart';
import '../../domain/entities/menu_entity.dart';

/// Ultra-optimized menu controller using immutable state
/// Prevents unnecessary rebuilds through reference equality checks
class OptimizedMenuController extends ChangeNotifier {
  ImmutableMenuState _state;
  bool _isNotifying = false;
  
  // Performance tracking
  int _stateChanges = 0;
  int _preventedNotifications = 0;

  OptimizedMenuController(List<MenuEntity> menuItems)
      : _state = ImmutableMenuState(
          state: MenuStateEnum.close,
          selectedItemId: menuItems.first.id.name,
          hoverStates: {for (final item in menuItems) item.id.name: false},
          items: menuItems.map(_convertToImmutable).toList(),
          version: 0,
        );

  static ImmutableMenuItem _convertToImmutable(MenuEntity entity) {
    return ImmutableMenuItem(
      id: entity.id.name,
      title: entity.title,
      text: entity.text,
      iconPath: entity.iconPath,
      flexSize: entity.flexSize,
      delaySec: entity.delaySec,
      reverse: entity.reverse,
    );
  }

  // Getters
  ImmutableMenuState get state => _state;
  MenuStateEnum get menuState => _state.state;
  String get selectedItemId => _state.selectedItemId;
  List<ImmutableMenuItem> get menuItems => _state.items;
  
  // Performance metrics
  int get stateChanges => _stateChanges;
  int get preventedNotifications => _preventedNotifications;

  /// Update state with change detection - only notifies if actually changed
  void _updateState(ImmutableMenuState newState) {
    if (identical(_state, newState)) {
      _preventedNotifications++;
      return;
    }

    if (_isNotifying) {
      _preventedNotifications++;
      return;
    }

    _state = newState;
    _stateChanges++;
    
    _isNotifying = true;
    notifyListeners();
    
    // Reset notification flag asynchronously
    Future.microtask(() {
      _isNotifying = false;
    });
  }

  /// Toggle menu state
  void toggleMenu() {
    final newState = _state.state == MenuStateEnum.open 
        ? MenuStateEnum.close 
        : MenuStateEnum.open;
    
    _updateState(_state.copyWith(state: newState));
  }

  /// Select menu item
  void selectItem(String itemId) {
    if (_state.selectedItemId == itemId) {
      // Already selected, just close menu
      _updateState(_state.copyWith(state: MenuStateEnum.close));
      return;
    }

    // Update selection
    _updateState(_state.copyWith(selectedItemId: itemId));
    
    // Auto-close menu after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_state.state == MenuStateEnum.open) {
        _updateState(_state.copyWith(state: MenuStateEnum.close));
      }
    });
  }

  /// Update hover state for item
  /// 
  /// Performance optimizations:
  /// - Early return if hover state hasn't changed (prevents unnecessary updates)
  /// - Only creates new state if hover state actually changed
  /// - Tracks prevented notifications for performance monitoring
  void updateHover(String itemId, bool isHover) {
    // OPTIMIZATION 1: Early return if hover state hasn't changed
    // This is the most important optimization - prevents unnecessary state updates
    final currentHover = _state.hoverStates[itemId] ?? false;
    if (currentHover == isHover) {
      _preventedNotifications++;
      if (kDebugMode) {
        debugPrint('🚫 [OptimizedMenuController] Hover update skipped for $itemId (no change: $isHover)');
      }
      return;
    }

    // OPTIMIZATION 2: Only create new state if hover actually changed
    // This ensures reference equality checks work properly in Selectors
    final newHoverStates = Map<String, bool>.from(_state.hoverStates);
    newHoverStates[itemId] = isHover;
    
    if (kDebugMode) {
      debugPrint('✅ [OptimizedMenuController] Hover state updated for $itemId: $currentHover -> $isHover');
    }
    
    // OPTIMIZATION 3: Use immutable state update
    // This triggers notification only if state reference changed
    _updateState(_state.copyWith(hoverStates: newHoverStates));
  }

  /// Check if item is selected
  bool isItemSelected(String itemId) {
    return _state.selectedItemId == itemId;
  }

  /// Check if item is hovered
  bool isItemHovered(String itemId) {
    return _state.hoverStates[itemId] ?? false;
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'stateChanges': _stateChanges,
      'preventedNotifications': _preventedNotifications,
      'currentVersion': _state.version,
      'efficiency': _preventedNotifications / (_stateChanges + _preventedNotifications),
    };
  }

  /// Reset performance counters
  void resetMetrics() {
    _stateChanges = 0;
    _preventedNotifications = 0;
  }
}

/// Optimized selector for menu state changes
class OptimizedMenuSelector<T> extends StatelessWidget {
  final T Function(ImmutableMenuState) selector;
  final Widget Function(BuildContext, T) builder;
  final bool Function(T, T)? shouldRebuild;

  const OptimizedMenuSelector({
    super.key,
    required this.selector,
    required this.builder,
    this.shouldRebuild,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedMenuController>(
      builder: (context, controller, child) {
        final selectedValue = selector(controller.state);
        return builder(context, selectedValue);
      },
    );
  }
}

/// Mixin for widgets that need optimized menu state access
mixin OptimizedMenuMixin<T extends StatefulWidget> on State<T> {
  ImmutableMenuState? _lastState;
  
  /// Check if menu state actually changed
  bool hasMenuStateChanged(OptimizedMenuController controller) {
    final currentState = controller.state;
    if (identical(_lastState, currentState)) {
      return false;
    }
    _lastState = currentState;
    return true;
  }
}