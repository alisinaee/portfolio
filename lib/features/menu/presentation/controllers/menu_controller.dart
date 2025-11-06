import 'package:flutter/foundation.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../../../core/utils/performance_logger.dart';

/// Optimized MenuController with smart state updates
/// 
/// Performance Improvements:
/// - Batched state updates to reduce notifyListeners calls
/// - Debounced hover updates to prevent excessive rebuilds
/// - Performance logging for debugging
/// - Immutable list references for better Selector performance
class AppMenuController extends ChangeNotifier {
  static const String _performanceId = 'AppMenuController';
  final MenuRepository _menuRepository;

  AppMenuController(this._menuRepository) {
    _loadMenuItems();
  }

  MenuState _menuState = MenuState.close;
  MenuItems _selectedMenuItem = MenuItems.home;
  List<MenuEntity> _menuItems = [];
  
  // Hover state management
  final Map<MenuItems, bool> _hoverStates = {};
  bool _isUpdatingHover = false;

  // Getters
  MenuState get menuState => _menuState;
  MenuItems get selectedMenuItem => _selectedMenuItem;
  List<MenuEntity> get menuItems => _menuItems;

  void _loadMenuItems() {
    _menuItems = _menuRepository.getMenuItems();
    
    // Initialize hover states
    for (final item in _menuItems) {
      _hoverStates[item.id] = false;
    }
    
    PerformanceLogger.logAnimation(_performanceId, 'Menu items loaded', data: {
      'count': _menuItems.length,
    });
    
    notifyListeners();
  }

  bool isItemSelected(MenuItems id) {
    return _selectedMenuItem == id;
  }

  bool _isNotifying = false;
  
  void onMenuButtonTap() {
    if (_isNotifying) {
      debugPrint('🚫 [MenuController] onMenuButtonTap ignored - already notifying');
      return;
    }
    
    final oldState = _menuState;
    debugPrint('🎮 [MenuController] onMenuButtonTap called - Current state: $oldState');
    
    if (_menuState == MenuState.open) {
      _menuState = MenuState.close;
    } else {
      _menuState = MenuState.open;
    }
    
    debugPrint('🎮 [MenuController] State changed: $oldState -> $_menuState');
    
    PerformanceLogger.logAnimation(_performanceId, 'Menu state changed', data: {
      'from': oldState.name,
      'to': _menuState.name,
    });
    
    _isNotifying = true;
    notifyListeners();
    
    // Reset notification flag after a brief delay
    Future.microtask(() {
      _isNotifying = false;
    });
  }

