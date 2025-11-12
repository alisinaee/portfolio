#!/bin/bash

# Performance Analysis Script
# Helps identify performance bottlenecks in your Flutter app

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Flutter Performance Analysis Tool                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter found${NC}"
echo ""

# Function to analyze code for performance issues
analyze_code() {
    echo "🔍 Analyzing code for performance issues..."
    echo ""
    
    # Check for debug logs
    echo "📝 Checking for excessive debug logging..."
    DEBUG_COUNT=$(grep -r "debugPrint\|print(" lib/ --include="*.dart" | wc -l)
    if [ "$DEBUG_COUNT" -gt 50 ]; then
        echo -e "${YELLOW}⚠️  Found $DEBUG_COUNT debug print statements${NC}"
        echo "   Consider disabling in production: const bool kDebugPerformance = false;"
    else
        echo -e "${GREEN}✅ Debug logging looks reasonable ($DEBUG_COUNT statements)${NC}"
    fi
    echo ""
    
    # Check for missing const constructors
    echo "📝 Checking for missing const constructors..."
    CONST_OPPORTUNITIES=$(grep -r "Text(\|Icon(\|SizedBox(\|Padding(" lib/ --include="*.dart" | grep -v "const " | wc -l)
    if [ "$CONST_OPPORTUNITIES" -gt 20 ]; then
        echo -e "${YELLOW}⚠️  Found $CONST_OPPORTUNITIES potential const constructor opportunities${NC}"
        echo "   Add 'const' keyword where possible for better performance"
    else
        echo -e "${GREEN}✅ Const constructor usage looks good${NC}"
    fi
    echo ""
    
    # Check for RepaintBoundary usage
    echo "📝 Checking for RepaintBoundary usage..."
    REPAINT_COUNT=$(grep -r "RepaintBoundary" lib/ --include="*.dart" | wc -l)
    if [ "$REPAINT_COUNT" -lt 5 ]; then
        echo -e "${YELLOW}⚠️  Only found $REPAINT_COUNT RepaintBoundary widgets${NC}"
        echo "   Consider adding RepaintBoundary around expensive widgets"
    else
        echo -e "${GREEN}✅ RepaintBoundary usage looks good ($REPAINT_COUNT instances)${NC}"
    fi
    echo ""
    
    # Check for setState usage
    echo "📝 Checking for setState patterns..."
    SETSTATE_COUNT=$(grep -r "setState(" lib/ --include="*.dart" | wc -l)
    echo "   Found $SETSTATE_COUNT setState calls"
    if [ "$SETSTATE_COUNT" -gt 100 ]; then
        echo -e "${YELLOW}⚠️  High number of setState calls - consider state management optimization${NC}"
    fi
    echo ""
    
    # Check for animation controllers
    echo "📝 Checking animation controller disposal..."
    CONTROLLER_COUNT=$(grep -r "AnimationController" lib/ --include="*.dart" | wc -l)
    DISPOSE_COUNT=$(grep -r "\.dispose()" lib/ --include="*.dart" | wc -l)
    echo "   Found $CONTROLLER_COUNT animation controllers"
    echo "   Found $DISPOSE_COUNT dispose calls"
    if [ "$DISPOSE_COUNT" -lt "$CONTROLLER_COUNT" ]; then
        echo -e "${YELLOW}⚠️  Potential memory leak - ensure all controllers are disposed${NC}"
    else
        echo -e "${GREEN}✅ Disposal looks good${NC}"
    fi
    echo ""
}

# Function to check build configuration
check_build_config() {
    echo "🔧 Checking build configuration..."
    echo ""
    
    # Check if running in profile mode
    echo "   To test performance, run:"
    echo -e "${GREEN}   flutter run --profile -d chrome${NC}"
    echo ""
    
    # Check for web optimizations
    if [ -f "web/index.html" ]; then
        echo -e "${GREEN}✅ Web configuration found${NC}"
    fi
    echo ""
}

# Function to suggest optimizations
suggest_optimizations() {
    echo "💡 Optimization Suggestions:"
    echo ""
    echo "1. Enable Performance Tracking:"
    echo "   - Use main_with_tracking.dart"
    echo "   - Add PerformanceOverlay to your app"
    echo ""
    echo "2. Quick Wins:"
    echo "   - Set kDebugPerformance = false in production"
    echo "   - Add const constructors where possible"
    echo "   - Wrap expensive widgets with RepaintBoundary"
    echo ""
    echo "3. Advanced Optimizations:"
    echo "   - Batch state updates with scheduleMicrotask"
    echo "   - Debounce rapid events (hover, scroll)"
    echo "   - Use Selector instead of Consumer"
    echo ""
    echo "4. Testing:"
    echo "   - Run: flutter run --profile -d chrome"
    echo "   - Monitor FPS overlay"
    echo "   - Check console for performance reports"
    echo ""
}

# Main execution
analyze_code
check_build_config
suggest_optimizations

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Analysis Complete                                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📚 For detailed guide, see:"
echo "   - COMPREHENSIVE_PERFORMANCE_GUIDE.md"
echo "   - PERFORMANCE_OPTIMIZATION_SUMMARY.md"
echo "   - QUICK_PERFORMANCE_REFERENCE.md"
echo ""
