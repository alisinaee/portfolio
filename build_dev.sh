#!/bin/bash

# 🔧 Flutter Development Build Script
# Quick build for development and testing

echo "🔧 Building Flutter Web for Development..."
echo ""

# Build with profile mode for better debugging
echo "⚡ Building in profile mode..."
flutter build web \
  --profile \
  --web-renderer canvaskit \
  --source-maps \
  --base-href "/"

echo ""
echo "✅ Development build complete!"
echo ""
echo "📦 Output directory: build/web"
echo ""
echo "🌐 To test locally:"
echo "   cd build/web"
echo "   python3 -m http.server 8000"
echo "   Then open http://localhost:8000"
echo ""

