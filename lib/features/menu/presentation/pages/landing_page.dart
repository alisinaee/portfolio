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

  void _onMenuStateChanged() {
    final menuController = Provider.of<AppMenuController>(context, listen: false);
    
    debugPrint('🔄 [MenuState] State changed to: ${menuController.menuState}');
    debugPrint('🔄 [MenuState] Animation flag: $_isAnimating');
    
    // If menu was closed (either by button or item selection), fade in the card
    if (menuController.menuState == MenuState.close) {
      debugPrint('🎬 [MenuState] Menu closed, starting card fade-in animation');
      // Use a shorter delay to allow menu close animation to complete
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          debugPrint('🎬 [MenuState] Starting card fade-in, current value: ${_fadeController.value}');
          // Always reverse the animation to show the card
          _fadeController.reverse().then((_) {
            debugPrint('✅ [MenuState] Card fade-in complete - resetting animation flag');
            setState(() {
              _isAnimating = false; // Reset animation flag when fade-in completes
              _isMenuAnimating = false; // Reset menu animation flag
            });
          });
        }
      });
    } else if (menuController.menuState == MenuState.open) {
      debugPrint('🎬 [MenuState] Menu opened - setting menu animation flag');
      setState(() {
        _isMenuAnimating = true;
      });
      // Reset animation flag after menu open animation completes
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          debugPrint('✅ [MenuState] Menu open animation complete - resetting animation flag');
          setState(() {
            _isAnimating = false;
            _isMenuAnimating = false;
          });
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
    debugPrint('🎯 [MenuButton] Tap detected - checking debounce...');
    
    if (_isAnimating || _isMenuAnimating) {
      debugPrint('🚫 [MenuButton] Tap ignored - animation in progress (card: $_isAnimating, menu: $_isMenuAnimating)');
      return;
    }
    
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds < 800) {
      debugPrint('🚫 [MenuButton] Tap ignored - debounce active (${now.difference(_lastTapTime!).inMilliseconds}ms ago)');
      return; // Debounce: ignore taps within 800ms
    }
    
    debugPrint('✅ [MenuButton] Tap accepted - starting menu open animation');
    _lastTapTime = now;
    setState(() {
      _isAnimating = true;
    });
    
    final menuController = Provider.of<AppMenuController>(context, listen: false);
    
    // First fade out the main card
    _fadeController.forward().then((_) {
      debugPrint('🎬 [MenuButton] Card fade-out complete - opening menu');
      // Then show the menu
      menuController.onMenuButtonTap();
      // Don't reset _isAnimating here - let _onMenuStateChanged handle it
    });
  }

  void _onMenuClose() {
    debugPrint('🎯 [MenuButton] Close tap detected - checking debounce...');
    
    if (_isAnimating || _isMenuAnimating) {
      debugPrint('🚫 [MenuButton] Close tap ignored - animation in progress (card: $_isAnimating, menu: $_isMenuAnimating)');
      return;
    }
    
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds < 800) {
      debugPrint('🚫 [MenuButton] Close tap ignored - debounce active (${now.difference(_lastTapTime!).inMilliseconds}ms ago)');
      return; // Debounce: ignore taps within 800ms
    }
    
    debugPrint('✅ [MenuButton] Close tap accepted - closing menu');
    _lastTapTime = now;
    setState(() {
      _isAnimating = true;
    });
    
    final menuController = Provider.of<AppMenuController>(context, listen: false);
    
    // Close the menu first
    menuController.onMenuButtonTap();
    
    // The fade animation will be handled by _onMenuStateChanged
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
                child: menuController.menuState == MenuState.open
                    ? GestureDetector(
                        onTap: (_isAnimating || _isMenuAnimating) ? null : _onMenuClose,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (_isAnimating || _isMenuAnimating)
                                ? Colors.white.withValues(alpha:0.05)
                                : Colors.white.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: (_isAnimating || _isMenuAnimating)
                                  ? Colors.white.withValues(alpha:0.1)
                                  : Colors.white.withValues(alpha:0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: (_isAnimating || _isMenuAnimating)
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
                        onTap: (_isAnimating || _isMenuAnimating) ? null : _onMenuTap,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (_isAnimating || _isMenuAnimating)
                                ? Colors.white.withValues(alpha:0.05)
                                : Colors.white.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: (_isAnimating || _isMenuAnimating)
                                  ? Colors.white.withValues(alpha:0.1)
                                  : Colors.white.withValues(alpha:0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: (_isAnimating || _isMenuAnimating)
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
              
              // One big centered card with fade animation
              // Show card when menu is closed, with fade animation
              if (menuController.menuState != MenuState.open)
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Center(
                        // WEB DEPLOYMENT FIX: Add containment wrapper
                        child: Container(
                          width: 800,
                          height: 600,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(_borderRadius),
                          ),
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