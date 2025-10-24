import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

class StringShader {
  static Future<ui.FragmentProgram?> loadShader() async {
    debugPrint('🔍 [StringShader] Loading shader...');
    debugPrint('🔍 [StringShader] Platform: ${kIsWeb ? "Web" : "Native"}');
    
    if (kIsWeb) {
      // On web, try a different approach - maybe the issue is with the asset path
      debugPrint('🔍 [StringShader] Web detected - trying alternative approach');
      
      // Try different asset paths that might work on web
      final assetPaths = [
        'shaders/liquid_glass_lens.frag',
        'assets/shaders/liquid_glass_lens.frag',
        'packages/moving_text_background_new/shaders/liquid_glass_lens.frag',
      ];
      
      for (final path in assetPaths) {
        try {
          debugPrint('🔍 [StringShader] Trying asset path: $path');
          final program = await ui.FragmentProgram.fromAsset(path);
          debugPrint('✅ [StringShader] Success with path: $path');
          return program;
        } catch (e) {
          debugPrint('❌ [StringShader] Failed with path $path: $e');
        }
      }
      
      debugPrint('❌ [StringShader] All web asset paths failed');
      return null;
    } else {
      // On native platforms, use the standard approach
      try {
        final program = await ui.FragmentProgram.fromAsset('shaders/liquid_glass_lens.frag');
        debugPrint('✅ [StringShader] Native shader loaded successfully');
        return program;
      } catch (e, stackTrace) {
        debugPrint('❌ [StringShader] Native shader loading failed: $e');
        debugPrint('❌ [StringShader] Stack trace: $stackTrace');
        return null;
      }
    }
  }
  
  static String _getShaderCode() {
    return '''
#include <flutter/runtime_effect.glsl>

// Uniforms from Flutter
uniform vec2 uResolution;
uniform vec2 uMouse;
uniform float uEffectSize; // Controls the size of the lens effect (0.1 to 2.0 recommended)
uniform float uBlurIntensity; // Controls the blur strength (0.0 = no blur, 2.0 = heavy blur)
uniform float uDispersionStrength; // Add chromatic dispersion control
uniform sampler2D uTexture;

// Main function
vec4 main(vec2 fragCoord) {
    // Normalize coordinates
    vec2 uv = fragCoord / uResolution.xy;
    
    // Calculate distance from mouse position
    vec2 mousePos = uMouse / uResolution.xy;
    float dist = distance(uv, mousePos);
    
    // Create lens effect with size control
    float lensRadius = uEffectSize * 0.3; // Adjust the base radius
    float lensEffect = 1.0 - smoothstep(0.0, lensRadius, dist);
    
    // Apply distortion based on distance from center
    vec2 distortion = (uv - mousePos) * lensEffect * 0.1;
    vec2 distortedUV = uv - distortion;
    
    // Add chromatic dispersion
    float dispersion = uDispersionStrength * lensEffect;
    vec2 redOffset = distortion * (1.0 + dispersion);
    vec2 greenOffset = distortion;
    vec2 blueOffset = distortion * (1.0 - dispersion);
    
    // Sample texture with different offsets for chromatic effect
    vec4 redSample = texture(uTexture, distortedUV - redOffset);
    vec4 greenSample = texture(uTexture, distortedUV - greenOffset);
    vec4 blueSample = texture(uTexture, distortedUV - blueOffset);
    
    // Combine channels
    vec4 color = vec4(redSample.r, greenSample.g, blueSample.b, 1.0);
    
    // Apply blur based on distance
    float blurAmount = uBlurIntensity * lensEffect;
    if (blurAmount > 0.0) {
        // Simple blur implementation
        vec4 blurColor = vec4(0.0);
        float blurRadius = blurAmount * 0.01;
        
        for (int x = -2; x <= 2; x++) {
            for (int y = -2; y <= 2; y++) {
                vec2 offset = vec2(float(x), float(y)) * blurRadius;
                blurColor += texture(uTexture, distortedUV + offset);
            }
        }
        blurColor /= 25.0; // 5x5 kernel
        
        // Mix original and blurred
        color = mix(color, blurColor, lensEffect * 0.5);
    }
    
    // Apply lens effect intensity
    color = mix(texture(uTexture, uv), color, lensEffect);
    
    return color;
}
''';
  }
}
