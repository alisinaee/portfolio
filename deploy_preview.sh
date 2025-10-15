#!/bin/bash

# 🔍 Firebase Preview Deployment Script
# Deploy to a preview channel to test before going live

echo "🔍 Firebase Preview Deployment"
echo ""

# Step 1: Clean and get dependencies
echo "🧹 Preparing..."
flutter clean
flutter pub get
echo ""

# Step 2: Build with WASM
echo "⚡ Building with WASM..."
flutter build web \
  --wasm \
  --release \
  --web-renderer canvaskit \
  --base-href "/"

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "✅ Build complete!"
echo ""

# Step 3: Deploy to preview channel
echo "🔥 Deploying to preview channel..."
firebase hosting:channel:deploy preview --expires 7d

if [ $? -ne 0 ]; then
    echo "❌ Preview deployment failed!"
    exit 1
fi

echo ""
echo "✅ Preview deployment complete!"
echo "🔗 Check the preview URL above to test your site"
echo "⏰ Preview expires in 7 days"
echo ""

