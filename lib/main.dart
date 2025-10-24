import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/utils/performance_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/menu/data/data_sources/menu_data_source.dart';
import 'features/menu/data/repositories/menu_repository_impl.dart';
import 'features/menu/presentation/controllers/menu_controller.dart';
import 'features/prelaunch/presentation/pages/prelaunch_page.dart';
import 'core/utils/memory_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register frame timings logger for slow-frame diagnostics (guarded on web)
  if (!kIsWeb) {
    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        final total = timing.totalSpan;
        if (total > const Duration(milliseconds: 17)) {
          debugPrint('🕒 Slow frame: ${total.inMicroseconds / 1000}ms | build: ${timing.buildDuration.inMicroseconds / 1000}ms | raster: ${timing.rasterDuration.inMicroseconds / 1000}ms');
        }
      }
    });
  }
  // Start web-friendly jank monitor
  if (kDebugPerformance) {
    PerformanceLogger.startJankMonitor();
  }
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    
  );
  
  // Start periodic memory cleanup to prevent leaks
  MemoryManager.startPeriodicCleanup();
  
  runApp(const MovingTextBackgroundApp());
}

class MovingTextBackgroundApp extends StatelessWidget {
  const MovingTextBackgroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppMenuController(
        MenuRepositoryImpl(MenuDataSource()),
      ),
      child: MaterialApp(
        title: 'Moving Text Background',
        debugShowCheckedModeBanner: false,
        scrollBehavior: MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown
          },
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // Wrap with PerformanceMonitor for monitoring
        // Set showOverlay to true to enable performance monitoring
        // NOTE: Disable in production for better performance!
        home: PrelaunchPage(),
      ),
    );
  }
}
