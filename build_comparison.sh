#!/bin/bash

# 📊 Build Comparison Script
# Builds both JS and WASM versions to compare performance

echo "📊 Building Both JS and WASM for Comparison..."
echo ""

# Clean first
echo "🧹 Cleaning..."
flutter clean
flutter pub get
echo ""

# Build JS version
echo "1️⃣ Building JavaScript version..."
flutter build web \
  --release \
  --web-renderer canvaskit \
  --base-href "/" \
  -o build/web-js

echo ""
echo "✅ JavaScript build complete!"
echo ""

# Build WASM version
echo "2️⃣ Building WASM version..."
flutter build web \
  --wasm \
  --release \
  --web-renderer canvaskit \
  --base-href "/" \
  -o build/web-wasm

echo ""
echo "✅ WASM build complete!"
echo ""
echo "📊 Comparison Results:"
echo ""
echo "JavaScript build:"
du -sh build/web-js
echo ""
echo "WASM build:"
du -sh build/web-wasm
echo ""
echo "🌐 To test:"
echo "   JS:   cd build/web-js && python3 -m http.server 8000"
echo "   WASM: cd build/web-wasm && python3 -m http.server 9000"
echo ""

