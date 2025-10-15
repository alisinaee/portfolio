# Liquid Glass API Reference

## Classes

### BackgroundCaptureWidget

A widget that captures background content and applies shader effects to create a liquid glass lens.

#### Constructor

```dart
const BackgroundCaptureWidget({
  required Widget child,
  required double width,
  required double height,
  required BaseShader shader,
  Offset? initialPosition,
  Duration? captureInterval,
  GlobalKey? backgroundKey,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `child` | `Widget` | Content to display inside the lens |
| `width` | `double` | Width of the lens in logical pixels |
| `height` | `double` | Height of the lens in logical pixels |
| `shader` | `BaseShader` | Shader instance to apply effects |
| `initialPosition` | `Offset?` | Initial position of the lens |
| `captureInterval` | `Duration?` | How often to capture background (default: 8ms) |
| `backgroundKey` | `GlobalKey?` | Key to the background widget to capture |

#### Methods

##### `_captureBackground()`
```dart
Future<void> _captureBackground()
```
Captures the background content behind the lens and updates the shader.

##### `_startContinuousCapture()`
```dart
void _startContinuousCapture()
```
Starts the periodic background capture timer.

---

### LiquidGlassLensShader

A shader that creates a liquid glass lens effect with chromatic dispersion.

#### Constructor

```dart
LiquidGlassLensShader()
```

#### Methods

##### `updateShaderUniforms()`
```dart
void updateShaderUniforms({
  required double width,
  required double height,
  required ui.Image? backgroundImage,
})
```

Sets the shader uniforms for the liquid glass effect.

**Parameters:**
- `width`: Width of the lens in pixels
- `height`: Height of the lens in pixels  
- `backgroundImage`: Captured background image

**Shader Uniforms:**
- Index 0-1: Resolution (width, height)
- Index 2-3: Mouse position (center x, center y)
- Index 4: Effect size (default: 5.0)
- Index 5: Blur intensity (default: 0.0)
- Index 6: Dispersion strength (default: 0.4)
- Sampler 0: Background texture

---

### BaseShader

Abstract base class for custom shaders.

#### Constructor

```dart
BaseShader({
  required String shaderAssetPath,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `shaderAssetPath` | `String` | Path to the fragment shader file |
| `isLoaded` | `bool` | Whether the shader is loaded and ready |
| `shader` | `ui.FragmentShader` | The loaded fragment shader |

#### Methods

##### `initialize()`
```dart
Future<void> initialize()
```
Loads the fragment shader from the asset path.

##### `updateShaderUniforms()`
```dart
void updateShaderUniforms({
  required double width,
  required double height,
  required ui.Image? backgroundImage,
})
```
Abstract method to update shader uniforms. Must be implemented by subclasses.

---

### ShaderPainter

Custom painter that renders the shader effect.

#### Constructor

```dart
ShaderPainter(ui.FragmentShader shader)
```

#### Methods

##### `paint()`
```dart
void paint(Canvas canvas, Size size)
```
Paints the shader effect on the canvas.

##### `shouldRepaint()`
```dart
bool shouldRepaint(CustomPainter oldDelegate)
```
Returns true to always repaint when the shader changes.

---

## Fragment Shader Reference

### liquid_glass_lens.frag

The fragment shader that creates the liquid glass effect.

#### Uniforms

```glsl
uniform vec2 uResolution;        // Screen resolution
uniform vec2 uMouse;            // Mouse/center position
uniform float uEffectSize;      // Lens size (0.1-2.0)
uniform float uBlurIntensity;   // Blur strength (0.0-2.0)
uniform float uDispersionStrength; // Chromatic dispersion (0.0-1.0)
uniform sampler2D uTexture;    // Background texture
```

#### Key Features

1. **Rounded Box Effect**: Creates a lens-shaped distortion area
2. **Chromatic Dispersion**: Separates RGB channels for realistic glass effect
3. **Blur Sampling**: Optional blur effect with 5x5 sampling
4. **Edge Effects**: Realistic glass edge rendering with shadows
5. **Gradient Lighting**: Adds depth and realism to the lens

#### Shader Algorithm

1. **Distance Calculation**: Calculates distance from lens center
2. **Effect Masking**: Creates smooth falloff for lens boundaries
3. **Distortion**: Applies curved lens distortion to UV coordinates
4. **Chromatic Dispersion**: Offsets RGB channels by different amounts
5. **Blur Sampling**: Optional multi-sample blur for soft focus
6. **Lighting**: Adds gradient lighting effects for realism

---

## Usage Examples

### Basic Implementation

```dart
class MyLiquidGlassApp extends StatefulWidget {
  @override
  _MyLiquidGlassAppState createState() => _MyLiquidGlassAppState();
}

class _MyLiquidGlassAppState extends State<MyLiquidGlassApp> {
  final GlobalKey backgroundKey = GlobalKey();
  late LiquidGlassLensShader shader;

  @override
  void initState() {
    super.initState();
    shader = LiquidGlassLensShader()..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: backgroundKey,
            child: YourBackgroundWidget(),
          ),
          BackgroundCaptureWidget(
            width: 160,
            height: 160,
            initialPosition: Offset(100, 100),
            backgroundKey: backgroundKey,
            shader: shader,
            child: Icon(Icons.search, size: 40),
          ),
        ],
      ),
    );
  }
}
```

### Custom Shader Implementation

```dart
class MyCustomShader extends BaseShader {
  MyCustomShader() : super(shaderAssetPath: 'shaders/my_effect.frag');
  
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
    shader.setFloat(2, 0.5); // Custom parameter
    
    if (backgroundImage != null) {
      shader.setImageSampler(0, backgroundImage);
    }
  }
}
```

### Performance Optimization

```dart
BackgroundCaptureWidget(
  width: 120,  // Smaller size for better performance
  height: 120,
  captureInterval: Duration(milliseconds: 33), // 30 FPS capture
  backgroundKey: backgroundKey,
  shader: shader,
  child: YourContent(),
)
```

---

## Error Handling

### Common Exceptions

1. **Shader Loading Errors**
   ```dart
   try {
     await shader.initialize();
   } catch (e) {
     debugPrint('Shader loading failed: $e');
   }
   ```

2. **Background Capture Errors**
   ```dart
   // Handled automatically in BackgroundCaptureWidget
   // Check debug console for error messages
   ```

3. **Rendering Errors**
   ```dart
   // ShaderPainter handles rendering errors gracefully
   // Falls back to transparent rendering on error
   ```

### Debug Information

Enable debug logging:
```dart
import 'dart:developer' as developer;

// In your shader initialization
developer.log('Shader loaded successfully', name: 'LiquidGlass');
```

---

## Platform-Specific Notes

### Android
- Requires OpenGL ES 3.0+ for fragment shaders
- Performance may vary on older devices
- Test on different screen densities

### iOS
- Uses Metal or OpenGL ES depending on device
- Metal provides better performance on newer devices
- Consider fallback for older iOS versions

### Web
- Requires WebGL 2.0 support
- Performance depends on browser and device
- Test across different browsers

### Desktop (Windows/macOS/Linux)
- Uses platform-specific graphics APIs
- Generally good performance on modern hardware
- Consider GPU requirements for deployment
