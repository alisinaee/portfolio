# Liquid Glass Flutter Package

A Flutter package that creates a stunning liquid glass lens effect using custom fragment shaders. This package captures background content and applies a realistic magnifying glass distortion effect with chromatic dispersion.

## 🌟 Features

- **Real-time Background Capture**: Captures any widget's background content dynamically
- **Liquid Glass Lens Effect**: Creates a realistic magnifying glass distortion
- **Chromatic Dispersion**: Advanced shader effects with RGB color separation
- **Draggable Interface**: Interactive lens that can be moved around the screen
- **Custom Shader Support**: Extensible shader system for custom effects
- **Performance Optimized**: Efficient rendering with minimal impact on performance

## 📦 Package Structure

```
liquid_glass/
├── lib/
│   ├── main.dart                    # Demo application
│   ├── base_shader.dart            # Base shader class
│   ├── liquid_glass_lens_shader.dart # Liquid glass shader implementation
│   ├── background_capture_widget.dart # Background capture widget
│   └── shader_painter.dart         # Custom painter for shader rendering
├── shaders/
│   └── liquid_glass_lens.frag     # Fragment shader source
├── assets/
│   └── images/                     # Sample images for demo
└── pubspec.yaml                   # Package configuration
```

## 🚀 Quick Start

### 1. Basic Usage

```dart
import 'package:liquid_glass/liquid_glass_lens_shader.dart';
import 'package:liquid_glass/background_capture_widget.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey backgroundKey = GlobalKey();
  late LiquidGlassLensShader liquidGlassLensShader = LiquidGlassLensShader()
    ..initialize();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your background content
          RepaintBoundary(
            key: backgroundKey,
            child: YourBackgroundWidget(),
          ),
          // Liquid glass lens
          BackgroundCaptureWidget(
            width: 160,
            height: 160,
            initialPosition: Offset(100, 100),
            backgroundKey: backgroundKey,
            shader: liquidGlassLensShader,
            child: YourLensContent(),
          ),
        ],
      ),
    );
  }
}
```

### 2. Advanced Configuration

```dart
BackgroundCaptureWidget(
  width: 200,                    // Lens width
  height: 200,                   // Lens height
  initialPosition: Offset(50, 50), // Initial position
  backgroundKey: backgroundKey,   // Key to background widget
  shader: liquidGlassLensShader,  // Shader instance
  captureInterval: Duration(milliseconds: 16), // Capture frequency
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(100),
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Icon(Icons.search, size: 40),
  ),
)
```

## 🎨 Shader Effects

### Liquid Glass Lens Shader

The `LiquidGlassLensShader` creates a realistic magnifying glass effect with:

- **Distortion**: Curved lens distortion effect
- **Chromatic Dispersion**: RGB color separation for realistic glass effect
- **Blur Control**: Adjustable blur intensity
- **Size Control**: Configurable lens size
- **Edge Effects**: Realistic glass edge rendering

### Shader Parameters

| Parameter | Type | Description | Range |
|-----------|------|-------------|-------|
| `uResolution` | vec2 | Screen resolution | Auto |
| `uMouse` | vec2 | Mouse/center position | Auto |
| `uEffectSize` | float | Lens size multiplier | 0.1 - 2.0 |
| `uBlurIntensity` | float | Blur strength | 0.0 - 2.0 |
| `uDispersionStrength` | float | Chromatic dispersion | 0.0 - 1.0 |

## 🔧 API Reference

### BackgroundCaptureWidget

The main widget that handles background capture and shader rendering.

#### Constructor Parameters

```dart
BackgroundCaptureWidget({
  required Widget child,           // Content to display in lens
  required double width,          // Lens width
  required double height,         // Lens height
  required BaseShader shader,     // Shader instance
  Offset? initialPosition,        // Initial lens position
  Duration? captureInterval,      // Background capture frequency
  GlobalKey? backgroundKey,       // Key to background widget
})
```

#### Key Methods

- `_captureBackground()`: Captures background content
- `_startContinuousCapture()`: Starts periodic background capture
- `build()`: Renders the draggable lens widget

### LiquidGlassLensShader

Extends `BaseShader` to implement the liquid glass effect.

#### Key Methods

```dart
void updateShaderUniforms({
  required double width,
  required double height,
  required ui.Image? backgroundImage,
})
```

#### Shader Uniforms

