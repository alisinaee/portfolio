# Liquid Glass Examples

## Basic Examples

### 1. Simple Magnifying Glass

```dart
import 'package:flutter/material.dart';
import 'package:liquid_glass/liquid_glass_lens_shader.dart';
import 'package:liquid_glass/background_capture_widget.dart';

class SimpleMagnifyingGlass extends StatefulWidget {
  @override
  _SimpleMagnifyingGlassState createState() => _SimpleMagnifyingGlassState();
}

class _SimpleMagnifyingGlassState extends State<SimpleMagnifyingGlass> {
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
          // Background content
          RepaintBoundary(
            key: backgroundKey,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  'Magnify this text!',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ),
          // Magnifying glass
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
          ),
        ],
      ),
    );
  }
}
```

### 2. Image Viewer with Zoom

```dart
class ImageViewerWithZoom extends StatefulWidget {
  final String imagePath;
  
  const ImageViewerWithZoom({Key? key, required this.imagePath}) : super(key: key);

  @override
  _ImageViewerWithZoomState createState() => _ImageViewerWithZoomState();
}

class _ImageViewerWithZoomState extends State<ImageViewerWithZoom> {
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
      appBar: AppBar(title: Text('Image Viewer')),
      body: Stack(
        children: [
          // Image background
          RepaintBoundary(
            key: backgroundKey,
            child: InteractiveViewer(
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          // Zoom lens
          BackgroundCaptureWidget(
            width: 150,
            height: 150,
            initialPosition: Offset(50, 50),
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
          ),
        ],
      ),
    );
  }
}
```

## Advanced Examples

### 3. Multi-Lens System

```dart
class MultiLensSystem extends StatefulWidget {
  @override
  _MultiLensSystemState createState() => _MultiLensSystemState();
}

class _MultiLensSystemState extends State<MultiLensSystem> {
  final GlobalKey backgroundKey = GlobalKey();
  late List<LiquidGlassLensShader> shaders;
  late List<Offset> lensPositions;

  @override
  void initState() {
    super.initState();
    shaders = List.generate(3, (index) => LiquidGlassLensShader()..initialize());
    lensPositions = [
      Offset(100, 100),
      Offset(200, 200),
      Offset(150, 300),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          RepaintBoundary(
            key: backgroundKey,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.orange, Colors.red, Colors.purple],
                ),
              ),
              child: Center(
                child: Text(
                  'Multiple Lenses',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
          ),
          // Multiple lenses
          ...List.generate(3, (index) {
            return BackgroundCaptureWidget(
              width: 100,
              height: 100,
              initialPosition: lensPositions[index],
              backgroundKey: backgroundKey,
              shader: shaders[index],
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
```

### 4. Interactive Product Viewer

```dart
class ProductViewer extends StatefulWidget {
  final List<String> productImages;
  
  const ProductViewer({Key? key, required this.productImages}) : super(key: key);

  @override
  _ProductViewerState createState() => _ProductViewerState();
}

class _ProductViewerState extends State<ProductViewer> {
  final GlobalKey backgroundKey = GlobalKey();
  late LiquidGlassLensShader shader;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    shader = LiquidGlassLensShader()..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                currentImageIndex = (currentImageIndex + 1) % widget.productImages.length;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Product image
          RepaintBoundary(
            key: backgroundKey,
            child: Image.asset(
              widget.productImages[currentImageIndex],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Magnifying lens
          BackgroundCaptureWidget(
            width: 180,
            height: 180,
            initialPosition: Offset(100, 100),
            backgroundKey: backgroundKey,
            shader: shader,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
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
          ),
          // Instructions
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Drag the lens to explore product details',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Custom Shader Examples

### 5. Custom Blur Shader

```dart
class CustomBlurShader extends BaseShader {
  CustomBlurShader() : super(shaderAssetPath: 'shaders/custom_blur.frag');
  
  @override
  void updateShaderUniforms({
    required double width,
    required double height,
    required ui.Image? backgroundImage,
  }) {
    if (!isLoaded) return;
    
    shader.setFloat(0, width);
    shader.setFloat(1, height);
    shader.setFloat(2, 0.8); // Blur intensity
    
    if (backgroundImage != null) {
      shader.setImageSampler(0, backgroundImage);
    }
  }
}

// Usage
class BlurEffectDemo extends StatefulWidget {
  @override
  _BlurEffectDemoState createState() => _BlurEffectDemoState();
}

class _BlurEffectDemoState extends State<BlurEffectDemo> {
  final GlobalKey backgroundKey = GlobalKey();
  late CustomBlurShader shader;