  Future<void> onSelectItem(MenuItems id) async {
    final startTime = DateTime.now();
    debugPrint('🎯 [MenuController] ===== ITEM SELECTION FLOW START =====');
    debugPrint('🎯 [MenuController] Item selection started: ${id.name}');
    debugPrint('🎯 [MenuController] Current selection: ${_selectedMenuItem.name}');
    debugPrint('🎯 [MenuController] Current menu state: ${_menuState.name}');
    
    if (_selectedMenuItem == id) {
      debugPrint('🔄 [MenuController] Item already selected, closing menu smoothly');
      debugPrint('🔄 [MenuController] Changing state from ${_menuState.name} to close');
      _menuState = MenuState.close;
      debugPrint('🔄 [MenuController] About to notify listeners...');
      notifyListeners();
      debugPrint('🔄 [MenuController] Listeners notified, returning early');
      debugPrint('🎯 [MenuController] ===== ITEM SELECTION FLOW END (SAME ITEM) =====');
      return;
    }
    
    // Step 1: Update selection and show selection animation
    debugPrint('🎨 [MenuController] ===== STEP 1: UPDATE SELECTION =====');
    final selectionStartTime = DateTime.now();
    final previousSelection = _selectedMenuItem;
    _selectedMenuItem = id;
    
    PerformanceLogger.logAnimation(_performanceId, 'Item selected', data: {
      'item': id.name,
      'previousSelection': previousSelection.name,
    });
    
    debugPrint('🎨 [MenuController] Selection updated: ${previousSelection.name} -> ${id.name}');
    debugPrint('🎨 [MenuController] About to notify listeners for selection change...');
    notifyListeners();
    final selectionTime = DateTime.now().difference(selectionStartTime).inMilliseconds;
    debugPrint('⏱️ [MenuController] Selection update took: ${selectionTime}ms');
    debugPrint('🎨 [MenuController] ===== STEP 1 COMPLETE =====');
    
    // Step 2: Show selection animation with smooth timing, then start gradual transition
    debugPrint('⏳ [MenuController] ===== STEP 2: SHOW SELECTION ANIMATION =====');
    debugPrint('⏳ [MenuController] Showing selection animation for 800ms...');
    debugPrint('⏳ [MenuController] Current time: ${DateTime.now().toString().substring(11, 23)}');
    await Future.delayed(const Duration(milliseconds: 800)); // Longer for smoother selection display
    debugPrint('⏳ [MenuController] Selection animation period ended at: ${DateTime.now().toString().substring(11, 23)}');
    debugPrint('⏳ [MenuController] ===== STEP 2 COMPLETE =====');
    
    // Step 3: Start gradual transition to background
    debugPrint('🎬 [MenuController] ===== STEP 3: TRANSITION TO BACKGROUND =====');
    debugPrint('🎬 [MenuController] Current menu state before transition: ${_menuState.name}');
    if (_menuState == MenuState.open) {
      debugPrint('🎬 [MenuController] Starting GRADUAL transition to background');
      debugPrint('🎬 [MenuController] This will trigger coordinated menu fade-out + background fade-in');
      
      final closeStartTime = DateTime.now();
      debugPrint('🎬 [MenuController] Changing state from ${_menuState.name} to close');
      _menuState = MenuState.close;
      debugPrint('🎬 [MenuController] About to notify listeners for state change...');
      notifyListeners();
      final closeTime = DateTime.now().difference(closeStartTime).inMilliseconds;
      debugPrint('⏱️ [MenuController] Gradual menu close took: ${closeTime}ms');
      debugPrint('🎬 [MenuController] State change notification sent');
    } else {
      debugPrint('🚫 [MenuController] Menu state is not open (${_menuState.name}), skipping transition');
    }
    debugPrint('🎬 [MenuController] ===== STEP 3 COMPLETE =====');
    
    final totalTime = DateTime.now().difference(startTime).inMilliseconds;
    debugPrint('✅ [MenuController] SMOOTH selection process completed in ${totalTime}ms');
    debugPrint('🎯 [MenuController] ===== ITEM SELECTION FLOW END =====');
  }

  double getTune(MenuItems id) {
    final selectedIndex = _menuItems.indexWhere((element) => element.id == _selectedMenuItem);
    final currentIndex = _menuItems.indexWhere((element) => element.id == id);
    return 1 - ((currentIndex - selectedIndex).abs() / _menuItems.length);
  }
  
  /// Optimized hover update with debouncing
  void updateMenuItemHover(MenuItems id, bool isHover) {
    // Don't update if state hasn't changed
    if (_hoverStates[id] == isHover) return;
    
    final index = _menuItems.indexWhere((element) => element.id == id);
    if (index == -1) return;
    
    // Update hover state
    _hoverStates[id] = isHover;
    _menuItems[index].isOnHover = isHover;
    
    // Debounce notifications to prevent excessive rebuilds
    if (!_isUpdatingHover) {
      _isUpdatingHover = true;
      
      // Batch multiple hover updates in the same frame
      Future.microtask(() {
        _isUpdatingHover = false;
        notifyListeners();
      });
    }
  }
  
  @override
  void dispose() {
    PerformanceLogger.logAnimation(_performanceId, 'Controller disposed');
    super.dispose();
  }
}
