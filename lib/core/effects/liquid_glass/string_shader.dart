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
  
}
