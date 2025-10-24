# Flutter Shader Development Guide

This guide covers how to create and use custom fragment shaders in Flutter applications, specifically for implementing liquid glass effects.

## Table of Contents
1. [Overview](#overview)
2. [Adding Shaders to Your Project](#adding-shaders-to-your-project)
3. [Loading Shaders at Runtime](#loading-shaders-at-runtime)
4. [Using Shaders with Canvas API](#using-shaders-with-canvas-api)
5. [Using Shaders with ImageFilter API](#using-shaders-with-imagefilter-api)
6. [Authoring Shaders](#authoring-shaders)
7. [Uniforms and Parameters](#uniforms-and-parameters)
8. [Performance Considerations](#performance-considerations)
9. [Liquid Glass Implementation](#liquid-glass-implementation)
10. [Troubleshooting](#troubleshooting)

## Overview

Custom shaders in Flutter allow you to create rich graphical effects beyond what the SDK provides. Shaders are programs written in GLSL (OpenGL Shading Language) that execute on the GPU.

### What Are Fragment Shaders?
Fragment shaders are small GPU programs that determine the color of each pixel on the screen. Think of them as functions that run in parallel for every pixel, where:

- **Input**: The pixel's position (coordinates) and custom parameters called uniforms
- **Output**: A single color value for that pixel

**NOTE**: Shaders run on the GPU, making them incredibly fast. Fragment shaders are typically the final step in the graphics pipeline, which is why they're so efficient for real-time effects.

### Key Concepts
- **Fragment Shaders**: Process individual pixels/fragments
- **GLSL**: The shader programming language
- **Uniforms**: Parameters passed from Dart to the shader
- **Samplers**: Access to image data within shaders
- **GPU Processing**: Parallel execution for maximum performance

## Adding Shaders to Your Project

### 1. Create Shader Files
Place your `.frag` files in a `shaders/` directory:

```
project/
├── shaders/
│   ├── liquid_glass_lens.frag
│   ├── web_liquid_glass.frag
│   └── simple_test.frag
└── pubspec.yaml
```

### 2. Declare in pubspec.yaml
```yaml
flutter:
  shaders:
    - shaders/liquid_glass_lens.frag
    - shaders/web_liquid_glass.frag
    - shaders/simple_test.frag
```

### 3. Hot Reload Support
Changes to shader files trigger recompilation during hot reload/restart in debug mode.

## Loading Shaders at Runtime

### Method 1: Using flutter_shaders Package (Recommended)
The `flutter_shaders` package provides a more convenient way to work with shaders:

```dart
import 'package:flutter_shaders/flutter_shaders.dart';

class MyShaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      assetKey: 'shaders/myshader.frag',
      (BuildContext context, FragmentShader shader, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: MyShaderPainter(shader),
        );
      },
    );
  }
}

class MyShaderPainter extends CustomPainter {
  final FragmentShader shader;

  MyShaderPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### Method 2: Manual Loading
```dart
import 'dart:ui' as ui;

Future<void> loadMyShader() async {
  var program = await ui.FragmentProgram.fromAsset('shaders/myshader.frag');
  var shader = program.fragmentShader();
  
  // Set uniforms
  shader.setFloat(0, 42.0);
  shader.setFloat(1, 100.0);
  
  // Use with Canvas
  canvas.drawRect(rect, Paint()..shader = shader);
}
```

### Error Handling
```dart
Future<ui.FragmentProgram?> loadShaderSafely(String assetPath) async {
  try {
    return await ui.FragmentProgram.fromAsset(assetPath);
  } catch (e) {
    debugPrint('Failed to load shader $assetPath: $e');
    return null;
  }
}
```

## Using Shaders with Canvas API

### Basic Usage
```dart
void paint(Canvas canvas, Size size, ui.FragmentShader shader) {
  // Draw rectangle with shader
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.width, size.height),
    Paint()..shader = shader,
  );
}
```

### Stroked Paths
```dart
void paintStroked(Canvas canvas, Size size, ui.FragmentShader shader) {
  // Shader only applies to stroke, not fill
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.width, size.height),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = shader,
  );
}
```

## Using Shaders with ImageFilter API

### BackdropFilter Implementation
```dart
Widget build(BuildContext context, ui.FragmentShader shader) {
  return ClipRect(
    child: SizedBox(
      width: 300,
      height: 300,
      child: BackdropFilter(
        filter: ui.ImageFilter.shader(shader),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    ),
  );
}
```

### Important Notes
- Use `ClipRect` to limit the affected area
- Without `ClipRect`, the filter affects the whole screen
- The shader receives automatic values:
  - `sampler2D` at index 0: filter input image
  - `float` at index 0: image width
  - `float` at index 1: image height

## Authoring Shaders

### Basic Structure
```glsl
#include <flutter/runtime_effect.glsl>

// Uniform declarations
uniform vec2 uResolution;
uniform vec2 uMouse;
uniform float uTime;

// Output
out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uResolution.xy;
    
    // Your shader logic here
    
    fragColor = vec4(1.0, 0.0, 0.0, 1.0); // Red output
}
```

### GLSL Limitations in Flutter
- **UBOs and SSBOs**: Not supported
- **Sampler Types**: Only `sampler2D` supported
- **Texture Function**: Only two-argument version `texture(sampler, uv)`
- **Varying Inputs**: No additional varying inputs allowed
- **Precision Hints**: Ignored when targeting Skia
- **Data Types**: No unsigned integers or booleans

### Supported GLSL Versions
- Any version from 460 down to 100
- Examples use version 460 core

## Uniforms and Parameters

### Setting Float Uniforms
```dart
void updateShader(ui.FragmentShader shader, Color color, double scale) {
  // For: uniform float uScale;
  shader.setFloat(0, scale);
  
  // For: uniform vec2 uMagnitude;
  shader.setFloat(1, 114.0); // x component
  shader.setFloat(2, 83.0);  // y component
  
  // For: uniform vec4 uColor;
  shader.setFloat(3, color.red / 255.0 * color.opacity);   // r
  shader.setFloat(4, color.green / 255.0 * color.opacity); // g
  shader.setFloat(5, color.blue / 255.0 * color.opacity);  // b
  shader.setFloat(6, color.opacity);                       // a
}
```

### Setting Sampler Uniforms
```dart
void updateShader(ui.FragmentShader shader, ui.Image image) {
  // For: uniform sampler2D uTexture;
  shader.setImageSampler(0, image);
}
```

### Important Notes
- **Index Order**: Based on uniform declaration order in GLSL
- **Sampler Indices**: Start over at 0 for `setImageSampler`
- **Uninitialized Values**: Default to 0.0
- **Color Conversion**: Convert Flutter colors to normalized RGBA

## Performance Considerations

### Best Practices
1. **Precache Shaders**: Load before animations start
2. **Reuse FragmentShader**: Don't create new instances each frame
3. **Minimize Uniform Updates**: Only update when values change
4. **Optimize Shader Code**: Avoid expensive operations in loops

### Example: Efficient Shader Management
```dart
class ShaderManager {
  ui.FragmentProgram? _program;
  ui.FragmentShader? _shader;
  
  Future<void> initialize() async {
    _program = await ui.FragmentProgram.fromAsset('shaders/my_shader.frag');
  }
  
  ui.FragmentShader getShader() {
    _shader ??= _program!.fragmentShader();
    return _shader!;
  }
  
  void dispose() {
    _shader?.dispose();
    _program = null;
  }
}
```

## Practical Examples

### 1. Snowfall Animation Shader
Based on the Medium article by Sivaram Subramanian, here's how to create a snowfall animation:

```glsl
#version 120
#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
uniform int inverter;
out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    // Invert Y for iOS compatibility
    if (inverter == 1) {
        uv.y = 1.0 - uv.y;
    }
    
    // Snowfall effect implementation
    float snow = 0.0;
    for (int i = 0; i < 50; i++) {
        float x = float(i) * 0.1;
        float y = mod(x * 0.1 + iTime * 0.1, 1.0);
        vec2 snowPos = vec2(x, y);
        float dist = distance(uv, snowPos);
        snow += smoothstep(0.02, 0.01, dist);
    }
    
    fragColor = vec4(snow, snow, snow, 1.0);
}
```

### 2. Dart Implementation for Snowfall
```dart
class SnowfallWidget extends StatefulWidget {
  @override
  _SnowfallWidgetState createState() => _SnowfallWidgetState();
}

class _SnowfallWidgetState extends State<SnowfallWidget> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late ValueNotifier<double> _timeNotifier;
  Paint _snowPaint = Paint();
  FragmentShader? _snowShader;

  @override
  void initState() {
    super.initState();
    _timeNotifier = ValueNotifier(0.0);
    _controller = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _loadShader();
    _controller.addListener(() {
      _timeNotifier.value = _controller.value * 10.0;
    });
  }

  Future<void> _loadShader() async {
    try {
      final program = await FragmentProgram.fromAsset('shaders/snowfall.frag');
      _snowShader = program.fragmentShader();
      _snowPaint.shader = _snowShader;
    } catch (e) {
      debugPrint('Failed to load snowfall shader: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _timeNotifier,
      builder: (context, time, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: SnowfallPainter(_snowPaint, time),
        );
      },
    );
  }
}

class SnowfallPainter extends CustomPainter {
  final Paint paint;
  final double time;

  SnowfallPainter(this.paint, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (paint.shader != null) {
      // Set uniforms
      paint.shader!.setFloat(0, size.width);
      paint.shader!.setFloat(1, size.height);
      paint.shader!.setFloat(2, time);
      paint.shader!.setFloat(3, Platform.isIOS ? 1 : 0); // inverter
      
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

### 3. Performance Considerations
- **Use Profile Mode**: Run with `flutter run --profile --enable-impeller` for better shader compilation
- **Precache Shaders**: Load shaders before animations start
- **Reuse FragmentShader**: Don't create new instances each frame
- **Platform Differences**: iOS renders shaders upside down, use inverter uniform

## Liquid Glass Implementation

### 1. Basic Liquid Glass Shader
```glsl
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform vec2 uMouse;
uniform float uEffectSize;
uniform float uBlurIntensity;
uniform float uDispersionStrength;
uniform float uGlassIntensity;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uResolution.xy;
    
    // Calculate distance from mouse
    vec2 center = uMouse.xy / uResolution.xy;
    vec2 m2 = (uv - center);
    
    // Create liquid glass effect
    float effectRadius = uEffectSize * 0.5;
    float sizeMultiplier = 1.0 / (effectRadius * effectRadius);
    float roundedBox = pow(abs(m2.x * uResolution.x / uResolution.y), 4.0) +
                      pow(abs(m2.y), 4.0);
    
    float baseIntensity = 100.0 * sizeMultiplier;
    float rb1 = clamp((1.0 - roundedBox * baseIntensity) * 8.0, 0.0, 1.0);
    
    if (rb1 > 0.0) {
        // Apply distortion and chromatic dispersion
        float distortionStrength = 50.0 * sizeMultiplier;
        vec2 lens = ((uv - 0.5) * (1.0 - roundedBox * distortionStrength) + 0.5);
        
        vec2 dir = normalize(m2);
        float dispersionScale = uDispersionStrength * 0.05;
        float dispersionMask = smoothstep(0.3, 0.7, roundedBox * baseIntensity);
        
        vec2 redOffset = dir * dispersionScale * 2.0 * dispersionMask;
        vec2 greenOffset = dir * dispersionScale * 1.0 * dispersionMask;
        vec2 blueOffset = dir * dispersionScale * -1.5 * dispersionMask;
        
        // Sample texture with chromatic dispersion
        vec4 colorResult;
        colorResult.r = texture(uTexture, lens + redOffset).r;
        colorResult.g = texture(uTexture, lens + greenOffset).g;
        colorResult.b = texture(uTexture, lens + blueOffset).b;
        colorResult.a = 1.0;
        
        // Mix with original
        colorResult = mix(
            texture(uTexture, uv),
            colorResult,
            rb1 * uGlassIntensity
        );
        
        fragColor = colorResult;
    } else {
        fragColor = texture(uTexture, uv);
    }
}
```

### 2. Dart Implementation
```dart
class LiquidGlassWidget extends StatefulWidget {
  final GlobalKey backgroundKey;
  final Widget child;
  
  const LiquidGlassWidget({
    super.key,
    required this.backgroundKey,
    required this.child,
  });

  @override
  State<LiquidGlassWidget> createState() => _LiquidGlassWidgetState();
}

class _LiquidGlassWidgetState extends State<LiquidGlassWidget> {
  ui.FragmentShader? _shader;
  ui.Image? _capturedBackground;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeShader();
  }

  Future<void> _initializeShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/liquid_glass_lens.frag');
      _shader = program.fragmentShader();
      _isInitialized = true;
      _captureBackground();
    } catch (e) {
      debugPrint('Failed to load shader: $e');
    }
  }

  Future<void> _captureBackground() async {
    if (!_isInitialized || widget.backgroundKey.currentContext == null) return;
    
    try {
      final boundary = widget.backgroundKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary != null && boundary.attached) {
        final image = await boundary.toImage(pixelRatio: 1.0);
        setState(() {
          _capturedBackground = image;
        });
      }
    } catch (e) {
      debugPrint('Failed to capture background: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          if (_shader != null && _capturedBackground != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _LiquidGlassPainter(
                  shader: _shader!,
                  background: _capturedBackground!,
                ),
              ),
            ),
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

class _LiquidGlassPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ui.Image background;

  _LiquidGlassPainter({
    required this.shader,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Set uniforms
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, size.width / 2); // mouse x
    shader.setFloat(3, size.height / 2); // mouse y
    shader.setFloat(4, 2.0); // effect size
    shader.setFloat(5, 0.5); // blur intensity
    shader.setFloat(6, 0.1); // dispersion strength
    shader.setFloat(7, 0.3); // glass intensity
    
    // Set background texture
    shader.setImageSampler(0, background);
    
    // Draw with shader
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

## Troubleshooting

### Common Issues

#### 1. Shader Compilation Errors
```
Error: Failed to compile shader
```
**Solution**: Check GLSL syntax and ensure compatibility with Flutter's limitations.

#### 2. Missing Uniforms
```
Error: Uniform not set
```
**Solution**: Ensure all uniforms are set in the correct order using `setFloat()` and `setImageSampler()`.

#### 3. Texture Not Found
```
Error: Cannot read properties of null (reading 'Sd')
```
**Solution**: Ensure texture is properly captured and set before using the shader.

#### 4. Performance Issues
**Symptoms**: Low frame rate, stuttering
**Solutions**:
- Precache shaders before animations
- Reuse FragmentShader instances
- Optimize shader code
- Reduce uniform updates

### Debug Tips

#### 1. Add Debug Logs
```dart
void _initializeShader() async {
  debugPrint('🔍 Loading shader...');
  try {
    final program = await ui.FragmentProgram.fromAsset('shaders/my_shader.frag');
    debugPrint('✅ Shader loaded successfully');
    _shader = program.fragmentShader();
    debugPrint('✅ Fragment shader created');
  } catch (e) {
    debugPrint('❌ Shader loading failed: $e');
  }
}
```

#### 2. Validate Uniforms
```dart
void _setUniforms(ui.FragmentShader shader, Size size) {
  debugPrint('🔍 Setting uniforms...');
  debugPrint('Resolution: ${size.width}x${size.height}');
  
  shader.setFloat(0, size.width);
  shader.setFloat(1, size.height);
  // ... other uniforms
  
  debugPrint('✅ Uniforms set successfully');
}
```

#### 3. Test Simple Shaders First
Start with basic shaders that don't require textures:
```glsl
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution.xy;
    fragColor = vec4(uv.x, uv.y, 0.5, 1.0);
}
```

## Resources

### Official Documentation
- [Flutter Shader Documentation](https://docs.flutter.dev/ui/effects/shaders)
- [Writing Efficient Shaders](https://github.com/flutter/flutter/wiki/Writing-efficient-shaders)

### Learning Resources
- [The Book of Shaders](https://thebookofshaders.com/) - Interactive guide to fragment shaders
- [Shader Toy](https://www.shadertoy.com/) - Online shader playground and community
- [Practical Fragment Shaders in Flutter Guide](https://droids-on-roids.com/blog/practical-fragment-shaders-in-flutter-guide-introduction/) - Comprehensive Flutter shader tutorial series

### Flutter-Specific Resources
- [Flutter Animations with Fragment Shaders](https://medium.com/@sivaramss/flutter-animations-with-fragment-shaders-8b4b4b4b4b4b) - Medium article on shader animations
- [Flutter Shaders Package](https://pub.dev/packages/flutter_shaders) - Package for easier shader management
- [Flutter GPU Package](https://pub.dev/packages/flutter_gpu) - Official Flutter GPU package

### Example Projects
- [Simple Shader Sample](https://github.com/flutter/samples/tree/main/simple_shader)
- [Flutter Shaders Package Examples](https://pub.dev/packages/flutter_shaders/example)
- [Flutter Shader Guide Repository](https://github.com/SivaramSS/flutter_shader_guide) - Complete snowfall shader example

### Advanced Topics
- [Generative Art with Shaders](https://droids-on-roids.com/blog/practical-fragment-shaders-in-flutter-guide-generative-art-part-1/) - Creating procedural art
- [Shading Widgets](https://droids-on-roids.com/blog/practical-fragment-shaders-in-flutter-guide-shading-widgets/) - Applying shaders to Flutter widgets
- [Improving Blurhash](https://droids-on-roids.com/blog/practical-fragment-shaders-in-flutter-guide-improving-blurhash/) - Performance optimization techniques

---

This guide provides comprehensive information for implementing custom fragment shaders in Flutter, with specific focus on liquid glass effects. Use this as a reference when developing shader-based visual effects in your Flutter applications.
