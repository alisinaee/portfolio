import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

class WebShaderLoader {
  static Future<ui.FragmentProgram?> loadShader() async {
    debugPrint('🔍 [WebShaderLoader] Loading shader...');
    debugPrint('🔍 [WebShaderLoader] Platform: ${kIsWeb ? "Web" : "Native"}');
    
    // Try different asset paths that might work on web
    final assetPaths = [
      'shaders/liquid_glass_lens.frag',
      'assets/shaders/liquid_glass_lens.frag',
      'packages/moving_text_background_new/shaders/liquid_glass_lens.frag',
    ];
    
    for (final path in assetPaths) {
      try {
        debugPrint('🔍 [WebShaderLoader] Trying asset path: $path');
        final program = await ui.FragmentProgram.fromAsset(path);
        debugPrint('✅ [WebShaderLoader] Success with path: $path');
        return program;
      } catch (e) {
        debugPrint('❌ [WebShaderLoader] Failed with path $path: $e');
      }
    }
    
    debugPrint('❌ [WebShaderLoader] All asset paths failed');
    return null;
  }
  
}
