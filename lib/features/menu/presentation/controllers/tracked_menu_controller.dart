import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../../../core/utils/performance_logger.dart';
import '../../../../core/performance/tracking_mixins.dart';

/// Enhanced MenuController with advanced performance tracking
/// 
/// This version includes:
/// - Detailed state change tracking
/// - Listener count monitoring
/// - Processing time measurement
/// - Performance warnings for expensive operations
class TrackedMenuController extends ChangeNotifier with StatePerformanceTracking {
  static const String _performanceId = 'TrackedMenuController';
  final MenuRepository _menuRepository;

  TrackedMenuController(this._menuRepository) {
    _loadMenuItems();
  }

  @override
  String get stateId => _performanceId;

  MenuState _menuState = MenuState.close;
  MenuItems _selectedMenuItem = MenuItems.home;
  List<MenuEntity> _menuItems = [];
  
  // Hover state management with debouncing
  final Map<MenuItems, bool> _hoverStates = {};
  Timer? _hoverDebounceTimer;
  bool _hasPendingHoverUpdate = false;
  int _hoverUpdateCount = 0;
  int _skippedHoverUpdates = 0;
  
  // State batching mechanism
  bool _isBatching = false;
  bool _hasPendingUpdate = false;
  int _batchedUpdateCount = 0;

  // Getters
  MenuState get menuState => _menuState;
  MenuItems get selectedMenuItem => _selectedMenuItem;
  List<MenuEntity> get menuItems => _menuItems;

  void _loadMenuItems() {
    final startTime = DateTime.now();
    
    _menuItems = _menuRepository.getMenuItems();
    
    // Initialize hover states
    for (final item in _menuItems) {
      _hoverStates[item.id] = false;
    }
    
    final loadTime = DateTime.now().difference(startTime);
    
    PerformanceLogger.logAnimation(_performanceId, 'Menu items loaded', data: {
      'count': _menuItems.length,
      'loadTime': '${loadTime.inMicroseconds / 1000}ms',
    });
    
    notifyListeners(); // Tracked by StatePerformanceTracking mixin
  }

  bool isItemSelected(MenuItems id) {
    return _selectedMenuItem == id;
  }

  // Guard to prevent duplicate state changes
  bool _isProcessingStateChange = false;
  
  /// Batched state update mechanism with performance tracking
  void _batchUpdate(VoidCallback update) {
    final startTime = DateTime.now();
    
    update();
    
    if (!_isBatching) {
      _isBatching = true;
      _batchedUpdateCount = 0;
      
      scheduleMicrotask(() {
        _isBatching = false;
        if (_hasPendingUpdate) {
          _hasPendingUpdate = false;
          
          final batchTime = DateTime.now().difference(startTime);
          
          PerformanceLogger.logAnimation(
            _performanceId, 
            'Batched update executed',
            data: {
              'batchedUpdates': _batchedUpdateCount,
              'batchTime': '${batchTime.inMicroseconds / 1000}ms',
            },
          );
          
          notifyListeners(); // Tracked by mixin
        }
      });
    }
    
    _hasPendingUpdate = true;
    _batchedUpdateCount++;
  }
  
  void onMenuButtonTap() {
    final startTime = DateTime.now();
    
    // Guard: Prevent duplicate state change processing
    if (_isProcessingStateChange) {
      debugPrint('🚫 [MenuController] onMenuButtonTap ignored - already processing state change');
      return;
    }
    
    final oldState = _menuState;
    
    // Guard: Prevent redundant state changes
    final newState = _menuState == MenuState.open ? MenuState.close : MenuState.open;
    if (_menuState == newState) {
      debugPrint('🚫 [MenuController] State already in target state: $newState');
      return;
    }
    
    debugPrint('🎮 [MenuController] onMenuButtonTap called - Current state: $oldState');
    
    _isProcessingStateChange = true;
    
    // Use batched update for state change
    _batchUpdate(() {
      _menuState = newState;
      
      final processingTime = DateTime.now().difference(startTime);
      
      debugPrint('🎮 [MenuController] State changed: $oldState -> $_menuState in ${processingTime.inMicroseconds / 1000}ms');
      
      PerformanceLogger.logAnimation(_performanceId, 'Menu state changed', data: {
        'from': oldState.name,
        'to': _menuState.name,
        'processingTime': '${processingTime.inMicroseconds / 1000}ms',
      });
    });
    
    // Reset processing flag after microtask
    scheduleMicrotask(() {
      _isProcessingStateChange = false;
    });
  }

