import 'package:flutter/material.dart';
import '../widgets/enhanced_menu_widget.dart' as bg;
import '../widgets/liquid_glass_box_widget.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../../domain/entities/menu_entity.dart';
import '../../../../core/performance/performance_boost.dart';


class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin, PerformanceMonitorMixin<LandingPage> {
  final GlobalKey backgroundKey = GlobalKey();
  final GlobalKey<LiquidGlassBoxWidgetState> _mainCardKey = GlobalKey();
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Debounce variables
  bool _isAnimating = false;
  DateTime? _lastTapTime;
  bool _isMenuAnimating = false;
  bool _isProcessingStateChange = false;
  
  // Perfect values from debug panel
  final double _leftMargin = 100.5;
  final double _rightMargin = 101.0;
  final double _topMargin = 2.5;
  final double _bottomMargin = 2.5;
  final double _borderRadius = 166.5;
  
  // Content positioning offsets - perfect centering
  final double _contentOffsetX = 0.0;
  final double _contentOffsetY = 0.0;
  


  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 288), // ⚡ OPTIMIZED: 18 frames (288ms)
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.985, // ⚡ OPTIMIZED: Minimal scale for better performance
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Ensure the card starts visible when menu is closed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // GUARD: Check mounted before accessing state
      if (!mounted) return;
      
      final menuController = Provider.of<AppMenuController>(context, listen: false);
      if (menuController.menuState == MenuState.close) {
        _fadeController.reset();
      }
    });
  }

  MenuState? _lastProcessedState;
  
  void _handleMenuStateChange(AppMenuController menuController) {
    final startTime = DateTime.now();
    
    debugPrint('🔄 [MenuState] ===== STATE CHANGE HANDLER START =====');
    debugPrint('🔄 [MenuState] STATE CHANGE TRIGGERED: ${menuController.menuState}');
    debugPrint('🔄 [MenuState] Time: ${DateTime.now().toString().substring(11, 23)}');
    debugPrint('🔄 [MenuState] Current animation states:');
    debugPrint('🔄 [MenuState]   - _isAnimating: $_isAnimating');
    debugPrint('🔄 [MenuState]   - _isMenuAnimating: $_isMenuAnimating');
    debugPrint('🔄 [MenuState]   - _isProcessingStateChange: $_isProcessingStateChange');
    debugPrint('🔄 [MenuState]   - _lastProcessedState: $_lastProcessedState');
    debugPrint('🔄 [MenuState]   - fadeController.status: ${_fadeController.status}');
    debugPrint('🔄 [MenuState]   - fadeController.value: ${_fadeController.value}');
    
    // Prevent processing if already processing a state change
    if (_isProcessingStateChange) {
      debugPrint('🚫 [MenuState] PROCESSING IN PROGRESS - ignoring: ${menuController.menuState}');
      debugPrint('🔄 [MenuState] ===== STATE CHANGE HANDLER END (IGNORED) =====');
      return;
    }
    
    // Prevent processing the same state change multiple times
    if (_lastProcessedState == menuController.menuState) {
      debugPrint('🚫 [MenuState] DUPLICATE state change ignored: ${menuController.menuState}');
      debugPrint('🔄 [MenuState] ===== STATE CHANGE HANDLER END (DUPLICATE) =====');
      return;
    }
    
    _isProcessingStateChange = true;
    _lastProcessedState = menuController.menuState;
    debugPrint('🔄 [MenuState] STATE ACCEPTED - Processing: ${menuController.menuState}');
    
    if (menuController.menuState == MenuState.close) {
      debugPrint('🎬 [MenuState] ===== CLOSE STATE PROCESSING START =====');
      debugPrint('🎬 [MenuState] MENU CLOSING - Starting crossfade transition');
      debugPrint('🎬 [MenuState] Current fade controller status: ${_fadeController.status}');
      debugPrint('🎬 [MenuState] Current fade controller value: ${_fadeController.value}');
      
      final setStateStartTime = DateTime.now();
      debugPrint('🎬 [MenuState] About to call setState for close...');
      if (mounted) {
        setState(() {
          _isMenuAnimating = false;
        });
      }
      final setStateTime = DateTime.now().difference(setStateStartTime).inMilliseconds;
      debugPrint('⏱️ [MenuState] setState (close) took: ${setStateTime}ms');
      debugPrint('🎬 [MenuState] setState complete, new states:');
      debugPrint('🎬 [MenuState]   - _isMenuAnimating: $_isMenuAnimating');
      
      // Start crossfade transition immediately
      debugPrint('🎬 [MenuState] Starting crossfade: menu fade-out + card fade-in');
      debugPrint('🎬 [MenuState] About to call _fadeController.reverse()...');
      final fadeStartTime = DateTime.now();
      
      // Ultra-smooth crossfade: card fades in as menu fades out with extended timing
      // GUARD: Check if widget is still mounted before starting animation
      if (!mounted) {
        debugPrint('🚫 [MenuState] Widget not mounted, skipping fade animation');
        _isProcessingStateChange = false;
        return;
      }
      
      _fadeController.reverse().then((_) {
        // GUARD: Check mounted before processing animation completion
        if (!mounted) {
          debugPrint('🚫 [MenuState] Widget not mounted after fade, skipping completion');
          return;
        }
        
        final fadeTime = DateTime.now().difference(fadeStartTime).inMilliseconds;
        debugPrint('🎬 [MenuState] *** ULTRA-SMOOTH FADE REVERSE COMPLETED ***');
        debugPrint('🎬 [MenuState] Crossfade completed in ${fadeTime}ms');
        debugPrint('🎬 [MenuState] Final fade controller status: ${_fadeController.status}');
        debugPrint('🎬 [MenuState] Final fade controller value: ${_fadeController.value}');
        
        // Add extra delay to ensure menu fully fades before showing card
        Future.delayed(const Duration(milliseconds: 192), () { // ⚡ OPTIMIZED: 12 frames (192ms)
          if (mounted) {
            debugPrint('🎬 [MenuState] Widget still mounted, calling final setState...');
            final finalSetStateStartTime = DateTime.now();
            setState(() {
              _isAnimating = false;
            });
            final finalSetStateTime = DateTime.now().difference(finalSetStateStartTime).inMilliseconds;
            debugPrint('⏱️ [MenuState] Final setState took: ${finalSetStateTime}ms');
            debugPrint('🎬 [MenuState] Final states:');
            debugPrint('🎬 [MenuState]   - _isAnimating: $_isAnimating');
            
            final totalTime = DateTime.now().difference(startTime).inMilliseconds;
            debugPrint('✅ [MenuState] ULTRA-SMOOTH CROSSFADE COMPLETE in ${totalTime}ms');
            _isProcessingStateChange = false; // Reset processing flag
            debugPrint('🎬 [MenuState] Processing flag reset');
          } else {
            debugPrint('🚫 [MenuState] Widget not mounted, skipping final setState');
            _isProcessingStateChange = false;
          }
          debugPrint('🎬 [MenuState] ===== CLOSE STATE PROCESSING END =====');
        });
      }).catchError((error) {
        debugPrint('🚨 [MenuState] ERROR in fade controller reverse: $error');
        _isProcessingStateChange = false;
      });
    } else if (menuController.menuState == MenuState.open) {
      debugPrint('🎬 [MenuState] MENU OPENING - Coordinating with background animation');
      
      final setStateStartTime = DateTime.now();
      if (mounted) {
        setState(() {
          _isMenuAnimating = true;
        });
      }
      final setStateTime = DateTime.now().difference(setStateStartTime).inMilliseconds;
      debugPrint('⏱️ [MenuState] setState (open) took: ${setStateTime}ms');
      
      // Reset animation flags after menu opens with optimized timing
      debugPrint('⏳ [MenuState] Waiting 272ms for menu open animation...'); // ⚡ OPTIMIZED: 17 frames
      Future.delayed(const Duration(milliseconds: 272), () { // ⚡ OPTIMIZED: 17 frames (272ms)
        // GUARD: Check mounted before setState
        if (mounted && _lastProcessedState == MenuState.open) {
          final finalSetStateStartTime = DateTime.now();
          setState(() {
            _isAnimating = false; // CRITICAL: Reset this so close button works
            _isMenuAnimating = false; // Also reset this
          });
          final finalSetStateTime = DateTime.now().difference(finalSetStateStartTime).inMilliseconds;
          debugPrint('⏱️ [MenuState] Final setState (open) took: ${finalSetStateTime}ms');
          debugPrint('🔓 [MenuState] Animation flags RESET - Close button now enabled');
          
          final totalTime = DateTime.now().difference(startTime).inMilliseconds;
          debugPrint('✅ [MenuState] SMOOTH MENU OPEN COMPLETE in ${totalTime}ms - CLOSE BUTTON READY');
          _isProcessingStateChange = false; // Reset processing flag
        } else if (!mounted) {
          debugPrint('🚫 [MenuState] Widget not mounted, skipping final setState');
          _isProcessingStateChange = false;
        }
      });
    }
    
    // Fallback: Reset processing flag after a timeout
    Future.delayed(const Duration(seconds: 2), () {
      // GUARD: Check mounted before accessing state
      if (mounted && _isProcessingStateChange) {
        debugPrint('⚠️ [MenuState] Timeout - resetting processing flag');
        _isProcessingStateChange = false;
      }
    });
  }

  Widget _buildCardContent() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Content container for positioning
          Transform.translate(
            offset: Offset(_contentOffsetX, _contentOffsetY),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hero Section
                Text(
                  'Hello, I\'m',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 24,
                    fontFamily: 'Ganyme',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ALI SINAEE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontFamily: 'Ganyme',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.4),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Description
                Text(
                  'Senior Flutter Expert & Mobile App Developer',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.4),
                    fontSize: 28,
                    fontFamily: 'Ganyme',
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                
                // CTA Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: Colors.white.withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'GET IN TOUCH',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.5),
                      fontSize: 18,
                      fontFamily: 'Ganyme',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onMenuTap() {
    final now = DateTime.now();
    debugPrint('🎯 [MenuButton] TAP DETECTED at ${now.toString().substring(11, 23)}');
    debugPrint('🎯 [MenuButton] _isAnimating: $_isAnimating, _isMenuAnimating: $_isMenuAnimating');
    
    if (_isAnimating || _isMenuAnimating) {
      debugPrint('🚫 [MenuButton] TAP IGNORED - Animation in progress');
      return; // Ignore taps during animation
    }
    
    if (_lastTapTime != null) {
      final timeDiff = now.difference(_lastTapTime!).inMilliseconds;
      debugPrint('🎯 [MenuButton] Time since last tap: ${timeDiff}ms');
      if (timeDiff < 500) {
        debugPrint('🚫 [MenuButton] TAP IGNORED - Debounce active (${timeDiff}ms < 500ms)');
        return; // Debounce: ignore taps within 500ms
      }
    }
    
    debugPrint('✅ [MenuButton] TAP ACCEPTED - Starting menu animation');
    _lastTapTime = now;
    
    final startTime = DateTime.now();
    if (mounted) {
      setState(() {
        _isAnimating = true;
      });
    }
    final setStateTime = DateTime.now().difference(startTime).inMilliseconds;
    debugPrint('⏱️ [MenuButton] setState took: ${setStateTime}ms');
    
    final menuController = Provider.of<AppMenuController>(context, listen: false);
    
    // Fade out the card and trigger menu state change when complete
    debugPrint('🎬 [MenuButton] Starting card fade-out animation');
    final fadeStartTime = DateTime.now();
    
    // GUARD: Check if widget is still mounted before starting animation
    if (!mounted) {
      debugPrint('🚫 [MenuButton] Widget not mounted, skipping fade animation');
      return;
    }
    
    // PERFORMANCE: Trigger menu state change immediately when fade completes (no unnecessary delay)
    _fadeController.forward().then((_) {
      // GUARD: Check mounted before processing animation completion
      if (!mounted) {
        debugPrint('🚫 [MenuButton] Widget not mounted after fade, skipping menu state change');
        return;
      }
      
      final fadeTime = DateTime.now().difference(fadeStartTime).inMilliseconds;
      debugPrint('🎬 [MenuButton] Card fade-out completed in ${fadeTime}ms');
      
      debugPrint('🎬 [MenuButton] Triggering menu state change (synchronized with fade)');
      final menuStartTime = DateTime.now();
      menuController.onMenuButtonTap();
      final menuTime = DateTime.now().difference(menuStartTime).inMilliseconds;
      debugPrint('🎬 [MenuButton] Menu state change took: ${menuTime}ms');
    });
  }

  void _onMenuClose() {
    final now = DateTime.now();
    debugPrint('🎯 [MenuClose] CLOSE TAP DETECTED at ${now.toString().substring(11, 23)}');
    debugPrint('🎯 [MenuClose] _isAnimating: $_isAnimating, _isMenuAnimating: $_isMenuAnimating');
    
    if (_isAnimating || _isMenuAnimating) {
      debugPrint('🚫 [MenuClose] TAP IGNORED - Animation in progress');
      return; // Ignore taps during animation
    }
    
    if (_lastTapTime != null) {
      final timeDiff = now.difference(_lastTapTime!).inMilliseconds;
      debugPrint('🎯 [MenuClose] Time since last tap: ${timeDiff}ms');
      if (timeDiff < 500) {
        debugPrint('🚫 [MenuClose] TAP IGNORED - Debounce active (${timeDiff}ms < 500ms)');
        return; // Debounce: ignore taps within 500ms
      }
    }
    
    debugPrint('✅ [MenuClose] TAP ACCEPTED - Starting menu close animation');
    _lastTapTime = now;
    
    final startTime = DateTime.now();
    if (mounted) {
      setState(() {
        _isAnimating = true;
      });
    }
    final setStateTime = DateTime.now().difference(startTime).inMilliseconds;
    debugPrint('⏱️ [MenuClose] setState took: ${setStateTime}ms');
    
    final menuController = Provider.of<AppMenuController>(context, listen: false);
    
    debugPrint('🎬 [MenuClose] Triggering menu state change to CLOSE');
    final menuStartTime = DateTime.now();
    menuController.onMenuButtonTap();
    final menuTime = DateTime.now().difference(menuStartTime).inMilliseconds;
    debugPrint('🎬 [MenuClose] Menu state change took: ${menuTime}ms');
  }


  @override
  Widget performanceBuild(BuildContext context) {
    return Selector<AppMenuController, MenuState>(
      selector: (_, controller) => controller.menuState,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, menuState, child) {
        // Handle state changes with mounted check
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // GUARD: Check mounted before processing state changes
          if (!mounted) return;
          
          final menuController = Provider.of<AppMenuController>(context, listen: false);
          _handleMenuStateChange(menuController);
        });
        
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ⚡ OPTIMIZED: Background animation with RepaintBoundary for liquid glass capture
          RepaintBoundary(
            key: backgroundKey,
            child: const bg.EnhancedBackgroundAnimationWidget(),
          ),
          
              // Liquid Glass Menu button - changes to close button when menu is open
              Positioned(
                top: 20,
                left: 20,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: menuState == MenuState.open
                      ? GestureDetector(
                          key: const ValueKey('close'),
                          onTap: () {
                            final now = DateTime.now();
                            debugPrint('🎯 [CloseButton] CLOSE BUTTON TAPPED at ${now.toString().substring(11, 23)}');
                            debugPrint('🎯 [CloseButton] Current states - _isAnimating: $_isAnimating, _isMenuAnimating: $_isMenuAnimating');
                            
                            if (_isAnimating) {
                              debugPrint('🚫 [CloseButton] TAP IGNORED - _isAnimating is true');
                              return;
                            }
                            
                            debugPrint('✅ [CloseButton] TAP ACCEPTED - Calling _onMenuClose');
                            _onMenuClose();
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _isAnimating
                                  ? Colors.white.withValues(alpha:0.05)
                                  : Colors.white.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _isAnimating
                                    ? Colors.white.withValues(alpha:0.1)
                                    : Colors.white.withValues(alpha:0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: _isAnimating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          key: const ValueKey('menu'),
                          onTap: () {
                            final now = DateTime.now();
                            debugPrint('🎯 [MenuButton] MENU BUTTON TAPPED at ${now.toString().substring(11, 23)}');
                            debugPrint('🎯 [MenuButton] Current states - _isAnimating: $_isAnimating, _isMenuAnimating: $_isMenuAnimating');
                            
                            if (_isAnimating) {
                              debugPrint('🚫 [MenuButton] TAP IGNORED - _isAnimating is true');
                              return;
                            }
                            
                            debugPrint('✅ [MenuButton] TAP ACCEPTED - Calling _onMenuTap');
                            _onMenuTap();
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _isAnimating
                                  ? Colors.white.withValues(alpha:0.05)
                                  : Colors.white.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _isAnimating
                                    ? Colors.white.withValues(alpha:0.1)
                                    : Colors.white.withValues(alpha:0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: _isAnimating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.menu,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                ),
              ),
              
              // ⚡ OPTIMIZED: Card with RepaintBoundary for better performance
              if (menuState != MenuState.open)
                RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _fadeController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Center(
                            // Simple liquid glass with fade - no overlays or confusing effects
                            child: LiquidGlassBoxWidget(
                              key: _mainCardKey,
                              backgroundKey: backgroundKey,
                              width: 800,
                              height: 600,
                              initialPosition: Offset.zero,
                              borderRadius: 20.0,
                              leftMargin: _leftMargin,
                              rightMargin: _rightMargin,
                              topMargin: _topMargin,
                              bottomMargin: _bottomMargin,
                              debugBorderRadius: _borderRadius,
                              child: Padding(
                                padding: const EdgeInsets.all(60.0),
                                child: _buildCardContent(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          
          // Menu is handled by BackgroundAnimationWidget internally
          
          // Debug Panels - DISABLED (perfect values applied)
          // LiquidGlassDebugPanel(
          //   onValuesChanged: _onDebugValuesChanged,
          //   initialLeftMargin: _leftMargin,
          //   initialRightMargin: _rightMargin,
          //   initialTopMargin: _topMargin,
          //   initialBottomMargin: _bottomMargin,
          //   initialBorderRadius: _borderRadius,
          // ),
          
          // ContentPositionDebugPanel(
          //   onPositionChanged: _onContentPositionChanged,
          //   initialOffsetX: _contentOffsetX,
          //   initialOffsetY: _contentOffsetY,
          // ),
        ],
      ),
    );
      },
    );
  }
}