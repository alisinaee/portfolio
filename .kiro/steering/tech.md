# Technology Stack

## Framework & Language

- **Flutter** 3.22.0+ (Web, Mobile, Desktop)
- **Dart** 3.9.2+
- **WebAssembly (WASM)** for production builds

## Key Dependencies

- `provider: ^6.1.1` - State management
- `flutter_svg: ^2.0.9` - SVG icon rendering
- `firebase_core: ^3.6.0` - Firebase integration
- `firebase_analytics: ^11.3.3` - Analytics tracking

## Build System

### Development
```bash
flutter run -d chrome
```

### Production Build (WASM)
```bash
./build_wasm.sh
# Or manually:
flutter build web --wasm --release --base-href "/"
```

### Deployment
```bash
./deploy_preview.sh    # Preview channel
./deploy_firebase.sh   # Production
```

### Testing
```bash
flutter test
flutter analyze
```

### Local Testing of Production Build
```bash
cd build/web
python3 -m http.server 8000
# Open http://localhost:8000
```

## Performance Tools

- **PerformanceLogger** - Custom frame timing and animation tracking
- **MemoryManager** - Periodic cleanup to prevent leaks
- **PerformanceMonitor** - Optional FPS overlay widget
- Frame timing callbacks for slow frame detection

## Shader Compilation

Custom GLSL shaders in `shaders/` directory:
- Compiled at build time by Flutter
- Loaded via `ShaderManager` singleton
- Used for liquid glass effects

## Browser Compatibility

Best: Chrome/Edge (full WASM support)
Good: Firefox
Limited: Safari (partial WASM support)
