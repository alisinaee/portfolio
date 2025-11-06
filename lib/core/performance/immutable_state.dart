import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Immutable state management for maximum performance
/// Prevents unnecessary rebuilds through reference equality
@immutable
class ImmutableMenuState {
  final MenuStateEnum state;
  final String selectedItemId;
  final Map<String, bool> hoverStates;
  final List<ImmutableMenuItem> items;
  final int version; // For change detection

  const ImmutableMenuState({
    required this.state,
    required this.selectedItemId,
    required this.hoverStates,
    required this.items,
    required this.version,
  });

  /// Create new state with changes (immutable update)
  ImmutableMenuState copyWith({
    MenuStateEnum? state,
    String? selectedItemId,
    Map<String, bool>? hoverStates,
    List<ImmutableMenuItem>? items,
  }) {
    return ImmutableMenuState(
      state: state ?? this.state,
      selectedItemId: selectedItemId ?? this.selectedItemId,
      hoverStates: hoverStates ?? this.hoverStates,
      items: items ?? this.items,
      version: version + 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImmutableMenuState && other.version == version;
  }

  @override
  int get hashCode => version.hashCode;
}

@immutable
class ImmutableMenuItem {
  final String id;
  final String title;
  final String text;
  final String? iconPath;
  final double flexSize;
  final int delaySec;
  final bool reverse;

  const ImmutableMenuItem({
    required this.id,
    required this.title,
    required this.text,
    this.iconPath,
    required this.flexSize,
    required this.delaySec,
    required this.reverse,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImmutableMenuItem &&
        other.id == id &&
        other.title == title &&
        other.text == text &&
        other.iconPath == iconPath &&
        other.flexSize == flexSize &&
        other.delaySec == delaySec &&
        other.reverse == reverse;
  }

  @override
  int get hashCode => Object.hash(id, title, text, iconPath, flexSize, delaySec, reverse);
}

enum MenuStateEnum { open, close }

/// High-performance state controller using immutable state
class ImmutableMenuController extends ChangeNotifier {
  ImmutableMenuState _state;
  
  ImmutableMenuController(List<ImmutableMenuItem> items)
      : _state = ImmutableMenuState(
          state: MenuStateEnum.close,
          selectedItemId: items.first.id,
          hoverStates: {for (final item in items) item.id: false},
          items: items,
          version: 0,
        );

  ImmutableMenuState get state => _state;

  /// Update state immutably - only notifies if actually changed
  void _updateState(ImmutableMenuState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void toggleMenu() {
    _updateState(_state.copyWith(
      state: _state.state == MenuStateEnum.open 
          ? MenuStateEnum.close 
          : MenuStateEnum.open,
    ));
  }

  void selectItem(String itemId) {
    if (_state.selectedItemId != itemId) {
      _updateState(_state.copyWith(selectedItemId: itemId));
      
      // Auto-close menu after selection
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_state.state == MenuStateEnum.open) {
          _updateState(_state.copyWith(state: MenuStateEnum.close));
        }
      });
    }
  }

  void updateHover(String itemId, bool isHover) {
    final currentHover = _state.hoverStates[itemId] ?? false;
    if (currentHover != isHover) {
      final newHoverStates = Map<String, bool>.from(_state.hoverStates);
      newHoverStates[itemId] = isHover;
      _updateState(_state.copyWith(hoverStates: newHoverStates));
    }
  }
}

/// Mixin for widgets that need to optimize rebuilds with immutable state
mixin ImmutableStateMixin<T extends StatefulWidget> on State<T> {
  Object? _lastState;

  /// Only rebuild if state reference actually changed
  bool shouldRebuildForState(Object newState) {
    if (identical(_lastState, newState)) {
      return false;
    }
    _lastState = newState;
    return true;
  }
}