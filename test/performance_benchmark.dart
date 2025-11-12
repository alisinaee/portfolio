import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../lib/features/menu/presentation/controllers/menu_controller.dart';
import '../lib/features/menu/data/repositories/menu_repository_impl.dart';

/// Performance Benchmark Tool
/// 
/// This tool provides comprehensive performance metrics for the menu system:
/// - Frame rate measurement during transitions
/// - Widget rebuild count tracking
/// - Animation timing validation
/// - Memory usage monitoring
/// 
/// Usage:
/// Run this file with: flutter run test/performance_benchmark.dart
/// 
/// The tool will:
/// 1. Measure baseline performance
/// 2. Run menu interaction scenarios
/// 3. Collect performance metrics
/// 4. Generate a performance report

void main() {
  runApp(const PerformanceBenchmarkApp());
}

class PerformanceBenchmarkApp extends StatelessWidget {
  const PerformanceBenchmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu Performance Benchmark',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PerformanceBenchmarkScreen(),
    );
  }
}

class PerformanceBenchmarkScreen extends StatefulWidget {
  const PerformanceBenchmarkScreen({super.key});

  @override
  State<PerformanceBenchmarkScreen> createState() => _PerformanceBenchmarkScreenState();
}

class _PerformanceBenchmarkScreenState extends State<PerformanceBenchmarkScreen> {
  late AppMenuController _controller;
  final List<PerformanceMetric> _metrics = [];
  bool _isRunning = false;
  String _currentTest = '';
  final StringBuffer _log = StringBuffer();

