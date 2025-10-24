## Background Animation Optimization Checklist

Use this to iteratively improve smoothness on web without changing the visual behavior. After each step, run the app for 2–3 minutes and paste the console output so we can validate gains.

- [ ] Enable performance logs and frame timing
  - Set `kDebugPerformance = true` in `lib/core/utils/performance_logger.dart`
  - In `main.dart`, add a frame timings listener to report slow frames
  - Expected: Console shows build times, animation events, and slow-frame warnings

- [ ] Reduce rebuild pressure in moving rows
  - Ensure `MovingRow` uses `AnimatedBuilder` + `Transform.translate` (GPU) and keeps child subtree stable
  - Wrap heavy subtrees with `RepaintBoundary`
  - Expected: Lower build counts; steady frame times

- [ ] Unify timing and remove drift
  - Use `AnimationController` with `Ticker` (no long `Future.delayed` loops)
  - Use status listeners to reverse/forward instead of setState loops
  - Expected: No “jump to start” between cycles

- [ ] Align stagger logic without extra controllers
  - Prefer a single `AnimationController` per `MovingRow` (already present). For multiple rows, vary `delaySec` and direction only
  - Avoid one controller per inner element
  - Expected: Fewer active tickers; lower CPU

- [ ] Ease work per frame
  - Prefer `FadeTransition` over costly size/position transitions for switching content
  - Avoid `AnimatedPositioned`/layout-heavy ops on web where possible
  - Expected: Fewer layout passes during animation

- [ ] Tune durations and pauses
  - Slightly increase durations or pauses if GPU time is borderline (e.g., 3s move, 5s pause)
  - Keep distance modest (e.g., ≤ 20% width) to reduce pixel work
  - Expected: Fewer slow-frame logs

- [ ] Cap list sizes and cache children
  - Generate immutable lists once (`List.generate(..., growable: false)`)
  - Avoid rebuilding `Row` contents each tick
  - Expected: Stable memory; fewer GC spikes

- [ ] Verify isolation
  - Place `RepaintBoundary` around animated layers; keep static UI outside
  - Expected: Only animated layers repaint

- [ ] Validate results
  - Watch for `🐌 Slow frame` warnings
  - Compare build counts via `PerformanceLogger.printSummary()` after 2–3 minutes
  - Expected: Build counts decrease and remain stable; minimal slow frames

- [ ] Optional final polish
  - Consider globally lowering target FPS on web via `SchedulerBinding.instance.timeDilation` for testing only
  - Consider lowering text opacity/blur during motion if still GPU-bound (visual tweak)

When you finish a step, paste logs; we’ll decide whether to proceed or adjust.


