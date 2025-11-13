# Testing Guide

## Performance Testing

### Profile Mode Testing
```bash
flutter run --profile -d chrome
```

**What to check:**
- FPS overlay shows 55-60 fps
- No stuttering during animations
- Smooth menu transitions
- Stable memory usage

### Release Mode Testing
```bash
flutter run --release -d chrome
```

**What to check:**
- Production performance
- Bundle size
- Load time
- Overall smoothness

## Local Build Testing

### Build and Serve
```bash
# Build WASM version
./scripts/build_wasm.sh

# Serve locally
cd build/web
python3 -m http.server 8000

# Open http://localhost:8000
```

### What to Test
1. Initial load time (<3s)
2. Animation smoothness (60fps)
3. Menu responsiveness (<50ms)
4. Memory stability (no growth)
5. No console errors

## Browser DevTools Testing

### Performance Tab
1. Open Chrome DevTools (F12)
2. Go to Performance tab
3. Click Record
4. Interact with app for 30 seconds
5. Stop recording

**Look for:**
- ✅ Steady 60fps line
- ✅ No long tasks (>50ms)
- ✅ Smooth animation frames

### Memory Tab
1. Take heap snapshot
2. Interact with app for 5 minutes
3. Take another snapshot
4. Compare

**Expected:**
- Memory growth <10MB over 5 minutes
- No detached DOM nodes
- No memory leaks

### Network Tab
**Check:**
- Shaders load once, then cached
- No redundant asset requests
- Optimized bundle size

## Functional Testing

### Menu Testing
- [ ] Menu button responds instantly
- [ ] Menu opens smoothly (800ms)
- [ ] Hover effects work correctly
- [ ] Menu closes smoothly
- [ ] No lag during transitions

### Animation Testing
- [ ] Background animations smooth
- [ ] No jumps or stuttering
- [ ] Consistent timing (35s cycles)
- [ ] Animations pause when inactive
- [ ] Resume correctly when active

### Responsive Testing
Test on different screen sizes:
- [ ] Desktop (1920px+)
- [ ] Laptop (1366px+)
- [ ] Tablet (768px+)
- [ ] Mobile (375px+)

## Browser Compatibility Testing

Test on:
- [ ] Chrome (primary)
- [ ] Edge
- [ ] Firefox
- [ ] Safari (limited WASM support)

## Performance Benchmarks

### Target Metrics
| Metric | Target | Test Method |
|--------|--------|-------------|
| FPS | ≥55 | Performance overlay |
| Frame Time | <16.7ms | DevTools Performance |
| Build Time | <16ms | Console logs |
| Memory Growth | <10MB/5min | DevTools Memory |
| Initial Load | <3s | Network tab |

## Automated Testing

### Run Tests
```bash
flutter test
```

### Analyze Code
```bash
flutter analyze
```

### Performance Analysis
```bash
./scripts/analyze_performance.sh
```

## Troubleshooting

### Low FPS
1. Check running in profile/release mode
2. Verify hardware acceleration enabled
3. Test in Chrome/Edge
4. Close other browser tabs

### Memory Leaks
1. Check disposal patterns
2. Verify animation cleanup
3. Use DevTools Memory profiler

### Build Issues
1. Run `flutter clean`
2. Update Flutter: `flutter upgrade`
3. Check Flutter version compatibility

## Test Checklist

Before deployment:
- [ ] All tests pass
- [ ] No analyzer warnings
- [ ] Performance targets met
- [ ] Tested on target browsers
- [ ] No console errors
- [ ] Memory stable
- [ ] Animations smooth
- [ ] Responsive on all sizes
