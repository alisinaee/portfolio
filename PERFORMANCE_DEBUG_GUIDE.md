# 🔍 Performance Debugging Guide

## 📊 Real-Time Performance Tracking

Your app now has comprehensive performance tracking built into all animations!

---

## 🎯 Features

### 1. **Live FPS Monitor**
- Shows real-time FPS in the top-right corner
- Color-coded performance bar
- Frame timing in milliseconds

### 2. **Detailed Console Logging**
- Tracks every animation widget
- Logs initialization, builds, state changes
- Shows build counts and timing
- Identifies slow frames

### 3. **Performance Summary**
- Click "Print Log" button to see full summary
- Shows total builds per widget
- Identifies performance bottlenecks

---

## 🚀 How to Use

### Enable/Disable Logging

In `lib/core/utils/performance_logger.dart`, line 6:

```dart
const bool kDebugPerformance = true;  // Set to false to disable
```

### View Real-Time Stats

1. Run your app:
   ```bash
   flutter run -d chrome
   ```

2. Look at the **top-right corner** for FPS panel

3. Click **"Print Log"** button below the FPS panel to see detailed summary in console

---

## 📈 What Gets Tracked

### FlipAnimation
- Initialization
- Animation starts/completions
- Build counts
- Tune values and delays

### MovingRow
- Initialization with delay
- Widget list generation
- Direction toggles
- Build frequency
- State changes

### DiagonalWidget
- Layout calculations
- Recalculation triggers
- Angle and scale factor values
- Build timing

---

## 🔍 Reading the Logs

### Console Output Format

```
🟢 [timestamp] [WidgetName] 🎬 Action | data: value
```

### Symbols:
- 🟢 **Green**: Info/Normal operation
- 🟡 **Yellow**: Warning/Slow performance
- 🔴 **Red**: Error/Critical issue
- 🎬 **Animation**: Animation event
- 🏗️  **Build**: Widget build event
- 🔄 **setState**: State change
- 🐌 **Slow**: Slow frame detected

### Example Logs:

```
🟢 [10:23:45.123] [FlipAnimation_home] 🎬 Initializing
🟢 [10:23:45.156] [FlipAnimation_home] 🎬 Initialized
🟢 [10:23:46.234] [MovingRow_delay0_menu] 🎬 Starting animation loop
🟢 [10:23:46.235] [MovingRow_delay0_menu] 🏗️  Build #60 took 12ms
🟢 [10:23:51.345] [MovingRow_delay0_menu] 🔄 setState called (total: 90) - Toggle direction #3
🟡 [10:23:52.456] [DiagonalWidget] 🐌 Slow frame: 18.45ms (target: 16.7ms)
```

---

## 📊 Performance Summary

Click "Print Log" button or manually call:

```dart
PerformanceLogger.printSummary();
```

### Sample Output:

```
╔════════════════════════════════════════════════════════════╗
║         PERFORMANCE SUMMARY                                ║
╠════════════════════════════════════════════════════════════╣
║ MovingRow_delay0_menu                    :    450 builds
║ FlipAnimation_home                        :    380 builds
║ DiagonalWidget                            :     15 builds
║ FlipAnimation_settings                    :    320 builds
╚════════════════════════════════════════════════════════════╝
```

---

## 🎯 Identifying Performance Issues

### High Build Counts

**Bad:**
```
║ MovingRow_delay0_menu                    :   5000 builds
```

**Good:**
```
║ MovingRow_delay0_menu                    :    450 builds
```

**Fix**: Check for unnecessary `setState()` calls

### Slow Frames

```
🟡 [10:23:52.456] [DiagonalWidget] 🐌 Slow frame: 18.45ms
```

**Means**: Frame took > 16.7ms (below 60 FPS)

**Fix**: 
- Check for expensive calculations
- Add caching
- Use `RepaintBoundary`

### Excessive Recalculations

```
🟢 [10:23:46.789] [DiagonalWidget] 🎬 Recalculating layout | recalculation_count: 150
```

**If count is high**: Layout is changing too frequently

