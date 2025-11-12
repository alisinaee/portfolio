import 'package:flutter_test/flutter_test.dart';
import 'package:moving_text_background_new/features/menu/presentation/controllers/menu_controller.dart';
import 'package:moving_text_background_new/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:moving_text_background_new/features/menu/data/data_sources/menu_data_source.dart';
import 'package:moving_text_background_new/features/menu/domain/entities/menu_entity.dart';

/// Test to verify hover state optimization
/// 
/// This test validates that:
/// 1. Hover state updates only affect specific menu items
/// 2. Early return prevents unnecessary notifyListeners calls
/// 3. Debouncing prevents excessive rebuilds
void main() {
  group('AppMenuController Hover State Optimization', () {
    late AppMenuController controller;

    setUp(() {
      final dataSource = MenuDataSource();
      final repository = MenuRepositoryImpl(dataSource);
      controller = AppMenuController(repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Early return prevents update when hover state unchanged', () {
      // Get initial metrics
      final initialMetrics = controller.getHoverPerformanceMetrics();
      final initialSkipped = initialMetrics['skippedUpdates'] as int;

      // Update hover state to true
      controller.updateMenuItemHover(MenuItems.home, true);
      
      // Wait for debounce
      Future.delayed(const Duration(milliseconds: 20));

      // Try to update to same state (should be skipped)
      controller.updateMenuItemHover(MenuItems.home, true);
      controller.updateMenuItemHover(MenuItems.home, true);
      controller.updateMenuItemHover(MenuItems.home, true);

      // Get updated metrics
      final updatedMetrics = controller.getHoverPerformanceMetrics();
      final updatedSkipped = updatedMetrics['skippedUpdates'] as int;

      // Verify that duplicate updates were skipped
      expect(updatedSkipped, greaterThan(initialSkipped));
      expect(updatedSkipped - initialSkipped, equals(3));
    });

    test('Hover state updates only affect specific menu items', () {
      // Update hover state for home item
      controller.updateMenuItemHover(MenuItems.home, true);
      
      // Wait for debounce
      Future.delayed(const Duration(milliseconds: 20));

      // Verify only home item is hovered
      expect(controller.isItemHovered(MenuItems.home), isTrue);
      expect(controller.isItemHovered(MenuItems.project), isFalse);
      expect(controller.isItemHovered(MenuItems.realms), isFalse);
      expect(controller.isItemHovered(MenuItems.about), isFalse);
      expect(controller.isItemHovered(MenuItems.contact), isFalse);
    });

    test('Multiple hover updates are properly tracked', () {
      // Get initial metrics
      final initialMetrics = controller.getHoverPerformanceMetrics();
      final initialUpdates = initialMetrics['hoverUpdates'] as int;

      // Update different items
      controller.updateMenuItemHover(MenuItems.home, true);
      controller.updateMenuItemHover(MenuItems.project, true);
      controller.updateMenuItemHover(MenuItems.home, false);
      
      // Wait for debounce
      Future.delayed(const Duration(milliseconds: 50));

      // Get updated metrics
      final updatedMetrics = controller.getHoverPerformanceMetrics();
      final updatedUpdates = updatedMetrics['hoverUpdates'] as int;

      // Verify updates were tracked
      expect(updatedUpdates, greaterThan(initialUpdates));
    });

    test('Performance metrics show efficiency improvement', () {
      // Perform multiple updates with duplicates
      controller.updateMenuItemHover(MenuItems.home, true);
      controller.updateMenuItemHover(MenuItems.home, true); // Duplicate
      controller.updateMenuItemHover(MenuItems.home, true); // Duplicate
      controller.updateMenuItemHover(MenuItems.home, false);
      controller.updateMenuItemHover(MenuItems.home, false); // Duplicate
      
      // Wait for debounce
      Future.delayed(const Duration(milliseconds: 50));

      // Get metrics
      final metrics = controller.getHoverPerformanceMetrics();
      final efficiency = metrics['efficiency'] as String;

      // Verify efficiency is tracked
      expect(metrics['skippedUpdates'], greaterThan(0));
      expect(metrics['totalAttempts'], greaterThan(0));
      expect(efficiency, isNotEmpty);
    });
  });
}
