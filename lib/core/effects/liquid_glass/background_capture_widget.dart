import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:moving_text_background_new/core/effects/liquid_glass/base_shader.dart';
import 'package:moving_text_background_new/core/effects/liquid_glass/shader_painter.dart';

class BackgroundCaptureWidget extends StatefulWidget {
  const BackgroundCaptureWidget({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    required this.shader,
    this.initialPosition,
    this.captureInterval = const Duration(milliseconds: 8),
    this.backgroundKey,
    this.leftMargin = 50.0,
    this.rightMargin = 5.0,
    this.topMargin = 8.0,
    this.bottomMargin = 8.0,
    this.borderRadius = 35.0,
  });

  final Widget child;
  final double width;
  final double height;

  final Offset? initialPosition;
  final Duration? captureInterval;
  final GlobalKey? backgroundKey;

  final BaseShader shader;
  final double leftMargin;
  final double rightMargin;
  final double topMargin;
  final double bottomMargin;
  final double borderRadius;

  @override
  State<BackgroundCaptureWidget> createState() =>
      _BackgroundCaptureWidgetState();
}

class _BackgroundCaptureWidgetState extends State<BackgroundCaptureWidget>
    with TickerProviderStateMixin {
  late Offset position;
  Timer? timer;
  bool isCapturing = false;
  ui.Image? capturedBackground;

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition ?? const Offset(100, 100);

    _startContinuousCapture();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureBackground();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    capturedBackground?.dispose();
    super.dispose();
  }

  void _startContinuousCapture() {
    if (widget.captureInterval != null) {
      timer = Timer.periodic(widget.captureInterval!, (timer) {
        if (mounted && !isCapturing) {
          _captureBackground();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _buildWidgetContent(),
    );
  }

  // Method to trigger background capture from parent
  void triggerBackgroundCapture() {
    if (!isCapturing) {
      _captureBackground();
    }
  }

  Widget _buildWidgetContent() {
    if (widget.shader.isLoaded && capturedBackground != null) {
      widget.shader.updateShaderUniforms(
        width: widget.width,
        height: widget.height,
        backgroundImage: capturedBackground,
      );
      return CustomPaint(
        size: Size(widget.width, widget.height), // Use full size without any constraints
        painter: ShaderPainter(
          widget.shader.shader,
          leftMargin: widget.leftMargin,
          rightMargin: widget.rightMargin,
          topMargin: widget.topMargin,
          bottomMargin: widget.bottomMargin,
          borderRadius: widget.borderRadius,
              showRedBorder: false,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 50, right: 50, top: 8, bottom: 8), // Keep padding only for content
          child: widget.child,
        ),
      );
    }

    // Fallback to normal child
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, top: 8, bottom: 8), // Symmetric margins for proper centering
      child: widget.child,
    );
  }

  Future<void> _captureBackground() async {
    if (isCapturing || !mounted) return;

    isCapturing = true;

    try {
      // 1. Get the RenderRepaintBoundary
      final boundary = widget.backgroundKey?.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      final ourBox = context.findRenderObject() as RenderBox?;

      if (boundary == null ||
          !boundary.attached ||
          ourBox == null ||
          !ourBox.hasSize) {
        return;
      }

      // 2. Calculate the capture region
      final boundaryBox = boundary as RenderBox;
      if (!boundaryBox.hasSize || widget.width <= 0 || widget.height <= 0) {
        return;
      }

      final widgetRectInBoundary = Rect.fromPoints(
        boundaryBox.globalToLocal(ourBox.localToGlobal(Offset.zero)),
        boundaryBox.globalToLocal(
          ourBox.localToGlobal(ourBox.size.bottomRight(Offset.zero)),
        ),
      );

      final boundaryRect = Rect.fromLTWH(
        0,
        0,
        boundaryBox.size.width,
        boundaryBox.size.height,
      );
      final Rect regionToCapture = widgetRectInBoundary.intersect(boundaryRect);

      if (regionToCapture.isEmpty) {
        return;
      }

      // 3. Capture the image
      final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final OffsetLayer? offsetLayer = boundary.debugLayer as OffsetLayer?;
      
      ui.Image croppedImage;
      
      if (offsetLayer == null) {
        debugPrint('Warning: debugLayer is null, using alternative capture method');
        // Fallback: capture the entire boundary and crop
        croppedImage = await boundary.toImage(pixelRatio: pixelRatio);
      } else {
        croppedImage = await offsetLayer
        .toImage(
          regionToCapture,
          pixelRatio: pixelRatio,
        );
      }

      // 5. Update state
      if (mounted) {
        setState(() {
          capturedBackground?.dispose();
          capturedBackground = croppedImage;
        });
      } else {
        croppedImage.dispose();
      }
    } catch (e) {
      debugPrint('Error capturing background: $e');
    } finally {
      if (mounted) {
        isCapturing = false;
      }
    }
  }
}