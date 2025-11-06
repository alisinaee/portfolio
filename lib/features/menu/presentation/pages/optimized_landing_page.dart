import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/optimized_menu_widget.dart';
import '../widgets/liquid_glass_box_widget.dart';
import '../controllers/optimized_menu_controller.dart';
import '../../../../core/performance/immutable_state.dart';

/// Ultra-optimized landing page with maximum performance
/// Uses immutable state, widget caching, and GPU acceleration
class OptimizedLandingPage extends StatefulWidget {
  const OptimizedLandingPage({super.key});

  @override
  State<OptimizedLandingPage> createState() => _OptimizedLandingPageState();
}

class _OptimizedLandingPageState extends State<OptimizedLandingPage> 
    with TickerProviderStateMixin, OptimizedMenuMixin {
  
  final GlobalKey _backgroundKey = GlobalKey();
  final GlobalKey<LiquidGlassBoxWidgetState> _mainCardKey = GlobalKey();
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // State management
  bool _isAnimating = false;
  DateTime? _lastTapTime;
  MenuStateEnum? _lastProcessedState;
  
  // Widget caching for performance
  Widget? _cachedCard;
  
  // Constants (final for better performance)
  static const double _leftMargin = 100.5;
  static const double _rightMargin = 101.0;
  static const double _topMargin = 2.5;
  static const double _bottomMargin = 2.5;
  static const double _borderRadius = 166.5;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 250), // Faster fade
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to menu state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<OptimizedMenuController>();
      controller.addListener(_onMenuStateChanged);
      
      if (controller.menuState == MenuStateEnum.close) {
        _fadeController.reset();
      }
    });
  }

  void _onMenuStateChanged() {
    final controller = context.read<OptimizedMenuController>();
    
    // Prevent duplicate processing
    if (_lastProcessedState == controller.menuState) return;
    _lastProcessedState = controller.menuState;
    
    if (controller.menuState == MenuStateEnum.close) {
      // Menu closing - fade in card
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && _lastProcessedState == MenuStateEnum.close) {
          _fadeController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _isAnimating = false;
              });
            }
          });
        }
      });
    } else {
      // Menu opening
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _lastProcessedState == MenuStateEnum.open) {
          setState(() {
            _isAnimating = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    try {
      final controller = context.read<OptimizedMenuController>();
      controller.removeListener(_onMenuStateChanged);
    } catch (e) {
      // Context disposed, ignore
    }
    super.dispose();
  }

  void _onMenuTap() {
    if (_isAnimating) return;
    
    final now = DateTime.now();
    if (_lastTapTime != null && 
        now.difference(_lastTapTime!).inMilliseconds < 400) {
      return; // Debounce
    }
    
    _lastTapTime = now;
    setState(() {
      _isAnimating = true;
    });
    
    final controller = context.read<OptimizedMenuController>();
    
    _fadeController.forward().then((_) {
      if (mounted) {
        controller.toggleMenu();
      }
    });
  }

  void _onMenuClose() {
    if (_isAnimating) return;
    
    final now = DateTime.now();
    if (_lastTapTime != null && 
        now.difference(_lastTapTime!).inMilliseconds < 400) {
      return;
    }
    
    _lastTapTime = now;
    setState(() {
      _isAnimating = true;
    });
    
    context.read<OptimizedMenuController>().toggleMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedMenuController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Background animation
              RepaintBoundary(
                key: _backgroundKey,
                child: const OptimizedBackgroundAnimationWidget(),
              ),
              
              // Menu button
              Positioned(
                top: 20,
                left: 20,
                child: _buildMenuButton(controller),
              ),
              
              // Main card (only when menu is closed)
              if (controller.menuState != MenuStateEnum.open)
                _buildMainCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(OptimizedMenuController controller) {
    final isMenuOpen = controller.menuState == MenuStateEnum.open;
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        key: ValueKey(isMenuOpen ? 'close' : 'menu'),
        onTap: _isAnimating ? null : (isMenuOpen ? _onMenuClose : _onMenuTap),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _isAnimating
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: _isAnimating
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.3),
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
                : Icon(
                    isMenuOpen ? Icons.close : Icons.menu,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    // Cache the card widget for performance
    _cachedCard ??= _createCardWidget();
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Center(
            child: _cachedCard!,
          ),
        );
      },
    );
  }

  Widget _createCardWidget() {
    return LiquidGlassBoxWidget(
      key: _mainCardKey,
      backgroundKey: _backgroundKey,
      width: 800,
      height: 600,
      initialPosition: Offset.zero,
      borderRadius: 20.0,
      leftMargin: _leftMargin,
      rightMargin: _rightMargin,
      topMargin: _topMargin,
      bottomMargin: _bottomMargin,
      debugBorderRadius: _borderRadius,
      child: const Padding(
        padding: EdgeInsets.all(60.0),
        child: _OptimizedCardContent(),
      ),
    );
  }
}

/// Optimized card content widget (const for performance)
class _OptimizedCardContent extends StatelessWidget {
  const _OptimizedCardContent();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hero Section
          Text(
            'Hello, I\'m',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.3),
              fontSize: 24,
              fontFamily: 'Ganyme',
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 20),
          Text(
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
          SizedBox(height: 20),
          _OptimizedDivider(),
          SizedBox(height: 40),
          
          // Description
          Text(
            'Senior Flutter Expert & Mobile App Developer',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.4),
              fontSize: 28,
              fontFamily: 'Ganyme',
              fontWeight: FontWeight.w300,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60),
          
          // CTA Button
          _OptimizedCTAButton(),
        ],
      ),
    );
  }
}

/// Optimized divider widget
class _OptimizedDivider extends StatelessWidget {
  const _OptimizedDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 3,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.4),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

/// Optimized CTA button widget
class _OptimizedCTAButton extends StatelessWidget {
  const _OptimizedCTAButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.1),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.2),
          width: 1,
        ),
      ),
      child: const Text(
        'GET IN TOUCH',
        style: TextStyle(
          color: Color.fromRGBO(255, 255, 255, 0.5),
          fontSize: 18,
          fontFamily: 'Ganyme',
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}