**Fix**: Add caching (already implemented!)

---

## 🔧 Optimization Checklist

### If FPS is Low (< 55):

1. **Check console for slow frames**
   - Look for 🐌 emoji
   - Identify which widget is causing it

2. **Check build counts**
   - Click "Print Log"
   - Look for widgets with > 1000 builds
   - Reduce unnecessary rebuilds

3. **Check calculations**
   - Look for "Recalculating" messages
   - Ensure caching is working

4. **Check toggles**
   - Look at toggle_count in logs
   - Should match expected frequency

---

## 📝 Common Patterns

### Good Performance:
```
🟢 Build #60 took 12ms          ✅ Fast builds
🟢 FPS: 58.3                     ✅ Good FPS
🟢 Frame: 15.2 ms                ✅ Under 16.7ms target
```

### Performance Issues:
```
🟡 Build #60 took 25ms           ⚠️ Slow build
🔴 FPS: 35.2                     ❌ Low FPS
🟡 Slow frame: 28.5ms            ⚠️ Frame drop
```

---

## 🎮 Interactive Debugging

### During Development:

1. **Run the app**
   ```bash
   flutter run -d chrome
   ```

2. **Watch the console** for logs (they auto-print)

3. **Click "Print Log"** periodically to see summary

4. **Interact with your app** and watch for:
   - Slow frame warnings
   - High build counts
   - Excessive state changes

### Throttling

Logs are automatically throttled to prevent spam:
- Max 1 log per second per widget
- Build counts logged every 60 builds
- setState logged every 30 calls

---

## 🎯 Performance Goals

| Metric | Target | Your App |
|--------|--------|----------|
| **FPS** | 55-60 | Check overlay |
| **Frame Time** | < 16.7ms | Check overlay |
| **Build Time** | < 16ms | Check logs |
| **Builds/min** | < 500 | Check summary |

---

## 💡 Tips

1. **Always check logs when FPS drops** below 55
2. **Use "Print Log" before and after changes** to compare
3. **Focus on widgets with high build counts first**
4. **Slow frames are normal occasionally** - look for patterns
5. **Disable logging in production** by setting `kDebugPerformance = false`

---

## 🧪 Testing Scenarios

### Test 1: Idle Performance
- Let app run for 1 minute
- Check summary - builds should be low
- FPS should be stable 55-60

### Test 2: Animation Load
- Trigger all animations
- Watch for slow frames
- Check which widget causes drops

### Test 3: Menu Navigation
- Open/close menu repeatedly
- Check build counts
- Should not increase excessively

---

## 🔄 Quick Commands

```dart
// In your code:

// Print summary anytime
PerformanceLogger.printSummary();

// Check build count
int builds = PerformanceLogger.getBuildCount('FlipAnimation_home');

// Reset all metrics
PerformanceLogger.reset();

// Log custom event
PerformanceLogger.logAnimation('MyWidget', 'Custom event', data: {
  'custom_value': 123,
});
```

---

## 📊 Understanding the Data

### Build Count

**What it means**: How many times `build()` was called

**Normal range**: 100-500 per minute

**High if**: > 1000 per minute

### Toggle Count

**What it means**: How many times MovingRow changed direction

**Normal**: Should match expected frequency (every 5 seconds)

**High if**: More frequent than expected

### Recalculation Count

**What it means**: How many times DiagonalWidget recalculated layout

**Normal**: Should be low (< 10)

**High if**: Layout changing frequently

---

## 🎉 Success Indicators

You're doing great if you see:

✅ **FPS steady at 55-60**
✅ **Build times < 16ms**
✅ **Few or no slow frame warnings**
✅ **Build counts < 500/min**
✅ **Recalculations only on resize**

---

## 🚨 Red Flags

Watch out for:

❌ **FPS drops below 45**
❌ **Frequent slow frame warnings**
❌ **Build counts > 1000/min**
❌ **Build times > 20ms**
❌ **Constant recalculations**

---

**Happy Debugging! 🚀**

*Your animations are now fully instrumented and ready for optimization!*

