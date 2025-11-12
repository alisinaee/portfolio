# Quick Performance Reference Card

## 🎯 Performance Targets

| Metric | Good | Warning | Critical |
|--------|------|---------|----------|
| FPS | ≥55 | 45-55 | <45 |
| Jank % | <5% | 5-10% | >10% |
| Build Time | <16ms | 16-32ms | >32ms |
| Animation FPS | ≥55 | 45-55 | <45 |
| State Update | <5ms | 5-10ms | >10ms |

## 🚀 Quick Setup (3 Steps)

### 1. Enable Tracking
```dart
// In main.dart
import 'core/performance/advanced_performance_tracker.dart';
import 'core/performance/performance_overlay.dart';

void main() {
  AdvancedPerformanceTracker.instance.startMonitoring();
  runApp(MyApp());
}
```

### 2. Add Overlay
```dart
MaterialApp(
  home: PerformanceOverlay(
    enabled: true,
    child: YourPage(),
  ),
)
```

### 3. Run & Monitor
```bash
flutter run --profile -d chrome
```

## 📊 Reading the Overlay

- **Green FPS**: Everything good
- **Orange FPS**: Needs attention
- **Red FPS**: Critical issue
- **Jank Count**: Dropped frames
- Click to expand details

## 🔧 Quick Fixes

### Fix 1: Disable Debug Logs
```dart
const bool kDebugPerformance = false;
```
Impact: +5-10% FPS

### Fix 2: Add RepaintBoundary
```dart
RepaintBoundary(child: ExpensiveWidget())
```
Impact: +10-15% FPS

### Fix 3: Use Const
```dart
const Text('Static')
```
Impact: +5-10% FPS

### Fix 4: Batch Updates
```dart
scheduleMicrotask(() => notifyListeners());
```
Impact: -50% state overhead

### Fix 5: Debounce Events
```dart
Timer(Duration(milliseconds: 16), () => update());
```
Impact: -70% unnecessary updates

## 📈 Tracking Widgets

```dart
class _MyState extends State<MyWidget> 
    with EnhancedPerformanceTracking<MyWidget> {
  @override
  String get trackingId => 'MyWidget';
  
  @override
  Widget buildWithTracking(BuildContext context) {
    return Container();
  }
}
```

## 🎬 Tracking Animations

```dart
class _MyState extends State<MyWidget> 
    with TickerProviderStateMixin, 
         AnimationPerformanceTracking<MyWidget> {
  @override
  String get animationId => 'MyAnimation';
  
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = createTrackedController(
      duration: Duration(milliseconds: 300),
    );
  }
}
```

## 🔄 Tracking State

```dart
class MyController extends ChangeNotifier 
    with StatePerformanceTracking {
  @override
  String get stateId => 'MyController';
}
```

## 📝 Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Low FPS | Too many rebuilds | Add RepaintBoundary |
| High Jank | Slow builds | Optimize widget tree |
| Memory leak | Not disposing | Add dispose() calls |
| Choppy animation | Complex curve | Use Curves.easeOut |
| Slow state | Many listeners | Batch updates |

## 🎯 Optimization Priority

1. **High Impact, Low Effort**
   - Disable debug logs
   - Add const constructors
   - Add RepaintBoundary

2. **High Impact, Medium Effort**
   - Batch state updates
   - Debounce events
   - Optimize animations

3. **Medium Impact, High Effort**
   - Refactor widget tree
   - Optimize shaders
   - Implement caching

## 📊 Performance Report Example

```
╔════════════════════════════════════════╗
║ PERFORMANCE REPORT                     ║
╠════════════════════════════════════════╣
║ Average FPS:   58.3 fps                ║
║ Jank Frames:     42 (1.2%)             ║
║ Top Rebuilds:                          ║
║   1. MenuWidget: 234 (2.3ms avg)       ║
║   2. Background: 156 (1.8ms avg)       ║
╚════════════════════════════════════════╝
```

## 🔍 Debugging Commands

```bash
# Profile mode (accurate metrics)
flutter run --profile -d chrome

# Release mode (fastest)
flutter run --release -d chrome

# With DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## ⚡ Performance Checklist

- [ ] Tracking enabled
- [ ] Overlay visible
- [ ] Baseline metrics collected
- [ ] Debug logs disabled
- [ ] RepaintBoundary added
- [ ] Const constructors used
- [ ] State updates batched
- [ ] Events debounced
- [ ] Animations optimized
- [ ] Final metrics compared

---

**Quick Tip**: Always measure before optimizing!
