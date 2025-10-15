import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/menu/data/data_sources/menu_data_source.dart';
import 'features/menu/data/repositories/menu_repository_impl.dart';
import 'features/menu/presentation/controllers/menu_controller.dart';
import 'features/menu/presentation/pages/menu_page.dart';
import 'shared/widgets/performance_overlay_widget.dart';

void main() {
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
        home: const PerformanceMonitor(
          showOverlay: true, // Change to false to disable
          child: MenuPage(),
        ),
      ),
    );
  }
}
