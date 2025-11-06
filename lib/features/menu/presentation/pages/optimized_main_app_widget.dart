import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/optimized_menu_controller.dart';
import '../widgets/loading_screen_widget.dart';
import 'optimized_landing_page.dart';
import '../../data/data_sources/menu_data_source.dart';

/// Ultra-optimized main app widget
/// Uses optimized controllers and minimal widget tree
class OptimizedMainAppWidget extends StatefulWidget {
  const OptimizedMainAppWidget({super.key});

  @override
  State<OptimizedMainAppWidget> createState() => _OptimizedMainAppWidgetState();
}

class _OptimizedMainAppWidgetState extends State<OptimizedMainAppWidget> {
  bool _isLoading = true;
  late OptimizedMenuController _menuController;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize menu controller with data
    final menuDataSource = MenuDataSource();
    final menuItems = menuDataSource.getMenuItems();
    _menuController = OptimizedMenuController(menuItems);
    
    // Simulate minimal loading time
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreenWidget();
    }
    
    return ChangeNotifierProvider<OptimizedMenuController>.value(
      value: _menuController,
      child: const OptimizedLandingPage(),
    );
  }
}

/// Performance monitoring widget (optional)
class PerformanceMonitorWidget extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const PerformanceMonitorWidget({
    super.key,
    required this.child,
    this.showOverlay = false,
  });

  @override
  State<PerformanceMonitorWidget> createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  @override
  Widget build(BuildContext context) {
    if (!widget.showOverlay) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 80,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Performance Monitor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Optimized Version Running',
                  style: TextStyle(color: Colors.green, fontSize: 10),
                ),
                Text(
                  'Canvas Animations: Active',
                  style: TextStyle(color: Colors.blue, fontSize: 10),
                ),
                Text(
                  'Immutable State: Active',
                  style: TextStyle(color: Colors.blue, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}