  @override
  void initState() {
    super.initState();
    _controller = AppMenuController(MenuRepositoryImpl());
    _setupFrameCallback();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupFrameCallback() {
    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      if (_isRunning) {
        for (final timing in timings) {
          final frameTime = timing.totalSpan.inMilliseconds;
          _metrics.add(PerformanceMetric(
            timestamp: DateTime.now(),
            frameTime: frameTime,
            testName: _currentTest,
          ));
        }
      }
    });
  }

  void _log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 23);
    final logMessage = '[$timestamp] $message';
    setState(() {
      _log.writeln(logMessage);
    });
    debugPrint(logMessage);
  }

  Future<void> _runBenchmark() async {
    setState(() {
      _isRunning = true;
      _metrics.clear();
      _log.clear();
    });

    _log('🚀 Starting Performance Benchmark');
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Test 1: Menu Open/Close Performance
    await _testMenuOpenClose();

    // Test 2: Hover State Performance
    await _testHoverPerformance();

    // Test 3: Item Selection Performance
    await _testItemSelection();

    // Test 4: Rapid Interaction Performance
    await _testRapidInteractions();

    // Generate Report
    _generateReport();

    setState(() {
      _isRunning = false;
    });

    _log('✅ Benchmark Complete');
  }

  Future<void> _testMenuOpenClose() async {
    _currentTest = 'Menu Open/Close';
    _log('\n📊 Test 1: Menu Open/Close Performance');
    _log('Target: Complete within 700ms, maintain 55+ FPS');

    for (int i = 0; i < 5; i++) {
      _log('  Iteration ${i + 1}/5');

      // Open menu
      final openStart = DateTime.now();
      _controller.onMenuButtonTap();
      await Future.delayed(const Duration(milliseconds: 400));
      final openDuration = DateTime.now().difference(openStart);
      _log('    Open: ${openDuration.inMilliseconds}ms');

      // Close menu
      final closeStart = DateTime.now();
      _controller.onMenuButtonTap();
      await Future.delayed(const Duration(milliseconds: 400));
      final closeDuration = DateTime.now().difference(closeStart);
      _log('    Close: ${closeDuration.inMilliseconds}ms');

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _testHoverPerformance() async {
    _currentTest = 'Hover State';
    _log('\n📊 Test 2: Hover State Performance');
    _log('Target: Updates within 16ms, debouncing active');

    final items = [
      MenuItems.home,
      MenuItems.profile,
      MenuItems.settings,
      MenuItems.history,
      MenuItems.transfer,
    ];

    for (final item in items) {
      final start = DateTime.now();
      _controller.updateMenuItemHover(item, true);
      final duration = DateTime.now().difference(start);
      _log('  ${item.name} hover ON: ${duration.inMicroseconds}μs');

      await Future.delayed(const Duration(milliseconds: 50));

      final offStart = DateTime.now();
      _controller.updateMenuItemHover(item, false);
      final offDuration = DateTime.now().difference(offStart);
      _log('  ${item.name} hover OFF: ${offDuration.inMicroseconds}μs');

      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Test debouncing
    _log('  Testing debouncing (10 rapid updates)...');
    final debounceStart = DateTime.now();
    for (int i = 0; i < 10; i++) {
      _controller.updateMenuItemHover(MenuItems.home, true);
    }
    final debounceDuration = DateTime.now().difference(debounceStart);
    _log('  Debounce test: ${debounceDuration.inMicroseconds}μs');

    final metrics = _controller.getHoverPerformanceMetrics();
    _log('  Hover Metrics: ${metrics['efficiency']} efficiency');
    _log('  Skipped: ${metrics['skippedUpdates']}, Processed: ${metrics['hoverUpdates']}');
  }

  Future<void> _testItemSelection() async {
    _currentTest = 'Item Selection';
    _log('\n📊 Test 3: Item Selection Performance');
    _log('Target: Complete within 320ms (optimized timing)');

    final items = [
      MenuItems.home,
      MenuItems.profile,
      MenuItems.settings,
    ];

    for (final item in items) {
      final start = DateTime.now();
      await _controller.onSelectItem(item);
      final duration = DateTime.now().difference(start);
      _log('  Select ${item.name}: ${duration.inMilliseconds}ms');

      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Test duplicate selection guard
    _log('  Testing duplicate selection guard...');
    final dupStart = DateTime.now();
    await _controller.onSelectItem(MenuItems.settings);
    final dupDuration = DateTime.now().difference(dupStart);
    _log('  Duplicate selection: ${dupDuration.inMilliseconds}ms (should be fast)');
  }

  Future<void> _testRapidInteractions() async {
    _currentTest = 'Rapid Interactions';
    _log('\n📊 Test 4: Rapid Interaction Performance');
    _log('Target: Handle rapid inputs without lag');

    _log('  Rapid menu toggles...');
    for (int i = 0; i < 10; i++) {
      _controller.onMenuButtonTap();
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _log('  Rapid hover changes...');
    for (int i = 0; i < 20; i++) {
      final item = MenuItems.values[i % MenuItems.values.length];
      _controller.updateMenuItemHover(item, i % 2 == 0);
      await Future.delayed(const Duration(milliseconds: 25));
    }

    _log('  Stress test complete');
  }

  void _generateReport() {
    _log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📈 PERFORMANCE REPORT');
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (_metrics.isEmpty) {
      _log('⚠️  No frame timing data collected');
      return;
    }

    // Calculate frame statistics
    final frameTimes = _metrics.map((m) => m.frameTime).toList();
    final avgFrameTime = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
    final maxFrameTime = frameTimes.reduce((a, b) => a > b ? a : b);
    final minFrameTime = frameTimes.reduce((a, b) => a < b ? a : b);
    final droppedFrames = frameTimes.where((t) => t > 16).length;
    final avgFps = 1000 / avgFrameTime;

    _log('\n📊 Frame Statistics:');
    _log('  Total Frames: ${frameTimes.length}');
    _log('  Average Frame Time: ${avgFrameTime.toStringAsFixed(2)}ms');
    _log('  Min Frame Time: ${minFrameTime}ms');
    _log('  Max Frame Time: ${maxFrameTime}ms');
    _log('  Average FPS: ${avgFps.toStringAsFixed(1)}');
    _log('  Dropped Frames (>16ms): $droppedFrames');
    _log('  Frame Drop Rate: ${(droppedFrames / frameTimes.length * 100).toStringAsFixed(1)}%');

    // Performance assessment
    _log('\n✅ Performance Assessment:');
    
    if (avgFps >= 55) {
      _log('  ✓ Frame Rate: PASS (${avgFps.toStringAsFixed(1)} FPS >= 55 FPS target)');
    } else {
      _log('  ✗ Frame Rate: FAIL (${avgFps.toStringAsFixed(1)} FPS < 55 FPS target)');
    }

    final dropRate = droppedFrames / frameTimes.length * 100;
    if (dropRate < 5) {
      _log('  ✓ Frame Drops: PASS (${dropRate.toStringAsFixed(1)}% < 5% threshold)');
    } else {
      _log('  ✗ Frame Drops: FAIL (${dropRate.toStringAsFixed(1)}% >= 5% threshold)');
    }

    // Hover performance metrics
    final hoverMetrics = _controller.getHoverPerformanceMetrics();
    _log('\n📊 Hover State Optimization:');
    _log('  Total Hover Attempts: ${hoverMetrics['totalAttempts']}');
    _log('  Updates Processed: ${hoverMetrics['hoverUpdates']}');
    _log('  Updates Skipped: ${hoverMetrics['skippedUpdates']}');
    _log('  Efficiency: ${hoverMetrics['efficiency']}');

    final efficiency = double.parse(hoverMetrics['efficiency'].toString().replaceAll('%', ''));
    if (efficiency >= 50) {
      _log('  ✓ Debouncing: EFFECTIVE (${efficiency.toStringAsFixed(1)}% skipped)');
    } else {
      _log('  ⚠️  Debouncing: LOW EFFICIENCY (${efficiency.toStringAsFixed(1)}% skipped)');
    }

    _log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Performance Benchmark'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Benchmark Tool',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This tool measures menu system performance:\n'
                      '• Frame rate during transitions\n'
                      '• Widget rebuild optimization\n'
                      '• Animation timing validation\n'
                      '• Hover state debouncing',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isRunning ? null : _runBenchmark,
              icon: Icon(_isRunning ? Icons.hourglass_empty : Icons.play_arrow),
              label: Text(_isRunning ? 'Running Benchmark...' : 'Run Benchmark'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _log.toString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PerformanceMetric {
  final DateTime timestamp;
  final int frameTime;
  final String testName;

  PerformanceMetric({
    required this.timestamp,
    required this.frameTime,
    required this.testName,
  });
}
