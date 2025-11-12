# Golden Files for Visual Regression Testing

This directory contains golden files (baseline images) used for visual regression testing of the menu system.

## What are Golden Files?

Golden files are reference images that represent the expected visual output of widgets. During testing, Flutter renders widgets and compares the output against these golden files pixel-by-pixel. Any differences indicate potential visual regressions.

## Files in this Directory

### menu_closed_state.png
- **Description:** Full landing page with menu in closed state
- **Size:** ~105KB
- **Purpose:** Validates that the menu closed state maintains visual consistency
- **Requirements:** 2.1, 2.3

### menu_button_closed.png
- **Description:** Isolated menu button (hamburger icon)
- **Size:** ~1.1KB
- **Purpose:** Validates menu button visual appearance
- **Requirements:** 2.3

## Usage

### Running Visual Regression Tests

```bash
# Run tests and compare against golden files
flutter test test/visual_regression_test.dart

# Update golden files (when visual changes are intentional)
flutter test test/visual_regression_test.dart --update-goldens
```

### When to Update Golden Files

Update golden files when:
1. **Intentional Visual Changes:** You've made deliberate changes to the UI design
2. **New Features:** You've added new visual elements that need baseline images
3. **Platform Updates:** Flutter or platform rendering has changed
4. **Test Expansion:** You've added new test cases that need golden files

### When NOT to Update Golden Files

Do NOT update golden files when:
1. **Tests are Failing:** Investigate the cause first
2. **Unintentional Changes:** Visual differences may indicate bugs
3. **Without Review:** Always review visual changes before updating
4. **CI/CD Failures:** Understand why tests failed before regenerating

## Best Practices

### 1. Review Before Updating
Always visually inspect the differences before updating golden files:
```bash
# Run tests to see failures
flutter test test/visual_regression_test.dart

# Review the failure output to understand what changed
# Only update if changes are intentional
```

### 2. Version Control
- ✅ **DO** commit golden files to version control
- ✅ **DO** include them in pull requests
- ✅ **DO** document why golden files were updated in commit messages
- ❌ **DON'T** update golden files without explanation

### 3. Cross-Platform Considerations
- Golden files may differ slightly between platforms (macOS, Linux, Windows)
- Consider generating platform-specific golden files if needed
- Document platform-specific differences

### 4. File Naming Convention
Use descriptive names that indicate:
- What is being tested (e.g., `menu_closed_state`)
- The state or condition (e.g., `hover`, `selected`, `open`)
- The component (e.g., `button`, `card`, `menu`)

## Troubleshooting

### Test Failures

**Problem:** Tests fail with "Golden file does not match"  
**Solution:**
1. Review the visual differences in the test output
2. Determine if changes are intentional or bugs
3. If intentional, update golden files with `--update-goldens`
4. If bugs, fix the code and re-run tests

**Problem:** Golden files not found  
**Solution:**
1. Run tests with `--update-goldens` to generate initial golden files
2. Ensure the `test/goldens/` directory exists
3. Check that test file paths match golden file paths

**Problem:** Tests pass locally but fail in CI/CD  
**Solution:**
1. Platform rendering differences may cause pixel-level variations
2. Consider using tolerance thresholds for pixel comparisons
3. Generate platform-specific golden files if needed

### Rendering Differences

**Problem:** Slight pixel differences between runs  
**Solution:**
- Some rendering differences are expected due to anti-aliasing
- Consider using `matchesGoldenFile` with tolerance parameters
- Focus on significant visual changes, not minor pixel variations

## Integration with CI/CD

### Recommended CI/CD Setup

```yaml
# Example GitHub Actions workflow
- name: Run Visual Regression Tests
  run: flutter test test/visual_regression_test.dart
  
- name: Upload Failed Golden Comparisons
  if: failure()
  uses: actions/upload-artifact@v2
  with:
    name: golden-failures
    path: test/failures/
```

### Approval Process

1. **Automated Tests:** Run on every PR
2. **Manual Review:** Require visual review for golden file changes
3. **Approval:** Designated team member approves visual changes
4. **Documentation:** Update this README with change rationale

## Related Documentation

- **Test Suite:** `test/visual_regression_test.dart`
- **Requirements:** `.kiro/specs/menu-transition-performance-fix/requirements.md`
- **Visual Regression Report:** `.kiro/specs/menu-transition-performance-fix/VISUAL_REGRESSION_REPORT.md`

## Maintenance

### Regular Updates
- Review golden files quarterly for relevance
- Remove obsolete golden files
- Add new golden files for new features
- Update documentation as needed

### File Management
- Keep golden files organized by feature/component
- Use subdirectories for complex features
- Maintain reasonable file sizes (compress if needed)
- Document any special considerations

---

**Last Updated:** November 10, 2025  
**Maintained By:** Development Team  
**Questions?** See `.kiro/specs/menu-transition-performance-fix/VISUAL_REGRESSION_REPORT.md`
