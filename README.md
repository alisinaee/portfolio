# 🎨 Ali Sianee's Portfolio

A beautiful, high-performance animated portfolio built with Flutter Web and optimized with WebAssembly.

[![Live Demo](https://img.shields.io/badge/Live%20Demo-Firebase-orange?style=for-the-badge&logo=firebase)](https://portfolio-2d46c.web.app)
[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue?style=for-the-badge&logo=github)](https://github.com/alisinaee/portfolio)

---

## 🌐 **Live Site**

### **Visit the portfolio:**
🔗 **[https://portfolio-2d46c.web.app](https://portfolio-2d46c.web.app)**

---

## ✨ **Features**

### **Unique Animations** 🎭
- **Flip Animations** - Smooth vertical flip transitions
- **Moving Text Backgrounds** - Horizontal scrolling text
- **Diagonal Layout** - Dynamic rotation transformations
- **Interactive Menu** - Smooth open/close transitions
- **Hover Effects** - Responsive visual feedback

### **Visual Design** 🎨
- **11 Custom Fonts** - Avalon, Ganyme, Clark, Headliner, and more
- **SVG Icons** - Scalable navigation icons
- **Responsive Layout** - Works on all screen sizes
- **Modern UI** - Clean, professional design

### **Performance** ⚡
- **WASM-Powered** - 2-3x faster than JavaScript builds
- **60 FPS Animations** - Buttery smooth
- **Anti-Lag System** - Runs indefinitely without slowdown
- **Memory Optimized** - No leaks, stable performance
- **Smart Pausing** - Animations only rebuild when active

---

## 🚀 **Technology Stack**

| Technology | Purpose |
|------------|---------|
| **Flutter Web** | UI Framework |
| **WebAssembly (WASM)** | High-performance execution |
| **Firebase Hosting** | Global CDN delivery |
| **Provider** | State management |
| **Custom Animations** | AnimatedBuilder, AnimatedPositioned |
| **Performance Monitoring** | Real-time FPS tracking |

---

## 📊 **Performance Optimizations**

### **What Makes It Fast:**

1. **WASM Compilation** ⚡
   - 2-3x faster than JavaScript
   - Near-native performance
   - Better animation smoothness

2. **Smart Animation Pausing** 🎯
   - 83% fewer widget rebuilds
   - Switches between animated and static states
   - Only rebuilds during active animation

3. **Memory Management** 🧹
   - Automatic cleanup every 5 minutes
   - Prevents memory leaks
   - Stable performance indefinitely

4. **Strategic Optimizations** 🔧
   - RepaintBoundary isolation
   - Cached calculations (DiagonalWidget)
   - Tree-shaken icons (99.5% reduction)
   - Const constructors throughout

### **Performance Metrics:**

| Metric | Target | Achieved |
|--------|--------|----------|
| **FPS** | 60 | ✅ 55-60 |
| **Frame Time** | <16.7ms | ✅ <1ms |
| **Build Time** | <16ms | ✅ <1ms |
| **Memory Growth** | Flat | ✅ Stable |
| **Lag-free Runtime** | Hours | ✅ Indefinite |

---

## 🛠️ **Getting Started**

### **Prerequisites:**
- Flutter SDK (3.22.0+)
- Dart SDK (3.9.2+)
- Firebase CLI
- Chrome/Edge browser (for development)

### **Installation:**

```bash
# Clone the repository
git clone https://github.com/alisinaee/portfolio.git
cd portfolio

# Get dependencies
flutter pub get

# Run locally
flutter run -d chrome
```

---

## 🏗️ **Build Commands**

### **Development:**
```bash
flutter run -d chrome
```

### **Production WASM Build:**
```bash
./build_wasm.sh
```

### **Deployment:**
```bash
# Preview (test first)
./deploy_preview.sh

# Production
./deploy_firebase.sh
```

---

## 📂 **Project Structure**

```
lib/
├── core/
│   ├── constants/        # App constants
│   └── utils/            # Performance & memory utilities
├── features/
│   └── menu/
│       ├── data/         # Data sources & repositories
│       ├── domain/       # Entities & repository interfaces
│       └── presentation/ # Controllers, pages, widgets
├── shared/
│   └── widgets/          # Reusable animated widgets
└── main.dart             # App entry point

assets/
├── fonts/                # 11 custom fonts
├── icons/                # SVG navigation icons
└── images/               # Image assets

Build Scripts:
├── build_wasm.sh         # WASM production build
├── deploy_firebase.sh    # Deploy to Firebase
└── deploy_preview.sh     # Deploy to preview channel
```

---

## 🎨 **Custom Fonts**

The portfolio uses 11 unique fonts:

- Avalon
- Avalors
- Bold
- Clark
- Clark Hollow
- Ganyme
- Gunplay
- Headliner
- Jenkine Bold
- Mutant
- Theh

---

## 📚 **Documentation**

| Guide | Description |
|-------|-------------|
| [QUICK_START.md](QUICK_START.md) | Quick reference guide |
| [PERFORMANCE_GUIDE.md](PERFORMANCE_GUIDE.md) | Complete performance docs |
| [PERFORMANCE_DEBUG_GUIDE.md](PERFORMANCE_DEBUG_GUIDE.md) | Debug animations |
| [ANTI_LAG_OPTIMIZATIONS.md](ANTI_LAG_OPTIMIZATIONS.md) | Lag prevention |
| [FIREBASE_SETUP.md](FIREBASE_SETUP.md) | Firebase configuration |
| [DEPLOYMENT_SUCCESS.md](DEPLOYMENT_SUCCESS.md) | Deployment summary |

---

## 🧪 **Testing**

### **Local Testing:**
```bash
flutter run -d chrome
```

### **Performance Testing:**
Enable performance overlay in `lib/main.dart`:
```dart
home: const PerformanceMonitor(
  showOverlay: true,  // Enable FPS counter
  child: MenuPage(),
),
```

### **Production Build Testing:**
```bash
./build_wasm.sh
cd build/web
python3 -m http.server 8000
# Open http://localhost:8000
```

---

## 🔍 **Performance Debugging**

### **Enable Debug Mode:**

In `lib/core/utils/performance_logger.dart`:
```dart
const bool kDebugPerformance = true;  // Enable logging
```

### **View Logs:**
- Check terminal console for detailed logs
- Click "Print Log" button in performance overlay
- Monitor build counts and timing

### **Logs Include:**
- Widget initialization
- Animation state changes
- Build counts (every 60 builds)
- Direction toggles
- Frame timing warnings

---

## 🌍 **Browser Compatibility**

| Browser | WASM Support | Performance |
|---------|--------------|-------------|
| **Chrome** | ✅ Excellent | ⭐⭐⭐⭐⭐ |
| **Edge** | ✅ Excellent | ⭐⭐⭐⭐⭐ |
| **Firefox** | ✅ Good | ⭐⭐⭐⭐ |
| **Safari** | ⚠️ Limited | ⭐⭐⭐ |

**Recommended:** Chrome or Edge for best experience

---

## 📱 **Responsive Design**

The portfolio is fully responsive and works on:
- 💻 Desktop (1920px+)
- 💻 Laptop (1366px+)
- 📱 Tablet (768px+)
- 📱 Mobile (375px+)

---

## 🔒 **Security**

- ✅ **HTTPS** - Automatic SSL via Firebase
- ✅ **CORS Headers** - Properly configured for WASM
- ✅ **Security Headers** - Cross-Origin policies set
- ✅ **No Secrets** - All config safe for public deployment

---

## 📈 **Optimization Results**

### **Before Optimization:**
- ❌ 4000+ builds after 23 minutes
- ❌ Continuous rebuilds even when paused
- ❌ Linear memory growth
- ❌ Lag after 1 hour

### **After Optimization:**
- ✅ ~700 builds after 23 minutes (83% reduction!)
- ✅ Smart pausing - no rebuilds when idle
- ✅ Flat memory usage
- ✅ No lag indefinitely

---

## 🤝 **Contributing**

This is a personal portfolio project, but feel free to:
- Report issues
- Suggest improvements
- Fork for your own use
- Learn from the code

---

## 📧 **Contact**

**Ali Sianee**
- 📧 Email: alsisinaiasl@gmail.com
- 🌐 Portfolio: [https://portfolio-2d46c.web.app](https://portfolio-2d46c.web.app)
- 💼 GitHub: [@alisinaee](https://github.com/alisinaee)

---

## 📄 **License**

Copyright © 2024 Ali Sianee. All rights reserved.

---

## 🙏 **Acknowledgments**

Built with:
- Flutter - Google's UI toolkit
- Firebase - Google's app platform
- WebAssembly - High-performance web standard
- Custom animations - Original implementations

---

## 🎯 **Quick Links**

| Resource | Link |
|----------|------|
| **Live Site** | [https://portfolio-2d46c.web.app](https://portfolio-2d46c.web.app) |
| **GitHub Repo** | [https://github.com/alisinaee/portfolio](https://github.com/alisinaee/portfolio) |
| **Firebase Console** | [Dashboard](https://console.firebase.google.com/project/portfolio-2d46c) |

---

**Made with ❤️ and Flutter**

**Status:** ✅ Live & Optimized | **Last Updated:** October 15, 2025
