import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BaseShader {
  BaseShader({
    required this.shaderAssetPath,
  });

  final String shaderAssetPath;

  late ui.FragmentProgram _program;
  late ui.FragmentShader _shader;

  bool _isLoaded = false;

  ui.FragmentShader get shader => _shader;
  bool get isLoaded => _isLoaded;

  Future<void> initialize() async {
    await _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      debugPrint('🔍 [BaseShader] ===== SHADER LOADING START =====');
      debugPrint('🔍 [BaseShader] Shader path: $shaderAssetPath');
      debugPrint('🔍 [BaseShader] Current working directory: ${Uri.base}');
      debugPrint('🔍 [BaseShader] Is Web: ${kIsWeb}');
      
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
            debugPrint('🔍 [BaseShader] Trying web path: $path');
            program = await ui.FragmentProgram.fromAsset(path);
            debugPrint('✅ [BaseShader] Loaded from web path: $path');
            break;
          } catch (e) {
            debugPrint('❌ [BaseShader] Failed web path $path: $e');
          }
        }
        
        if (program == null) {
          throw Exception('Could not load shader from any web path');
        }
        
        _program = program;
      } else {
        // For non-web platforms, use the original path
        debugPrint('🔍 [BaseShader] Loading shader for non-web platform: $shaderAssetPath');
        _program = await ui.FragmentProgram.fromAsset(shaderAssetPath);
      }
      
      debugPrint('✅ [BaseShader] FragmentProgram loaded successfully');
      
      _shader = _program.fragmentShader();
      debugPrint('✅ [BaseShader] FragmentShader created successfully');
      
      _isLoaded = true;
      debugPrint('✅ [BaseShader] Shader fully loaded and ready');
      debugPrint('🔍 [BaseShader] ===== SHADER LOADING SUCCESS =====');
    } catch (e, stackTrace) {
      debugPrint('❌ [BaseShader] ===== SHADER LOADING FAILED =====');
      debugPrint('❌ [BaseShader] Error: $e');
      debugPrint('❌ [BaseShader] Error type: ${e.runtimeType}');
      debugPrint('❌ [BaseShader] Shader path was: $shaderAssetPath');
      debugPrint('❌ [BaseShader] Stack trace: $stackTrace');
      debugPrint('❌ [BaseShader] ===== END ERROR =====');
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