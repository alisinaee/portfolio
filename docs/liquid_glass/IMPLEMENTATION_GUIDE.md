# Liquid Glass Implementation Guide

## 🚀 Quick Start

### 1. Basic Setup

```dart
import 'package:liquid_glass/liquid_glass_lens_shader.dart';
import 'package:liquid_glass/background_capture_widget.dart';

class MyLiquidGlassDemo extends StatefulWidget {
  @override
  _MyLiquidGlassDemoState createState() => _MyLiquidGlassDemoState();
}

class _MyLiquidGlassDemoState extends State<MyLiquidGlassDemo> {
  final GlobalKey _backgroundKey = GlobalKey();
  late LiquidGlassLensShader _shader;

  @override
  void initState() {
    super.initState();
    _shader = LiquidGlassLensShader()..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background content
          RepaintBoundary(
            key: _backgroundKey,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
              ),
              child: Center(
                child: Text(
                  'Drag the lens to explore!',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ),
          // Liquid glass lens
          BackgroundCaptureWidget(
            width: 160,
            height: 160,
            initialPosition: Offset(100, 100),
            backgroundKey: _backgroundKey,
            shader: _shader,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.search, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. Project Configuration

#### pubspec.yaml
```yaml
dependencies:
  liquid_glass:
    path: liquid_glass

flutter:
  shaders:
    - assets/shaders/liquid_glass_lens.frag
```

#### Copy Shader File
```bash
mkdir -p assets/shaders
cp liquid_glass/shaders/liquid_glass_lens.frag assets/shaders/
```

## 🎯 Common Patterns

### Pattern 1: Simple Magnifying Glass
```dart
BackgroundCaptureWidget(
  width: 120,
  height: 120,
  initialPosition: Offset(100, 100),
  backgroundKey: backgroundKey,
  shader: shader,
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Icon(Icons.search, color: Colors.white, size: 30),
  ),
)
```

### Pattern 2: Image Viewer with Zoom
```dart
BackgroundCaptureWidget(
  width: 180,
  height: 180,
  initialPosition: Offset(100, 100),
  backgroundKey: backgroundKey,
  shader: shader,
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Icon(Icons.zoom_in, color: Colors.white, size: 40),
  ),
)
```

### Pattern 3: Multiple Lenses
```dart
// Create multiple shader instances
List<LiquidGlassLensShader> shaders = List.generate(3, (index) => 
  LiquidGlassLensShader()..initialize()
);

// Use in Stack
...List.generate(3, (index) {
  return BackgroundCaptureWidget(
    width: 100,
    height: 100,
    initialPosition: positions[index],
    backgroundKey: backgroundKey,
    shader: shaders[index],
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.white, width: 2),
      ),
    ),
  );
})
```

## ⚡ Performance Optimization

### 1. Optimize Capture Frequency
```dart
BackgroundCaptureWidget(
  // High performance: 33ms (30 FPS)
  captureInterval: Duration(milliseconds: 33),
  
  // Balanced: 16ms (60 FPS)
  captureInterval: Duration(milliseconds: 16),
  
  // Maximum smoothness: 8ms (120 FPS)
  captureInterval: Duration(milliseconds: 8),
)
```

### 2. Optimize Lens Size
```dart
// Small lens for better performance
BackgroundCaptureWidget(
  width: 100,   // Good performance
  height: 100,
)

// Medium lens for balanced performance
BackgroundCaptureWidget(
  width: 160,   // Balanced
  height: 160,
)

// Large lens for maximum effect
BackgroundCaptureWidget(
  width: 250,   // May impact performance
  height: 250,
)
```

### 3. Optimize Background
```dart
// Use RepaintBoundary for complex backgrounds
RepaintBoundary(
  key: backgroundKey,
  child: ComplexBackgroundWidget(),
)

// Simple backgrounds perform better
RepaintBoundary(
  key: backgroundKey,
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
    ),
  ),
)
```

## 🐛 Troubleshooting

### Issue 1: Shader Not Loading
```dart
// Check shader loading status
if (!shader.isLoaded) {
  debugPrint('Shader not loaded yet');
  return Container(child: Text('Loading...'));
}
```

### Issue 2: Background Not Capturing
```dart
// Validate background key
final boundary = backgroundKey?.currentContext?.findRenderObject()
    as RenderRepaintBoundary?;
if (boundary == null || !boundary.attached) {
  debugPrint('Background boundary not available');
  return;
}
```

### Issue 3: Performance Issues
```dart
// Monitor capture performance
void _captureBackground() async {
  final stopwatch = Stopwatch()..start();
  
  // ... capture logic ...
  
  stopwatch.stop();
  if (stopwatch.elapsedMilliseconds > 16) {
    debugPrint('Slow capture: ${stopwatch.elapsedMilliseconds}ms');
  }
}
```

## 🎨 Customization

### Custom Shader Parameters
```dart
class CustomLensShader extends LiquidGlassLensShader {
  @override
  void updateShaderUniforms({
    required double width,
    required double height,
    required ui.Image? backgroundImage,
  }) {
    super.updateShaderUniforms(
      width: width,
      height: height,
      backgroundImage: backgroundImage,
    );
    
    // Custom parameters
    shader.setFloat(4, 3.0); // Effect size
    shader.setFloat(5, 0.5);  // Blur intensity
    shader.setFloat(6, 0.6);  // Dispersion strength
  }
}
```

### Custom Lens Appearance
```dart
BackgroundCaptureWidget(
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [Colors.white, Colors.transparent],
      ),
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 15,
          spreadRadius: 3,
        ),
      ],
    ),
    child: Center(
      child: Text(
        'ZOOM',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
)
```

## 📱 Platform Considerations

### Web
- Requires WebGL support
- May have performance limitations
- Test on different browsers

### Mobile
- iOS: Metal/OpenGL ES support
- Android: OpenGL ES support
- Consider device capabilities

### Desktop
- Windows: DirectX/OpenGL support
- macOS: Metal/OpenGL support
- Linux: OpenGL support

## 🔧 Advanced Usage

### Animated Lens
```dart
class AnimatedLensDemo extends StatefulWidget {
  @override
  _AnimatedLensDemoState createState() => _AnimatedLensDemoState();
}

class _AnimatedLensDemoState extends State<AnimatedLensDemo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _sizeAnimation = Tween<double>(begin: 100.0, end: 200.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sizeAnimation,
      builder: (context, child) {
        return BackgroundCaptureWidget(
          width: _sizeAnimation.value,
          height: _sizeAnimation.value,
          // ... other properties
        );
      },
    );
  }
}
```

### Conditional Lens
```dart
class ConditionalLensDemo extends StatefulWidget {
  @override
  _ConditionalLensDemoState createState() => _ConditionalLensDemoState();
}

class _ConditionalLensDemoState extends State<ConditionalLensDemo> {
  bool _showLens = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background content
        RepaintBoundary(
          key: backgroundKey,
          child: YourBackgroundWidget(),
        ),
        // Conditional lens
        if (_showLens)
          BackgroundCaptureWidget(
            // ... lens properties
          ),
        // Toggle button
        Positioned(
          top: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => setState(() => _showLens = !_showLens),
            child: Icon(_showLens ? Icons.visibility_off : Icons.visibility),
          ),
        ),
      ],
    );
  }
}
```

This implementation guide provides everything needed to successfully integrate and use the liquid glass effect in your Flutter application.

