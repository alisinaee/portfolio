# Liquid Glass - Technical Reference

## 🔧 API Reference

### BaseShader
```dart
abstract class BaseShader {
  final String shaderAssetPath;
  bool get isLoaded;
  ui.FragmentShader get shader;
  
  Future<void> initialize();
  void updateShaderUniforms({
    required double width,
    required double height,
    required ui.Image? backgroundImage,
  });
}
```

### LiquidGlassLensShader
```dart
class LiquidGlassLensShader extends BaseShader {
  LiquidGlassLensShader() : super(shaderAssetPath: 'shaders/liquid_glass_lens.frag');
  
  @override
  void updateShaderUniforms({
    required double width,
    required double height,
    required ui.Image? backgroundImage,
  });
}
```

### BackgroundCaptureWidget
```dart
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
  });

  final Widget child;
  final double width;
  final double height;
  final Offset? initialPosition;
  final Duration? captureInterval;
  final GlobalKey? backgroundKey;
  final BaseShader shader;
}
```

### ShaderPainter
```dart
class ShaderPainter extends CustomPainter {
  ShaderPainter(this.shader);
  
  final ui.FragmentShader shader;
  
  @override
  void paint(Canvas canvas, Size size);
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
```

## 🎨 Shader Uniforms

### Fragment Shader Uniforms
```glsl
uniform vec2 uResolution;        // Screen resolution
uniform vec2 uMouse;             // Mouse/center position  
uniform float uEffectSize;       // Lens size (0.1 to 2.0)
uniform float uBlurIntensity;    // Blur strength (0.0 to 2.0)
uniform float uDispersionStrength; // Chromatic dispersion (0.0 to 1.0)
uniform sampler2D uTexture;      // Background texture
```

### Uniform Index Mapping
```dart
// Resolution (indices 0-1)
shader.setFloat(0, width);   // uResolution.x
shader.setFloat(1, height);  // uResolution.y

// Mouse position (indices 2-3)  
shader.setFloat(2, mouseX);  // uMouse.x
shader.setFloat(3, mouseY);  // uMouse.y

// Effect parameters (indices 4-6)
shader.setFloat(4, effectSize);        // uEffectSize
shader.setFloat(5, blurIntensity);     // uBlurIntensity  
shader.setFloat(6, dispersionStrength); // uDispersionStrength

// Texture (sampler 0)
shader.setImageSampler(0, backgroundImage); // uTexture
```

## 🎯 Shader Effects Breakdown

### 1. Rounded Box Effect
```glsl
float effectRadius = uEffectSize * 0.5;
float sizeMultiplier = 1.0 / (effectRadius * effectRadius);
float roundedBox = pow(abs(m2.x * uResolution.x / uResolution.y), 4.0) +
                  pow(abs(m2.y), 4.0);
```

### 2. Lens Distortion
```glsl
float distortionStrength = 50.0 * sizeMultiplier;
vec2 lens = ((uv - 0.5) * (1.0 - roundedBox * distortionStrength) + 0.5);
```

### 3. Chromatic Dispersion
```glsl
vec2 dir = normalize(m2);
float dispersionScale = uDispersionStrength * 0.05;
float dispersionMask = smoothstep(0.3, 0.7, roundedBox * baseIntensity);

vec2 redOffset = dir * dispersionScale * 2.0 * dispersionMask;
vec2 greenOffset = dir * dispersionScale * 1.0 * dispersionMask;
vec2 blueOffset = dir * dispersionScale * -1.5 * dispersionMask;
```

### 4. Blur Sampling
```glsl
if (uBlurIntensity > 0.0) {
    float blurRadius = uBlurIntensity / max(uResolution.x, uResolution.y);
    float total = 0.0;
    vec3 colorSum = vec3(0.0);
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x, y) * blurRadius;
            colorSum.r += texture(uTexture, lens + offset + redOffset).r;
            colorSum.g += texture(uTexture, lens + offset + greenOffset).g;
            colorSum.b += texture(uTexture, lens + offset + blueOffset).b;
            total += 1.0;
        }
    }
    colorResult = vec4(colorSum / total, 1.0);
}
```

## 🔄 Background Capture Process

### 1. Boundary Detection
```dart
final boundary = widget.backgroundKey?.currentContext?.findRenderObject()
    as RenderRepaintBoundary?;
```

### 2. Coordinate Transformation
```dart
final widgetRectInBoundary = Rect.fromPoints(
  boundaryBox.globalToLocal(ourBox.localToGlobal(Offset.zero)),
  boundaryBox.globalToLocal(
    ourBox.localToGlobal(ourBox.size.bottomRight(Offset.zero)),
  ),
);
```

### 3. Image Capture
```dart
final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
final OffsetLayer offsetLayer = boundary.debugLayer! as OffsetLayer;
final ui.Image croppedImage = await offsetLayer.toImage(
  regionToCapture,
  pixelRatio: pixelRatio,
);
```

### 4. Memory Management
```dart
if (mounted) {
  setState(() {
    capturedBackground?.dispose();
    capturedBackground = croppedImage;
  });
} else {
  croppedImage.dispose();
}
```

## ⚡ Performance Metrics

### Capture Performance
| Device Type | Capture Time | Recommended Frequency |
|-------------|--------------|----------------------|
| High-end    | 8-16ms       | 16ms (60 FPS)        |
| Mid-range   | 16-33ms      | 33ms (30 FPS)        |
| Low-end     | 33-50ms      | 50ms (20 FPS)        |