- **Resolution** (indices 0-1): Screen dimensions
- **Mouse Position** (indices 2-3): Lens center position
- **Effect Size** (index 4): Lens size multiplier (default: 5.0)
- **Blur Intensity** (index 5): Blur strength (default: 0.0)
- **Dispersion Strength** (index 6): Chromatic dispersion (default: 0.4)
- **Background Texture** (sampler 0): Captured background image

### BaseShader

Abstract base class for custom shaders.

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

## 🎯 Use Cases

### 1. Magnifying Glass Apps
- Document readers with zoom functionality
- Image viewers with detail inspection
- Map applications with location magnification

### 2. Interactive UI Elements
- Search interfaces with live preview
- Product catalogs with detail views
- Educational apps with interactive exploration

### 3. Creative Applications
- Photo editing tools
- Art creation apps
- Interactive storytelling

## ⚡ Performance Considerations

### Optimization Tips

1. **Capture Frequency**: Adjust `captureInterval` based on your needs
   - High frequency (8-16ms): Smooth but CPU intensive
   - Low frequency (50-100ms): Efficient but less smooth

2. **Widget Size**: Smaller lenses perform better
   - Recommended: 100-200px for optimal performance
   - Large lenses (>300px) may impact performance

3. **Background Complexity**: Simple backgrounds render faster
   - Avoid complex nested widgets in background
   - Use `RepaintBoundary` to isolate background content

### Memory Management

- Background images are automatically disposed when widget is destroyed
- Shader resources are managed by Flutter's rendering system
- Consider disposing shaders manually for large applications

## 🛠️ Customization

### Creating Custom Shaders

1. **Extend BaseShader**:
```dart
class MyCustomShader extends BaseShader {
  MyCustomShader() : super(shaderAssetPath: 'shaders/my_effect.frag');
  
  @override
  void updateShaderUniforms({
    required double width,
    required double height,
    required ui.Image? backgroundImage,
  }) {
    // Set your custom uniforms
    shader.setFloat(0, width);
    shader.setFloat(1, height);
    // ... more uniforms
  }
}
```

2. **Create Fragment Shader**:
```glsl
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform sampler2D uTexture;
out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord() / uResolution.xy;
    fragColor = texture(uTexture, uv);
}
```

### Shader Development Tips

- Use `#include <flutter/runtime_effect.glsl>` for Flutter compatibility
- Test shaders on different devices for performance
- Use `debugPrint()` for shader debugging
- Handle shader loading errors gracefully

## 🐛 Troubleshooting

### Common Issues

1. **Shader Not Loading**
   - Check shader file path in `pubspec.yaml`
   - Verify shader syntax with GLSL validator
   - Ensure shader is in `shaders/` directory

2. **Performance Issues**
   - Reduce capture frequency
   - Decrease lens size
   - Simplify background content
   - Use `RepaintBoundary` for background

3. **Background Not Capturing**
   - Ensure `backgroundKey` is set correctly
   - Check that background widget is rendered
   - Verify `RepaintBoundary` is used

4. **Shader Compilation Errors**
   - Check GLSL syntax
   - Verify uniform declarations
   - Test on target platform

### Debug Mode

Enable debug logging:
```dart
// Add to your main.dart
import 'dart:developer' as developer;

void main() {
  developer.log('Liquid Glass Debug Mode', name: 'LiquidGlass');
  runApp(MyApp());
}
```

## 📱 Platform Support

- ✅ **Android**: Full support with OpenGL ES
- ✅ **iOS**: Full support with Metal/OpenGL ES
- ✅ **Web**: Full support with WebGL
- ✅ **Windows**: Full support with DirectX/OpenGL
- ✅ **macOS**: Full support with Metal/OpenGL
- ✅ **Linux**: Full support with OpenGL

## 🔄 Version History

### v1.0.0+1
- Initial release
- Basic liquid glass lens effect
- Background capture functionality
- Draggable interface
- Chromatic dispersion effects

## 📄 License

This package is provided as-is for educational and development purposes. Please check the original repository for licensing information.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and enhancement requests.

## 📞 Support

For questions and support:
- Create an issue in the repository
- Check the troubleshooting section
- Review the API documentation

---

**Note**: This package requires Flutter 3.6.2+ and uses custom fragment shaders. Ensure your target platform supports the required graphics APIs.
