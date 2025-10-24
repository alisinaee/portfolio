import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// Platform channel interface for native liquid glass shaders
class LiquidGlassPlatformChannel {
  static const MethodChannel _channel = MethodChannel('liquid_glass_shader');
  
  /// Initialize the native shader system
  static Future<bool> initialize() async {
    try {
      final bool result = await _channel.invokeMethod('initialize');
      return result;
    } catch (e) {
      print('Error initializing native shader: $e');
      return false;
    }
  }
  
  /// Apply liquid glass effect to a texture
  static Future<ui.Image?> applyLiquidGlassEffect({
    required ui.Image backgroundImage,
    required double width,
    required double height,
    required double effectSize,
    required double blurIntensity,
    required double dispersionStrength,
    required double glassIntensity,
    required Offset mousePosition,
  }) async {
    try {
      // Convert Flutter image to bytes for platform channel
      final ByteData? byteData = await backgroundImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      
      if (byteData == null) return null;
      
      final Map<String, dynamic> result = await _channel.invokeMethod('applyLiquidGlass', {
        'imageData': byteData.buffer.asUint8List(),
        'width': width,
        'height': height,
        'effectSize': effectSize,
        'blurIntensity': blurIntensity,
        'dispersionStrength': dispersionStrength,
        'glassIntensity': glassIntensity,
        'mouseX': mousePosition.dx,
        'mouseY': mousePosition.dy,
      });
      
      if (result['success'] == true && result['imageData'] != null) {
        // Convert result back to Flutter image
        final Uint8List imageBytes = Uint8List.fromList(result['imageData']);
        final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        return frameInfo.image;
      }
      
      return null;
    } catch (e) {
      print('Error applying liquid glass effect: $e');
      return null;
    }
  }
  
  /// Apply liquid glass effect to entire screen background
  static Future<bool> applyFullScreenLiquidGlass({
    required double effectSize,
    required double blurIntensity,
    required double dispersionStrength,
    required double glassIntensity,
    required Offset mousePosition,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('applyFullScreenLiquidGlass', {
        'effectSize': effectSize,
        'blurIntensity': blurIntensity,
        'dispersionStrength': dispersionStrength,
        'glassIntensity': glassIntensity,
        'mouseX': mousePosition.dx,
        'mouseY': mousePosition.dy,
      });
      return result;
    } catch (e) {
      print('Error applying full screen liquid glass: $e');
      return false;
    }
  }
  
  /// Set liquid glass parameters for real-time updates
  static Future<bool> updateLiquidGlassParameters({
    required double effectSize,
    required double blurIntensity,
    required double dispersionStrength,
    required double glassIntensity,
    required Offset mousePosition,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('updateParameters', {
        'effectSize': effectSize,
        'blurIntensity': blurIntensity,
        'dispersionStrength': dispersionStrength,
        'glassIntensity': glassIntensity,
        'mouseX': mousePosition.dx,
        'mouseY': mousePosition.dy,
      });
      return result;
    } catch (e) {
      print('Error updating liquid glass parameters: $e');
      return false;
    }
  }
  
  /// Start real-time liquid glass effect
  static Future<bool> startRealTimeEffect() async {
    try {
      final bool result = await _channel.invokeMethod('startRealTimeEffect');
      return result;
    } catch (e) {
      print('Error starting real-time effect: $e');
      return false;
    }
  }
  
  /// Stop real-time liquid glass effect
  static Future<bool> stopRealTimeEffect() async {
    try {
      final bool result = await _channel.invokeMethod('stopRealTimeEffect');
      return result;
    } catch (e) {
      print('Error stopping real-time effect: $e');
      return false;
    }
  }
  
  /// Dispose native resources
  static Future<bool> dispose() async {
    try {
      final bool result = await _channel.invokeMethod('dispose');
      return result;
    } catch (e) {
      print('Error disposing native resources: $e');
      return false;
    }
  }
}
