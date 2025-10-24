import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'base_shader.dart';

class RoundedLiquidGlassShader extends BaseShader {
  // Shader uniforms (matching original shader layout)
  static const int _uResolutionIndex = 0;
  static const int _uMouseIndex = 2;
  static const int _uEffectSizeIndex = 4;
  static const int _uBlurIntensityIndex = 5;
  static const int _uDispersionStrengthIndex = 6;
  static const int _uBorderRadiusIndex = 7; // New uniform
  static const int _uTextureIndex = 0; // Sampler

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
      // Set resolution (indices 0-1)
      shader.setFloat(0, width);
      shader.setFloat(1, height);

      // Set mouse position (indices 2-3)
      shader.setFloat(2, width / 2.0);
      shader.setFloat(3, height / 2.0);

      // Set effect parameters (indices 4-6)
      shader.setFloat(4, effectSize ?? 5.0);
      shader.setFloat(5, blurIntensity ?? 0);
      shader.setFloat(6, dispersionStrength ?? 0.4);

      // Set border radius (index 7 - new uniform)
      shader.setFloat(7, borderRadius ?? 6.0);

      // Set background texture (sampler index 0)
      if (backgroundImage != null && backgroundImage.width > 0 && backgroundImage.height > 0) {
        shader.setImageSampler(0, backgroundImage);
      }

      debugPrint('🔍 [RoundedLiquidGlassShader] Uniforms updated - size: ${width}x${height}, borderRadius: ${borderRadius ?? 6.0}');
    } catch (e) {
      debugPrint('❌ [RoundedLiquidGlassShader] Error updating uniforms: $e');
    }
  }
}
