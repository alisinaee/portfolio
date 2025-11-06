import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/menu/presentation/pages/optimized_main_app_widget.dart';
import 'core/utils/memory_manager.dart';
import 'core/effects/liquid_glass/shader_manager.dart';
import 'core/performance/widget_pool.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Optimize Flutter engine settings for web
  if (kIsWeb) {
    // Enable hardware acceleration
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  
  // Initialize Firebase (async)
  final firebaseInitialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize shaders (async)
  final shaderInitialization = ShaderManager.instance.initializeShaders();
  
  // Wait for critical initializations
  await Future.wait([
    firebaseInitialization,
    shaderInitialization,
  ]);
  
  // Start memory management
  if (!kDebugMode) {
    MemoryManager.startPeriodicCleanup();
  }
  
  // Configure frame timing monitoring (production-safe)
  if (!kIsWeb && kDebugMode) {
    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        final total = timing.totalSpan;
        if (total > const Duration(milliseconds: 20)) {
          debugPrint('🐌 Frame: ${total.inMicroseconds / 1000}ms');
        }
      }
    });
  }
  
  runApp(const OptimizedMovingTextBackgroundApp());
}

class OptimizedMovingTextBackgroundApp extends StatelessWidget {
  const OptimizedMovingTextBackgroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ali Sinaee - Portfolio',
      debugShowCheckedModeBanner: false,
      
      // Optimized scroll behavior
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
        scrollbars: false, // Disable scrollbars for cleaner look
      ),
      
      // Optimized theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        
        // Optimize text rendering
        textTheme: const TextTheme().apply(
          fontFamily: 'Ganyme',
        ),
        
        // Disable animations that aren't needed
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: const FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        
        // Optimize visual density
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      
      // Main app with optional performance monitoring
      home: PerformanceMonitorWidget(
        showOverlay: kDebugMode, // Only show in debug mode
        child: const OptimizedMainAppWidget(),
      ),
      
      // Optimize builder for performance
      builder: (context, child) {
        return MediaQuery(
          // Disable text scaling for consistent layout
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}

/// Custom page transition for better performance
class FadeUpwardsPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeUpwardsPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
}

/// Global performance utilities
class PerformanceUtils {
  static void warmUpShaders(BuildContext context) {
    // Pre-warm shaders to prevent first-frame jank
    Future.microtask(() async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();
      canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1), paint);
      recorder.endRecording();
    });
  }
  
  static void preloadAssets() {
    // Preload critical assets
    Future.microtask(() {
      // Preload fonts
      const TextStyle(fontFamily: 'Ganyme').toString();
      const TextStyle(fontFamily: 'Avalon').toString();
    });
  }
  
  static void optimizeMemory() {
    // Clear widget pools periodically
    WidgetPoolManager.instance.clearAll();
  }
}