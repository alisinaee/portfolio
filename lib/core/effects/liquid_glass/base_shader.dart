import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

class BaseShader {
  BaseShader({
    required this.shaderAssetPath,
  });

  final String shaderAssetPath;

  late ui.FragmentProgram _program;
  late ui.FragmentShader _shader;

  bool _isLoaded = false;
  bool _isLoading = false;
  
  // Static cache to prevent multiple loads of the same shader
  static final Map<String, BaseShader> _shaderCache = {};

  ui.FragmentShader get shader => _shader;
  bool get isLoaded => _isLoaded;

  static BaseShader getInstance(String shaderAssetPath) {
    return _shaderCache.putIfAbsent(shaderAssetPath, () => BaseShader._(shaderAssetPath));
  }

  BaseShader._(this.shaderAssetPath);

  Future<void> initialize() async {
    if (_isLoaded || _isLoading) return;
    await _loadShader();
  }

  Future<void> _loadShader() async {
    if (_isLoaded || _isLoading) return;
    
    _isLoading = true;
    
    try {
      if (kDebugMode) {
        debugPrint('🔍 [BaseShader] ===== SHADER LOADING START =====');
        debugPrint('🔍 [BaseShader] Shader path: $shaderAssetPath');
        debugPrint('🔍 [BaseShader] Current working directory: ${Uri.base}');
        debugPrint('🔍 [BaseShader] Is Web: $kIsWeb');
      }
      
      if (kIsWeb) {
        // For web, try multiple paths to find the compiled shader
        final webPaths = [
          'assets/$shaderAssetPath',
          'packages/moving_text_background_new/$shaderAssetPath',
          shaderAssetPath,
        ];
        
        ui.FragmentProgram? program;
        for (final path in webPaths) {
          try {
            if (kDebugMode) debugPrint('🔍 [BaseShader] Trying web path: $path');
            program = await ui.FragmentProgram.fromAsset(path);
            if (kDebugMode) debugPrint('✅ [BaseShader] Loaded from web path: $path');
            break;
          } catch (e) {
            if (kDebugMode) debugPrint('❌ [BaseShader] Failed web path $path: $e');
          }
        }
        
        if (program == null) {
          throw Exception('Could not load shader from any web path');
        }
        
        _program = program;
      } else {
        // For non-web platforms, use the original path
        if (kDebugMode) debugPrint('🔍 [BaseShader] Loading shader for non-web platform: $shaderAssetPath');
        _program = await ui.FragmentProgram.fromAsset(shaderAssetPath);
      }
      
      if (kDebugMode) debugPrint('✅ [BaseShader] FragmentProgram loaded successfully');
      
      _shader = _program.fragmentShader();
      if (kDebugMode) debugPrint('✅ [BaseShader] FragmentShader created successfully');
      
      _isLoaded = true;
      _isLoading = false;
      if (kDebugMode) {
        debugPrint('✅ [BaseShader] Shader fully loaded and ready');
        debugPrint('🔍 [BaseShader] ===== SHADER LOADING SUCCESS =====');
      }
    } catch (e, stackTrace) {
      _isLoading = false;
      if (kDebugMode) {
        debugPrint('❌ [BaseShader] ===== SHADER LOADING FAILED =====');
        debugPrint('❌ [BaseShader] Error: $e');
        debugPrint('❌ [BaseShader] Error type: ${e.runtimeType}');
        debugPrint('❌ [BaseShader] Shader path was: $shaderAssetPath');
        debugPrint('❌ [BaseShader] Stack trace: $stackTrace');
        debugPrint('❌ [BaseShader] ===== END ERROR =====');
      }
    }
  }

  void updateShaderUniforms({
    required double width,
    required double height,
    required ui.Image? backgroundImage,
    double? effectSize,
    double? blurIntensity,
    double? dispersionStrength,
    double? borderRadius,
  }) {
    throw UnimplementedError();
  }
}