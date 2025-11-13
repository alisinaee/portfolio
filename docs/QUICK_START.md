# 🚀 Quick Start Guide

## Running the App

### Development
```bash
flutter run -d chrome
```

### Production Build (WASM)
```bash
./scripts/build_wasm.sh
```

### Deployment
```bash
# Preview channel
./scripts/deploy_preview.sh

# Production
./scripts/deploy_firebase.sh
```

## Testing Performance

### Enable Performance Overlay
In `lib/main.dart`:
```dart
home: const PerformanceMonitor(
  showOverlay: true,  // Enable FPS counter
  child: LandingPage(),
),
```

### Run in Profile Mode
```bash
flutter run --profile -d chrome
```

## Performance Targets

| Metric | Target |
|--------|--------|
| FPS | ≥55 |
| Jank | <5% |
| Build Time | <16ms |

## Quick Optimizations

### 1. Disable Debug Logging (5 min)
```dart
// In lib/core/utils/performance_logger.dart
const bool kDebugPerformance = false;
```
**Impact**: +5-10% FPS

### 2. Add Const Constructors (15 min)
```dart
const Text('Static text')
const Icon(Icons.menu)
const SizedBox(height: 20)
```
**Impact**: +5-10% FPS

## Documentation

- [Performance Guide](performance/PERFORMANCE_GUIDE.md) - Complete performance documentation
- [Firebase Setup](guides/FIREBASE_SETUP.md) - Firebase configuration
- [Testing Guide](guides/TESTING_GUIDE.md) - Testing procedures

## Browser Compatibility

| Browser | Support | Performance |
|---------|---------|-------------|
| Chrome | ✅ Excellent | ⭐⭐⭐⭐⭐ |
| Edge | ✅ Excellent | ⭐⭐⭐⭐⭐ |
| Firefox | ✅ Good | ⭐⭐⭐⭐ |
| Safari | ⚠️ Limited | ⭐⭐⭐ |

**Recommended**: Chrome or Edge for best experience