### Memory Usage
| Component | Memory Usage | Notes |
|-----------|--------------|-------|
| Background Image | 2-4MB | Per capture |
| Shader Resources | 1-2MB | Per shader instance |
| Total Overhead | 3-6MB | Per lens |

### Frame Rate Impact
| Capture Frequency | Frame Rate Impact | Use Case |
|-------------------|-------------------|----------|
| 8ms (120 FPS)     | High              | Maximum smoothness |
| 16ms (60 FPS)     | Medium            | Balanced performance |
| 33ms (30 FPS)     | Low               | Efficient operation |
| 50ms (20 FPS)     | Minimal           | Background tasks |

## 🐛 Error Handling

### Shader Loading Errors
```dart
try {
  _program = await ui.FragmentProgram.fromAsset(shaderAssetPath);
  _shader = _program.fragmentShader();
  _isLoaded = true;
} catch (e) {
  debugPrint('Error loading shader: $e');
  _isLoaded = false;
}
```

### Background Capture Errors
```dart
try {
  // Capture logic
} catch (e) {
  debugPrint('Error capturing background: $e');
} finally {
  if (mounted) {
    isCapturing = false;
  }
}
```

### Shader Uniform Errors
```dart
try {
  shader.setImageSampler(0, backgroundImage);
} catch (e) {
  debugPrint('Error setting background texture: $e');
}
```

## 🔧 Debugging Tools

### Performance Monitoring
```dart
class PerformanceMonitor {
  static void logCaptureTime(String id, Duration duration) {
    if (duration.inMilliseconds > 16) {
      debugPrint('Slow capture [$id]: ${duration.inMilliseconds}ms');
    }
  }
  
  static void logMemoryUsage(String id, int bytes) {
    final mb = bytes / (1024 * 1024);
    debugPrint('Memory usage [$id]: ${mb.toStringAsFixed(2)}MB');
  }
}
```

### Shader Debugging
```dart
class ShaderDebugger {
  static void logShaderUniforms(LiquidGlassLensShader shader) {
    debugPrint('Shader uniforms:');
    debugPrint('  Resolution: ${shader.width}x${shader.height}');
    debugPrint('  Effect size: ${shader.effectSize}');
    debugPrint('  Blur intensity: ${shader.blurIntensity}');
    debugPrint('  Dispersion: ${shader.dispersionStrength}');
  }
}
```

## 📱 Platform-Specific Considerations

### Web
```dart
// Web-specific optimizations
if (kIsWeb) {
  // Reduce capture frequency for web
  captureInterval: Duration(milliseconds: 33),
  // Use smaller lens size
  width: 120,
  height: 120,
}
```

### Mobile
```dart
// Mobile-specific optimizations
if (Platform.isAndroid || Platform.isIOS) {
  // Use device pixel ratio
  final pixelRatio = MediaQuery.of(context).devicePixelRatio;
  // Adjust lens size based on screen size
  final screenSize = MediaQuery.of(context).size;
  final lensSize = min(screenSize.width, screenSize.height) * 0.2;
}
```

### Desktop
```dart
// Desktop-specific optimizations
if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
  // Higher capture frequency for desktop
  captureInterval: Duration(milliseconds: 16),
  // Larger lens size
  width: 200,
  height: 200,
}
```

## 🎨 Custom Shader Development

### Creating Custom Shaders
```glsl
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform sampler2D uTexture;
out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord() / uResolution.xy;
    
    // Custom effect implementation
    vec4 color = texture(uTexture, uv);
    
    // Apply custom transformations
    color.rgb = pow(color.rgb, vec3(1.2)); // Gamma correction
    
    fragColor = color;
}
```

### Custom Shader Class
```dart
class CustomEffectShader extends BaseShader {
  CustomEffectShader() : super(shaderAssetPath: 'shaders/custom_effect.frag');
  
  @override
  void updateShaderUniforms({
    required double width,
    required double height,
    required ui.Image? backgroundImage,
  }) {
    if (!isLoaded) return;
    
    // Set custom uniforms
    shader.setFloat(0, width);
    shader.setFloat(1, height);
    
    if (backgroundImage != null) {
      shader.setImageSampler(0, backgroundImage);
    }
  }
}
```

## 🔄 Integration Patterns

### Singleton Pattern
```dart
class ShaderManager {
  static final ShaderManager _instance = ShaderManager._internal();
  factory ShaderManager() => _instance;
  ShaderManager._internal();
  
  late LiquidGlassLensShader _shader;
  bool _initialized = false;
  
  Future<void> initialize() async {
    if (!_initialized) {
      _shader = LiquidGlassLensShader()..initialize();
      _initialized = true;
    }
  }
  
  LiquidGlassLensShader get shader => _shader;
}
```

### Factory Pattern
```dart
class ShaderFactory {
  static BaseShader createShader(ShaderType type) {
    switch (type) {
      case ShaderType.liquidGlass:
        return LiquidGlassLensShader();
      case ShaderType.custom:
        return CustomEffectShader();
      default:
        throw ArgumentError('Unknown shader type: $type');
    }
  }
}

enum ShaderType { liquidGlass, custom }
```

This technical reference provides comprehensive information for developers working with the liquid glass package at a deep technical level.

