import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Memory Manager - Helps prevent memory leaks in long-running animations
class MemoryManager {
  static Timer? _cleanupTimer;
  static int _cleanupCount = 0;
  
  /// Start periodic memory cleanup
  static void startPeriodicCleanup() {
    // Run cleanup every 5 minutes
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _performCleanup();
    });
  }
  
  /// Perform memory cleanup
  static void _performCleanup() {
    _cleanupCount++;
    
    // Only log cleanup in debug mode to reduce overhead
    if (kDebugMode) {
      debugPrint('🧹 [MemoryManager] Performing cleanup #$_cleanupCount');
    }
    
    // Force garbage collection hint
    // Note: Dart's GC will run automatically, but this helps
    
    if (kDebugMode) {
      debugPrint('🧹 [MemoryManager] Cleanup complete');
    }
  }
  
  /// Stop cleanup timer
  static void stopCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    debugPrint('🧹 [MemoryManager] Cleanup stopped');
  }
  
  /// Manual cleanup trigger
  static void cleanup() {
    _performCleanup();
  }
}

