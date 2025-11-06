import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Ultra-high performance animation engine using Canvas and CustomPainter
/// Bypasses Flutter's widget tree for maximum performance
class CanvasAnimationEngine extends CustomPainter {
  final List<AnimatedElement> elements;
  final double animationValue;
  final bool isMenuOpen;
  
  CanvasAnimationEngine({
    required this.elements,
    required this.animationValue,
    required this.isMenuOpen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use GPU-accelerated operations
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.low; // Faster rendering

    for (final element in elements) {
      element.paint(canvas, size, animationValue, isMenuOpen, paint);
    }
  }

  @override
  bool shouldRepaint(CanvasAnimationEngine oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
           isMenuOpen != oldDelegate.isMenuOpen;
  }
}

/// Base class for animated elements
abstract class AnimatedElement {
  void paint(Canvas canvas, Size size, double animationValue, bool isMenuOpen, Paint paint);
}

/// High-performance text animation element
class AnimatedTextElement extends AnimatedElement {
  final String text;
  final TextStyle style;
  final double startX;
  final double y;
  final double amplitude;
  final bool reverse;
  final int delay;

  AnimatedTextElement({
    required this.text,
    required this.style,
    required this.startX,
    required this.y,
    required this.amplitude,
    this.reverse = false,
    this.delay = 0,
  });

  @override
  void paint(Canvas canvas, Size size, double animationValue, bool isMenuOpen, Paint paint) {
    // Calculate position with smooth animation
    final adjustedValue = (animationValue + (delay * 0.1)) % 1.0;
    final t = reverse ? 1.0 - adjustedValue : adjustedValue;
    final offset = math.sin(t * math.pi * 2) * amplitude;
    
    // Create text painter (cached for performance)
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Paint text at calculated position
    textPainter.paint(canvas, Offset(startX + offset, y));
  }
}

/// Ultra-fast animation controller using Ticker directly
class HighPerformanceAnimationController extends ChangeNotifier {
  late Ticker _ticker;
  double _value = 0.0;
  bool _isRunning = false;
  final Duration duration;
  late DateTime _startTime;

  HighPerformanceAnimationController({
    required this.duration,
    required TickerProvider vsync,
  }) {
    _ticker = vsync.createTicker(_onTick);
  }

  double get value => _value;
  bool get isRunning => _isRunning;

  void start() {
    if (!_isRunning) {
      _isRunning = true;
      _startTime = DateTime.now();
      _ticker.start();
    }
  }

  void stop() {
    if (_isRunning) {
      _isRunning = false;
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    if (!_isRunning) return;

    final now = DateTime.now();
    final elapsedMs = now.difference(_startTime).inMilliseconds;
    final progress = (elapsedMs / duration.inMilliseconds) % 2.0;
    
    // Create smooth back-and-forth animation
    _value = progress <= 1.0 ? progress : 2.0 - progress;
    
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

/// Widget that uses the high-performance animation engine
class CanvasAnimationWidget extends StatefulWidget {
  final List<AnimatedElement> elements;
  final bool isMenuOpen;
  final Duration duration;

  const CanvasAnimationWidget({
    super.key,
    required this.elements,
    required this.isMenuOpen,
    this.duration = const Duration(seconds: 30),
  });

  @override
  State<CanvasAnimationWidget> createState() => _CanvasAnimationWidgetState();
}

class _CanvasAnimationWidgetState extends State<CanvasAnimationWidget>
    with SingleTickerProviderStateMixin {
  late HighPerformanceAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HighPerformanceAnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: CanvasAnimationEngine(
            elements: widget.elements,
            animationValue: _controller.value,
            isMenuOpen: widget.isMenuOpen,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}