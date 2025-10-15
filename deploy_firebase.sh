#!/bin/bash

# 🚀 Firebase Deployment Script with WASM
# This script builds your Flutter web app with WebAssembly and deploys to Firebase Hosting

echo "🚀 Firebase Deployment with WASM"
echo ""

# Step 1: Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get
echo ""

# Step 2: Build with WASM optimization
echo "⚡ Building with WASM optimization..."
flutter build web \
  --wasm \
  --release \
  --base-href "/"

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "✅ Build complete!"
echo ""

# Step 3: Deploy to Firebase
echo "🔥 Deploying to Firebase Hosting..."
firebase deploy --only hosting

if [ $? -ne 0 ]; then
    echo "❌ Deployment failed!"
    exit 1
fi

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Your portfolio is now live on Firebase Hosting!"
echo "📊 Performance: WASM-optimized for 2-3x speed boost"
echo ""

