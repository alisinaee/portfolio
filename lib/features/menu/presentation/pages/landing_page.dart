import 'package:flutter/material.dart';
import '../widgets/background_animation_widget.dart' as bg;
import '../widgets/liquid_glass_box_widget.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../../domain/entities/menu_entity.dart';


class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  final GlobalKey backgroundKey = GlobalKey();
  final GlobalKey<LiquidGlassBoxWidgetState> _mainCardKey = GlobalKey();
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Debounce variables
  bool _isAnimating = false;
  DateTime? _lastTapTime;
  bool _isMenuAnimating = false;
  
  // Perfect values from debug panel
  double _leftMargin = 100.5;
  double _rightMargin = 101.0;
  double _topMargin = 2.5;
  double _bottomMargin = 2.5;
  double _borderRadius = 166.5;
  
  // Content positioning offsets - perfect centering
  double _contentOffsetX = 0.0;
  double _contentOffsetY = 0.0;
  


  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to menu state changes to handle menu item selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuController = Provider.of<AppMenuController>(context, listen: false);
      menuController.addListener(_onMenuStateChanged);
      
      // Ensure the card starts visible when menu is closed
      if (menuController.menuState == MenuState.close) {
        _fadeController.reset();
      }
    });
  }

  MenuState? _lastProcessedState;
  
  void _onMenuStateChanged() {
    final menuController = Provider.of<AppMenuController>(context, listen: false);
    
    // Prevent processing the same state change multiple times
    if (_lastProcessedState == menuController.menuState) {
      debugPrint('🚫 [MenuState] DUPLICATE state change ignored: ${menuController.menuState}');
      return;
    }
    
    _lastProcessedState = menuController.menuState;
    debugPrint('🔄 [MenuState] STATE CHANGED to: ${menuController.menuState}');
    
    if (menuController.menuState == MenuState.close) {
      debugPrint('🎬 [MenuState] MENU CLOSING - Starting transition to background');
      
      setState(() {
        _isMenuAnimating = false;
      });
      
      // Wait for menu close animation to complete, then fade in card
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _lastProcessedState == MenuState.close) {
          debugPrint('🎬 [MenuState] Starting card fade-in');
          _fadeController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _isAnimating = false;
              });
              debugPrint('✅ [MenuState] TRANSITION TO BACKGROUND COMPLETE');
            }
          });
        }
      });
    } else if (menuController.menuState == MenuState.open) {
      debugPrint('🎬 [MenuState] MENU OPENING - Coordinating with background animation');
      
      setState(() {
        _isMenuAnimating = true;
      });
      
      // Reset animation flags after menu fully opens
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _lastProcessedState == MenuState.open) {
          setState(() {
            _isAnimating = false;
          });
          debugPrint('✅ [MenuState] MENU OPEN COMPLETE');
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    // Remove listener to prevent memory leaks
    try {
      final menuController = Provider.of<AppMenuController>(context, listen: false);
      menuController.removeListener(_onMenuStateChanged);
    } catch (e) {
      // Context might be disposed, ignore error
    }
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
    setState(() {
      _isAnimating = true;
    });
    final setStateTime = DateTime.now().difference(startTime).inMilliseconds;
    debugPrint('⏱️ [MenuButton] setState took: ${setStateTime}ms');
    
    final menuController = Provider.of<AppMenuController>(context, listen: false);
    
    // First fade out the main card
    debugPrint('🎬 [MenuButton] Starting card fade-out animation');
    final fadeStartTime = DateTime.now();
    _fadeController.forward().then((_) {
      final fadeTime = DateTime.now().difference(fadeStartTime).inMilliseconds;
      debugPrint('🎬 [MenuButton] Card fade-out completed in ${fadeTime}ms');
      
      if (mounted) {
        debugPrint('🎬 [MenuButton] Triggering menu state change');
        final menuStartTime = DateTime.now();
        menuController.onMenuButtonTap();
        final menuTime = DateTime.now().difference(menuStartTime).inMilliseconds;
        debugPrint('🎬 [MenuButton] Menu state change took: ${menuTime}ms');
      }
    });
  }

  void _onMenuClose() {
    if (_isAnimating || _isMenuAnimating) {
      return; // Ignore taps during animation
    }
    
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds < 500) {
      return; // Debounce: ignore taps within 500ms
    }
    
    _lastTapTime = now;
    setState(() {
      _isAnimating = true;
    });
    
    final menuController = Provider.of<AppMenuController>(context, listen: false);
    
    // Close the menu first - this will trigger smooth transition back
    menuController.onMenuButtonTap();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<AppMenuController>(
      builder: (context, menuController, child) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background animation with RepaintBoundary for liquid glass capture
              // Always show background animation, it handles menu state internally
          RepaintBoundary(
            key: backgroundKey,
                child: const bg.BackgroundAnimationWidget(),
          ),
          
              // Liquid Glass Menu button - changes to close button when menu is open
              Positioned(
                top: 20,
                left: 20,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: menuController.menuState == MenuState.open
                      ? GestureDetector(
                          key: const ValueKey('close'),
                          onTap: _isAnimating ? null : _onMenuClose,
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
                          onTap: _isAnimating ? null : _onMenuTap,
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
              
              // One big centered card with fade animation
              // Show card when menu is closed, with fade animation
              if (menuController.menuState != MenuState.open)
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Center(
                        // Clean liquid glass rendering (distortion fixed in shader)
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
                            child: SizedBox(
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
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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