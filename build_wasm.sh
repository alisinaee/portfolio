#!/bin/bash

# 🚀 Flutter WASM Build Script
# This script builds your Flutter web app with WebAssembly for maximum performance

echo "🚀 Building Flutter Web with WASM..."
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get
echo ""

# Build with WASM optimization
echo "⚡ Building with WASM optimization..."
flutter build web \
  --wasm \
  --release \
  --web-renderer canvaskit \
  --pwa-strategy offline-first \
  --base-href "/" \
  --dart-define=FLUTTER_WEB_USE_SKIA=true

echo ""
echo "✅ Build complete!"
echo ""
echo "📦 Output directory: build/web"
echo ""
echo "🌐 To test locally:"
echo "   cd build/web"
echo "   python3 -m http.server 8000"
echo "   Then open http://localhost:8000"
echo ""
echo "💡 Performance Tips:"
echo "   - WASM provides 2-3x better performance than JS"
echo "   - CanvasKit renderer is optimized for animations"
echo "   - PWA strategy enables offline support"
echo ""

