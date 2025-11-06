import 'liquid_glass_lens_shader.dart';

/// Singleton shader manager to prevent multiple shader loads
class ShaderManager {
  static ShaderManager? _instance;
  static ShaderManager get instance => _instance ??= ShaderManager._();
  
  ShaderManager._();
  
  LiquidGlassLensShader? _liquidGlassShader;
  
  /// Get cached liquid glass shader instance
  LiquidGlassLensShader getLiquidGlassShader() {
    return _liquidGlassShader ??= LiquidGlassLensShader();
  }
  
  /// Initialize all shaders (call once at app startup)
  Future<void> initializeShaders() async {
    final shader = getLiquidGlassShader();
    await shader.initialize();
  }
  
  /// Check if shaders are loaded
  bool get isLoaded => _liquidGlassShader?.isLoaded ?? false;
}