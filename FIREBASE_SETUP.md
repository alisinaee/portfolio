# 🔥 Firebase Hosting Setup Guide

Complete guide to deploy your optimized Flutter WASM portfolio to Firebase Hosting.

---

## 📋 Prerequisites

- ✅ Firebase CLI installed (already done!)
- ✅ Flutter project with WASM build scripts (already done!)
- ✅ Firebase account (you'll need to create one)

---

## 🚀 Quick Start

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `portfolio` (or any name you prefer)
4. Accept terms and click **"Continue"**
5. Disable Google Analytics (optional, you can enable later)
6. Click **"Create project"**
7. Wait for project creation, then click **"Continue"**

### Step 2: Enable Firebase Hosting

1. In Firebase Console, click **"Hosting"** in the left menu
2. Click **"Get started"**
3. Follow the wizard (you can skip steps - we've already configured it!)

### Step 3: Get Your Firebase Config

1. In Firebase Console, click the ⚙️ icon next to **"Project Overview"**
2. Click **"Project settings"**
3. Scroll down to **"Your apps"**
4. Click the **Web icon** (`</>`) to add a web app
5. Enter app nickname: `Portfolio Web`
6. **Check** "Also set up Firebase Hosting"
7. Click **"Register app"**

### Step 4: Copy Firebase Configuration

You'll see a code snippet like this:

```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123:web:abc123",
  measurementId: "G-ABC123"
};
```

### Step 5: Update Your Project Files

#### A. Update `.firebaserc`

Edit `.firebaserc` and replace `your-project-id` with your actual project ID:

```json
{
  "projects": {
    "default": "your-actual-project-id"
  }
}
```

#### B. Update `lib/firebase_options.dart`

Replace the `web` section with your actual config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',
  appId: 'YOUR_ACTUAL_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
  projectId: 'your-actual-project-id',
  authDomain: 'your-actual-project.firebaseapp.com',
  storageBucket: 'your-actual-project.appspot.com',
  measurementId: 'YOUR_ACTUAL_MEASUREMENT_ID',
);
```

### Step 6: Login to Firebase CLI

```bash
firebase login
```

This will open a browser for authentication.

### Step 7: Deploy Your Portfolio!

#### Option 1: Full Production Deployment

```bash
./deploy_firebase.sh
```

This script will:
- Clean previous builds
- Build with WASM optimization
- Deploy to Firebase Hosting
- Show you the live URL!

#### Option 2: Preview Deployment (Test First)

```bash
./deploy_preview.sh
```

This creates a temporary preview URL (expires in 7 days) to test before going live.

---

## 🎯 Deployment Commands

### Production Deployment

```bash
./deploy_firebase.sh
```

**What it does:**
- ✅ Cleans project
- ✅ Gets dependencies
- ✅ Builds with WASM
- ✅ Deploys to production
- ✅ Shows live URL

### Preview Deployment

```bash
./deploy_preview.sh
```

**What it does:**
- ✅ Creates temporary preview
- ✅ Expires in 7 days
- ✅ Perfect for testing
- ✅ Doesn't affect production

### Manual Commands

```bash
# Build only
flutter build web --wasm --release --web-renderer canvaskit

# Deploy only (after building)
firebase deploy --only hosting

# View hosting info
firebase hosting:sites:list

# See deployment history
firebase hosting:deployments:list
```

---

## 🌐 Your Live URLs

After deployment, you'll get URLs like:

### Production URL
```
https://your-project-id.web.app
https://your-project-id.firebaseapp.com
```

### Preview URL (if using preview deployment)
```
https://your-project-id--preview-abc123.web.app
```

---

## 🔧 Configuration Files

### `firebase.json`

This file is **already configured** with optimal settings for WASM:

- ✅ **Public directory**: `build/web`
- ✅ **WASM headers**: Correct Content-Type and CORS headers
- ✅ **SPA routing**: All routes redirect to index.html
- ✅ **Security headers**: Cross-Origin policies for WASM

### `.firebaserc`

Project configuration:
```json
{
  "projects": {
    "default": "your-project-id"  // Update this!
  }
}
```

---

## 📊 Performance Features

Your deployment includes:

### WASM Optimizations
- ✅ **2-3x faster** than JavaScript
- ✅ **CanvasKit renderer** for smooth animations
- ✅ **PWA support** for offline functionality
- ✅ **Optimized caching** for fast loads

### Firebase Features
- ✅ **Global CDN** - Fast worldwide
- ✅ **Free SSL** - Automatic HTTPS
- ✅ **Rollback support** - Easy to revert
- ✅ **Preview channels** - Test before deploy

---

## 🎨 Custom Domain (Optional)

### Add Your Own Domain

1. Go to Firebase Console → Hosting
2. Click **"Add custom domain"**
3. Enter your domain (e.g., `yourportfolio.com`)
4. Follow DNS setup instructions
5. Wait for SSL certificate (automatic, ~15 mins)

### DNS Configuration

Add these records to your domain:

```
Type: A
Name: @
Value: (Firebase provides this)

Type: A
Name: www
Value: (Firebase provides this)
```

---

## 🔍 Monitoring & Analytics

### View Deployment Stats

```bash
# List all deployments
firebase hosting:deployments:list

# View site info
firebase hosting:sites:list
```

### Firebase Console

Go to [Firebase Console](https://console.firebase.google.com/):

- **Hosting Dashboard**: View traffic, bandwidth
- **Analytics** (if enabled): User behavior
- **Performance** (if enabled): Real-time metrics

---

## 🐛 Troubleshooting

### Build Fails

**Issue**: `flutter build web --wasm` fails

**Solution**:
```bash
flutter clean
flutter pub get
flutter doctor
```

### Deployment Fails

**Issue**: `firebase deploy` fails

**Solution**:
```bash
# Re-login
firebase logout
firebase login

# Check project
firebase use --add

# Try again
firebase deploy --only hosting
```

### WASM Not Loading

**Issue**: Site loads but WASM doesn't work

**Check**:
1. Browser console for errors
2. Network tab - verify `.wasm` files load
3. CORS headers are set correctly (already configured!)
4. Use Chrome/Edge (best WASM support)

### Wrong Project

**Issue**: Deploying to wrong Firebase project

**Solution**:
```bash
# List available projects
firebase projects:list

# Switch project
firebase use your-project-id

# Or update .firebaserc manually
```

---

## 📱 Testing Checklist

Before deploying to production:

- [ ] Test preview deployment first
- [ ] Check all animations work
- [ ] Verify FPS overlay shows good performance
- [ ] Test on Chrome, Firefox, Safari
- [ ] Test on mobile devices
- [ ] Check all menu items navigate correctly
- [ ] Verify loading time is fast

---

## 🔄 Update Workflow

When you make changes:

```bash
# 1. Make your changes
# 2. Test locally
flutter run -d chrome

# 3. Deploy preview to test
./deploy_preview.sh

# 4. If good, deploy to production
./deploy_firebase.sh

# 5. Commit to Git
git add .
git commit -m "Update portfolio"
git push
```

---

## 📊 Performance Metrics

After deployment, check:

### Lighthouse Score
1. Open your site in Chrome
2. Open DevTools (F12)
3. Go to "Lighthouse" tab
4. Run audit

### Target Scores:
- **Performance**: 90+ (with WASM!)
- **Accessibility**: 95+
- **Best Practices**: 95+
- **SEO**: 90+

---

## 💡 Pro Tips

1. **Always test preview first** before production
2. **Use Git** to track all changes
3. **Enable Firebase Analytics** for visitor insights
4. **Set up custom domain** for professionalism
5. **Monitor performance** regularly
6. **Keep Firebase CLI updated**: `npm install -g firebase-tools`

---

## 🎯 Summary

Your Firebase setup includes:

✅ **Firebase Core** - Initialized in app  
✅ **Firebase Hosting** - Configured for WASM  
✅ **Deployment scripts** - One-command deploy  
✅ **Optimal headers** - WASM + CORS configured  
✅ **Preview support** - Test before live  
✅ **CDN delivery** - Fast worldwide  
✅ **SSL included** - Automatic HTTPS  

---

## 📞 Quick Commands Reference

```bash
# Deploy to production
./deploy_firebase.sh

# Deploy preview (7-day expiry)
./deploy_preview.sh

# Login to Firebase
firebase login

# Check current project
firebase use

# List all projects
firebase projects:list

# View deployments
firebase hosting:deployments:list

# Open hosting console
firebase open hosting
```

---

## 🎉 You're Ready!

Follow the steps above to deploy your optimized WASM portfolio to Firebase Hosting!

Your portfolio will be:
- 🚀 **Blazing fast** with WASM
- 🌍 **Globally distributed** via CDN
- 🔒 **Secure** with automatic SSL
- 📊 **Monitored** with Firebase analytics

**Happy deploying! 🎊**

