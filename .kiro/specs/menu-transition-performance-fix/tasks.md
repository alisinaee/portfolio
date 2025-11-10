# Implementation Plan: Menu Transition Performance Optimization

- [x] 1. Optimize AppMenuController state management
  - Implement batched state updates to reduce notifyListeners calls
  - Add state batching mechanism using microtasks to group multiple changes
  - Implement debouncing for hover state updates to prevent excessive rebuilds
  - Add guards to prevent duplicate state change processing
  - _Requirements: 1.1, 1.4, 4.1, 4.2_

- [x] 2. Reduce widget rebuilds with granular Selectors
- [x] 2.1 Replace Consumer with Selector in LandingPage
  - Replace broad Consumer<AppMenuController> with targeted Selector<AppMenuController, MenuState>
  - Implement shouldRebuild logic to prevent unnecessary rebuilds
  - Add mounted checks before setState calls
  - _Requirements: 4.1, 4.2_

- [x] 2.2 Optimize EnhancedBackgroundAnimationWidget rebuilds
  - Replace Consumer with Selector that only watches menuState and menuItems
  - Implement reference equality checks for menuItems list
  - Add shouldRebuild logic to compare previous and next state
  - _Requirements: 4.1, 4.2_

- [x] 2.3 Optimize _EnhancedMenuItem rebuilds
  - Implement Selector that only watches item-specific state (hover, selected)
  - Add shouldRebuild logic to prevent rebuilds when state hasn't changed
  - Ensure each menu item rebuilds independently
  - _Requirements: 4.1, 4.4_

- [x] 3. Add RepaintBoundary widgets for paint isolation
  - Wrap each _EnhancedMenuItem in RepaintBoundary to isolate repaints
  - Wrap MenuItemWidget in RepaintBoundary
  - Wrap static separators in RepaintBoundary
  - Wrap background animation in RepaintBoundary for liquid glass capture
  - _Requirements: 4.4, 5.1_

- [x] 4. Optimize animation timing and curves
- [x] 4.1 Reduce animation durations
  - Reduce _fadeController duration from 800ms to 400ms in LandingPage
  - Reduce menu transition delays from 600ms to 300ms
  - Reduce selection animation delay from 500ms to 300ms in AppMenuController
  - Reduce background animation duration from 30s to 20s
  - _Requirements: 1.1, 1.2, 5.2_

- [x] 4.2 Simplify animation curves
  - Replace Curves.easeInOut with Curves.easeOut in _fadeController
  - Replace complex curves with Curves.linear in background animation
  - Update all AnimatedOpacity curves to Curves.easeOut
  - _Requirements: 1.1, 5.1, 5.2_

- [x] 4.3 Optimize transition timing coordination
  - Align fade and scale animations to start simultaneously
  - Remove unnecessary Future.delayed chains
  - Ensure animation timing aligns with 16ms frame boundaries
  - _Requirements: 1.1, 1.3, 5.2_

- [x] 5. Convert static widgets to const constructors
  - Convert _EnhancedMenuSeparator to const constructor
  - Add const to all static Icon widgets
  - Add const to all static Text widgets where possible
  - Add const to all static Container decorations
  - _Requirements: 4.2, 4.3_

- [x] 6. Implement PerformanceMonitorMixin
  - Create PerformanceMonitorMixin that tracks rebuild counts
  - Add frame timing measurement to detect rebuilds faster than 16ms
  - Implement performanceBuild method that wraps build
  - Add debug logging for performance metrics
  - _Requirements: 3.1, 3.2, 3.4_

- [x] 7. Apply PerformanceMonitorMixin to key widgets
  - Add PerformanceMonitorMixin to _EnhancedBackgroundAnimationWidgetState
  - Add PerformanceMonitorMixin to _EnhancedMenuItemState
  - Add PerformanceMonitorMixin to _LandingPageState
  - Replace build methods with performanceBuild
  - _Requirements: 3.1, 3.2, 3.4_

- [x] 8. Optimize hover state management
  - Ensure hover state updates only affect specific menu items
  - Verify debouncing prevents excessive notifyListeners calls
  - Add early return if hover state hasn't changed
  - _Requirements: 1.1, 1.2, 4.4_

- [x] 9. Add animation disposal guards
  - Add mounted checks before all setState calls in animation callbacks
  - Ensure all AnimationControllers are disposed in dispose methods
  - Add null checks for animation controller operations
  - Wrap addPostFrameCallback with mounted checks
  - _Requirements: 5.3, 5.4_

- [x] 10. Validate performance improvements
  - Run Flutter DevTools Timeline to measure frame rates during transitions
  - Verify frame rate stays above 55 FPS during menu open/close
  - Measure widget rebuild counts using PerformanceMonitorMixin logs
  - Verify menu transitions complete within target durations
  - Compare before/after performance metrics
  - _Requirements: 1.1, 1.2, 1.3, 3.1, 3.2_

- [x] 11. Visual regression testing
  - Capture screenshots of menu in closed state
  - Capture screenshots of menu in open state
  - Capture screenshots of hover states
  - Compare with original implementation to ensure visual parity
  - Verify all animations maintain original visual appearance
  - _Requirements: 2.1, 2.2, 2.3, 2.4_
