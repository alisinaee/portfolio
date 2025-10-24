import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'base_shader.dart';

class RoundedLiquidGlassShader extends BaseShader {
  // Shader uniforms
  static const int _uResolutionIndex = 0;
  static const int _uMouseIndex = 1;
  static const int _uEffectSizeIndex = 2;
  static const int _uBlurIntensityIndex = 3;
  static const int _uDispersionStrengthIndex = 4;
  static const int _uBorderRadiusIndex = 5;
  static const int _uTextureIndex = 6;

  RoundedLiquidGlassShader() : super(shaderAssetPath: 'shaders/rounded_liquid_glass.frag');

  @override
  Future<void> initialize() async {
    await super.initialize();
  }

  @override
  void updateShaderUniforms({
    required double width,
    required double height,
    ui.Image? backgroundImage,
    double? effectSize,
    double? blurIntensity,
    double? dispersionStrength,
    double? borderRadius,
  }) {
    if (!isLoaded) return;

    try {
      // Set resolution
      shader.setFloat(_uResolutionIndex, width);
      shader.setFloat(_uResolutionIndex + 1, height);
      
      // Set mouse position (center of the widget)
      shader.setFloat(_uMouseIndex, width / 2.0);
      shader.setFloat(_uMouseIndex + 1, height / 2.0);
      
      // Set effect parameters
      shader.setFloat(_uEffectSizeIndex, effectSize ?? 1.0);
      shader.setFloat(_uBlurIntensityIndex, blurIntensity ?? 0.5);
      shader.setFloat(_uDispersionStrengthIndex, dispersionStrength ?? 0.1);
      shader.setFloat(_uBorderRadiusIndex, borderRadius ?? 6.0);
      
      // Set background texture
      if (backgroundImage != null) {
        shader.setImageSampler(_uTextureIndex, backgroundImage);
      }
      
      debugPrint('🔍 [RoundedLiquidGlassShader] Uniforms updated - size: ${width}x${height}, borderRadius: ${borderRadius ?? 6.0}');
    } catch (e) {
      debugPrint('❌ [RoundedLiquidGlassShader] Error updating uniforms: $e');
    }
  }
}