  @override
  void initState() {
    super.initState();
    shader = CustomBlurShader()..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: backgroundKey,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green, Colors.red],
                ),
              ),
              child: Center(
                child: Text(
                  'Blur Effect',
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
            ),
          ),
          BackgroundCaptureWidget(
            width: 200,
            height: 200,
            initialPosition: Offset(100, 100),
            backgroundKey: backgroundKey,
            shader: shader,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 6. Animated Lens Effect

```dart
class AnimatedLensDemo extends StatefulWidget {
  @override
  _AnimatedLensDemoState createState() => _AnimatedLensDemoState();
}

class _AnimatedLensDemoState extends State<AnimatedLensDemo>
    with TickerProviderStateMixin {
  final GlobalKey backgroundKey = GlobalKey();
  late LiquidGlassLensShader shader;
  late AnimationController animationController;
  late Animation<double> sizeAnimation;

  @override
  void initState() {
    super.initState();
    shader = LiquidGlassLensShader()..initialize();
    
    animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    sizeAnimation = Tween<double>(
      begin: 100.0,
      end: 200.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
    
    animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: backgroundKey,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.purple, Colors.blue, Colors.cyan],
                ),
              ),
              child: Center(
                child: Text(
                  'Animated Lens',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: sizeAnimation,
            builder: (context, child) {
              return BackgroundCaptureWidget(
                width: sizeAnimation.value,
                height: sizeAnimation.value,
                initialPosition: Offset(150, 150),
                backgroundKey: backgroundKey,
                shader: shader,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: sizeAnimation.value * 0.3,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## Performance Examples

### 7. Optimized High-Performance Lens

```dart
class OptimizedLensDemo extends StatefulWidget {
  @override
  _OptimizedLensDemoState createState() => _OptimizedLensDemoState();
}

class _OptimizedLensDemoState extends State<OptimizedLensDemo> {
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
          // Optimized background with RepaintBoundary
          RepaintBoundary(
            key: backgroundKey,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.pink],
                ),
              ),
              child: Center(
                child: Text(
                  'Optimized Performance',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ),
          // Optimized lens with reduced capture frequency
          BackgroundCaptureWidget(
            width: 120, // Smaller size for better performance
            height: 120,
            initialPosition: Offset(100, 100),
            backgroundKey: backgroundKey,
            shader: shader,
            captureInterval: Duration(milliseconds: 33), // 30 FPS
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Integration Examples

### 8. Integration with Existing App

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App with Liquid Glass',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey backgroundKey = GlobalKey();
  late LiquidGlassLensShader shader;
  bool showLens = false;

  @override
  void initState() {
    super.initState();
    shader = LiquidGlassLensShader()..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        actions: [
          IconButton(
            icon: Icon(showLens ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                showLens = !showLens;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Your existing app content
          RepaintBoundary(
            key: backgroundKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 200,
                    color: Colors.blue,
                    child: Center(
                      child: Text('Section 1', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  Container(
                    height: 200,
                    color: Colors.green,
                    child: Center(
                      child: Text('Section 2', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  Container(
                    height: 200,
                    color: Colors.red,
                    child: Center(
                      child: Text('Section 3', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Conditional lens
          if (showLens)
            BackgroundCaptureWidget(
              width: 150,
              height: 150,
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
            ),
        ],
      ),
    );
  }
}
```

## Testing Examples

### 9. Test Widget for Development

```dart
class LiquidGlassTestWidget extends StatefulWidget {
  @override
  _LiquidGlassTestWidgetState createState() => _LiquidGlassTestWidgetState();
}

class _LiquidGlassTestWidgetState extends State<LiquidGlassTestWidget> {
  final GlobalKey backgroundKey = GlobalKey();
  late LiquidGlassLensShader shader;
  double lensSize = 150.0;
  double blurIntensity = 0.0;
  double dispersionStrength = 0.4;

  @override
  void initState() {
    super.initState();
    shader = LiquidGlassLensShader()..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liquid Glass Test')),
      body: Column(
        children: [
          // Controls
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Lens Size: ${lensSize.toInt()}'),
                Slider(
                  value: lensSize,
                  min: 50,
                  max: 300,
                  onChanged: (value) => setState(() => lensSize = value),
                ),
                Text('Blur Intensity: ${blurIntensity.toStringAsFixed(1)}'),
                Slider(
                  value: blurIntensity,
                  min: 0,
                  max: 2,
                  onChanged: (value) => setState(() => blurIntensity = value),
                ),
                Text('Dispersion: ${dispersionStrength.toStringAsFixed(1)}'),
                Slider(
                  value: dispersionStrength,
                  min: 0,
                  max: 1,
                  onChanged: (value) => setState(() => dispersionStrength = value),
                ),
              ],
            ),
          ),
          // Test area
          Expanded(
            child: Stack(
              children: [
                RepaintBoundary(
                  key: backgroundKey,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.blue, Colors.green],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Test Area\nDrag the lens around',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                BackgroundCaptureWidget(
                  width: lensSize,
                  height: lensSize,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

These examples demonstrate various ways to use the Liquid Glass package, from simple implementations to advanced customizations. Choose the example that best fits your use case and modify it according to your needs.
