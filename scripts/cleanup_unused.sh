#!/bin/bash

# Automated cleanup script for unused files
# This script removes all unused files identified in the analysis

echo "🧹 Starting Project Cleanup..."
echo ""

# Backup first
echo "📦 Creating backup..."
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r lib "$BACKUP_DIR/"
cp -r test "$BACKUP_DIR/"
echo "✅ Backup created in $BACKUP_DIR"
echo ""

# Counter
REMOVED_COUNT=0

# Function to remove file safely
remove_file() {
    if [ -f "$1" ]; then
        echo "🗑️  Removing: $1"
        rm "$1"
        ((REMOVED_COUNT++))
    else
        echo "⚠️  Not found: $1"
    fi
}

# Function to remove directory safely
remove_dir() {
    if [ -d "$1" ]; then
        echo "🗑️  Removing directory: $1"
        rm -rf "$1"
        ((REMOVED_COUNT++))
    else
        echo "⚠️  Not found: $1"
    fi
}

echo "🗑️  Removing unused main files..."
remove_file "lib/main_optimized.dart"
remove_file "lib/main_with_tracking.dart"
echo ""

echo "🗑️  Removing unused optimized versions..."
remove_file "lib/features/menu/presentation/pages/optimized_landing_page.dart"
remove_file "lib/features/menu/presentation/pages/optimized_main_app_widget.dart"
remove_file "lib/features/menu/presentation/controllers/optimized_menu_controller.dart"
remove_file "lib/features/menu/presentation/widgets/optimized_menu_widget.dart"
remove_file "lib/core/animations/optimized_moving_text.dart"
echo ""

echo "🗑️  Removing unused demo/test pages..."
remove_file "lib/features/menu/presentation/pages/liquid_glass_demo_page.dart"
echo ""

echo "🗑️  Removing unused widget variants..."
remove_file "lib/core/widgets/glass_card.dart"
remove_file "lib/core/widgets/liquid_glass_card.dart"
remove_file "lib/core/widgets/proper_liquid_glass_card.dart"
remove_file "lib/core/widgets/real_liquid_glass_card.dart"
remove_file "lib/core/widgets/simple_liquid_glass_card.dart"
echo ""

echo "🗑️  Removing unused web shader implementations..."
remove_file "lib/core/web_shaders/background_stream_channel.dart"
remove_file "lib/core/web_shaders/entire_surface_widget.dart"
remove_file "lib/core/web_shaders/simple_full_coverage_widget.dart"
remove_file "lib/core/web_shaders/simple_web_liquid_glass_widget.dart"
remove_file "lib/core/web_shaders/stream_liquid_glass_widget.dart"
remove_file "lib/core/web_shaders/web_liquid_glass_widget.dart"
echo ""

echo "🗑️  Removing unused native shader files..."
remove_file "lib/core/native_shaders/liquid_glass_platform_channel.dart"
remove_file "lib/core/native_shaders/native_liquid_glass_widget.dart"
echo ""

echo "🗑️  Removing unused performance tools..."
remove_file "lib/core/performance/canvas_animation_engine.dart"
remove_file "lib/core/performance/widget_pool.dart"
echo ""

echo "🗑️  Removing duplicate utility..."
remove_file "lib/core/utils/performance_overlay_widget.dart"
echo ""

echo "🗑️  Removing unused feature directories..."
remove_dir "lib/features/liquid_glass_test"
remove_dir "lib/core/native_shaders"
remove_dir "lib/core/web_shaders"
echo ""

echo "🗑️  Removing test files (optional - comment out if you want to keep tests)..."
remove_file "test/hover_optimization_demo.dart"
remove_file "test/menu_controller_hover_test.dart"
remove_file "test/performance_benchmark.dart"
remove_file "test/performance_validation_test.dart"
remove_file "test/visual_regression_test.dart"
remove_dir "test/goldens"
echo ""

# Clean up empty directories
echo "🧹 Cleaning up empty directories..."
find lib -type d -empty -delete 2>/dev/null
find test -type d -empty -delete 2>/dev/null
echo ""

echo "✅ Cleanup complete!"
echo "📊 Removed $REMOVED_COUNT files/directories"
echo ""
echo "📦 Backup location: $BACKUP_DIR"
echo ""
echo "🔍 Next steps:"
echo "   1. Run: flutter analyze"
echo "   2. Run: flutter test (if you kept test files)"
echo "   3. Run: flutter run --profile -d chrome"
echo "   4. If everything works, you can delete the backup: rm -rf $BACKUP_DIR"
echo ""
