import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Real-time background stream channel for liquid glass effects
class BackgroundStreamChannel {
  static final BackgroundStreamChannel _instance = BackgroundStreamChannel._internal();
  factory BackgroundStreamChannel() => _instance;
  BackgroundStreamChannel._internal();

  final StreamController<ui.Image> _backgroundController = StreamController<ui.Image>.broadcast();
  Timer? _captureTimer;
  GlobalKey? _backgroundKey;
  bool _isCapturing = false;

  /// Stream of live background images
  Stream<ui.Image> get backgroundStream => _backgroundController.stream;

  /// Start capturing background from the specified key
  void startCapture(GlobalKey backgroundKey) {
    _backgroundKey = backgroundKey;
    _isCapturing = true;
    
    // Capture at 60 FPS for smooth real-time effect
    _captureTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _captureBackground();
    });
  }

  /// Stop background capture
  void stopCapture() {
    _isCapturing = false;
    _captureTimer?.cancel();
    _captureTimer = null;
  }

  /// Capture the current background
  Future<void> _captureBackground() async {
    if (!_isCapturing || _backgroundKey?.currentContext == null) return;

    try {
      final boundary = _backgroundKey!.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !boundary.attached) return;

      final ui.Image backgroundImage = await boundary.toImage(pixelRatio: 1.0);
      
      if (!_backgroundController.isClosed) {
        _backgroundController.add(backgroundImage);
      }
    } catch (e) {
      // Skip errors to avoid spam
    }
  }

  /// Dispose resources
  void dispose() {
    stopCapture();
    _backgroundController.close();
  }
}

/// Widget that provides real-time background stream to liquid glass effects
class BackgroundStreamProvider extends StatefulWidget {
  final Widget child;
  final GlobalKey backgroundKey;

  const BackgroundStreamProvider({
    super.key,
    required this.child,
    required this.backgroundKey,
  });

  @override
  State<BackgroundStreamProvider> createState() => _BackgroundStreamProviderState();
}

class _BackgroundStreamProviderState extends State<BackgroundStreamProvider> {
  final BackgroundStreamChannel _channel = BackgroundStreamChannel();

  @override
  void initState() {
    super.initState();
    _channel.startCapture(widget.backgroundKey);
  }

  @override
  void dispose() {
    _channel.stopCapture();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Mixin for widgets that need real-time background access
mixin BackgroundStreamMixin<T extends StatefulWidget> on State<T> {
  final BackgroundStreamChannel _channel = BackgroundStreamChannel();
  StreamSubscription<ui.Image>? _backgroundSubscription;
  ui.Image? _currentBackground;

  /// Get the current background image
  ui.Image? get currentBackground => _currentBackground;

  /// Subscribe to background stream
  void subscribeToBackground() {
    _backgroundSubscription = _channel.backgroundStream.listen((image) {
      if (mounted) {
        setState(() {
          _currentBackground?.dispose();
          _currentBackground = image;
        });
      }
    });
  }

  /// Unsubscribe from background stream
  void unsubscribeFromBackground() {
    _backgroundSubscription?.cancel();
    _backgroundSubscription = null;
  }

  @override
  void dispose() {
    unsubscribeFromBackground();
    _currentBackground?.dispose();
    super.dispose();
  }
}