  Future<void> onSelectItem(MenuItems id) async {
    final startTime = DateTime.now();
    debugPrint('🎯 [MenuController] ===== ITEM SELECTION FLOW START =====');
    debugPrint('🎯 [MenuController] Item selection started: ${id.name}');
    
    // Guard: Prevent duplicate selection processing
    if (_selectedMenuItem == id) {
      debugPrint('🔄 [MenuController] Item already selected, closing menu smoothly');
      
      _batchUpdate(() {
        _menuState = MenuState.close;
      });
      
      debugPrint('🎯 [MenuController] ===== ITEM SELECTION FLOW END (SAME ITEM) =====');
      return;
    }
    
    final previousSelection = _selectedMenuItem;
    
    // Update selection
    _batchUpdate(() {
      _selectedMenuItem = id;
      
      PerformanceLogger.logAnimation(_performanceId, 'Item selected', data: {
        'item': id.name,
        'previousSelection': previousSelection.name,
      });
    });
    
    // Show selection animation
    await Future.delayed(const Duration(milliseconds: 304));
    
    // Transition to background
    if (_menuState == MenuState.open) {
      _batchUpdate(() {
        _menuState = MenuState.close;
      });
    }
    
    final totalTime = DateTime.now().difference(startTime);
    debugPrint('✅ [MenuController] Selection completed in ${totalTime.inMilliseconds}ms');
    debugPrint('🎯 [MenuController] ===== ITEM SELECTION FLOW END =====');
  }

  double getTune(MenuItems id) {
    final selectedIndex = _menuItems.indexWhere((element) => element.id == _selectedMenuItem);
    final currentIndex = _menuItems.indexWhere((element) => element.id == id);
    return 1 - ((currentIndex - selectedIndex).abs() / _menuItems.length);
  }
  
  bool isItemHovered(MenuItems id) {
    return _hoverStates[id] ?? false;
  }
  
  /// Get comprehensive performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    final total = _hoverUpdateCount + _skippedHoverUpdates;
    final efficiency = total > 0 ? (_skippedHoverUpdates / total * 100) : 0;
    
    return {
      'hoverUpdates': _hoverUpdateCount,
      'skippedUpdates': _skippedHoverUpdates,
      'totalAttempts': total,
      'efficiency': '${efficiency.toStringAsFixed(1)}%',
      'debouncingActive': _hoverDebounceTimer?.isActive ?? false,
      'batchedUpdates': _batchedUpdateCount,
      'currentState': _menuState.name,
      'selectedItem': _selectedMenuItem.name,
    };
  }
  
  /// Optimized hover update with performance tracking
  void updateMenuItemHover(MenuItems id, bool isHover) {
    final startTime = DateTime.now();
    
    // Early return if hover state hasn't changed
    if (_hoverStates[id] == isHover) {
      _skippedHoverUpdates++;
      return;
    }
    
    _hoverUpdateCount++;
    
    // Validate menu item exists
    final index = _menuItems.indexWhere((element) => element.id == id);
    if (index == -1) {
      debugPrint('⚠️ [MenuController] Invalid menu item ID: ${id.name}');
      return;
    }
    
    // Cancel any pending debounce timer
    _hoverDebounceTimer?.cancel();
    
    // Update hover state immediately in memory
    final previousHoverState = _hoverStates[id];
    _hoverStates[id] = isHover;
    _menuItems[index].isOnHover = isHover;
    _hasPendingHoverUpdate = true;
    
    // Debounce notifications with 16ms delay (1 frame)
    _hoverDebounceTimer = Timer(const Duration(milliseconds: 16), () {
      if (_hasPendingHoverUpdate) {
        _hasPendingHoverUpdate = false;
        
        final hoverTime = DateTime.now().difference(startTime);
        
        PerformanceLogger.logAnimation(
          _performanceId,
          'Hover state updated (debounced)',
          data: {
            'item': id.name,
            'previousState': previousHoverState,
            'newState': isHover,
            'processingTime': '${hoverTime.inMicroseconds / 1000}ms',
          },
        );
        
        _batchUpdate(() {
          // State already updated, just trigger notification
        });
      }
    });
  }
  
  @override
  void dispose() {
    // Clean up debounce timer
    _hoverDebounceTimer?.cancel();
    
    // Print final performance metrics
    final metrics = getPerformanceMetrics();
    debugPrint('📊 [MenuController] Final Performance Metrics:');
    metrics.forEach((key, value) {
      debugPrint('   $key: $value');
    });
    
    PerformanceLogger.logAnimation(_performanceId, 'Controller disposed');
    super.dispose();
  }
}
