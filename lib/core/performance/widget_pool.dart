import 'package:flutter/material.dart';

/// High-performance widget pool for reusing expensive widgets
/// Reduces GC pressure and improves frame rates
class WidgetPool<T extends Widget> {
  final List<T> _available = [];
  final Set<T> _inUse = {};
  final T Function() _factory;
  final int _maxSize;

  WidgetPool({
    required T Function() factory,
    int maxSize = 10,
  }) : _factory = factory, _maxSize = maxSize;

  /// Get a widget from the pool or create new one
  T acquire() {
    T widget;
    if (_available.isNotEmpty) {
      widget = _available.removeLast();
    } else {
      widget = _factory();
    }
    _inUse.add(widget);
    return widget;
  }

  /// Return widget to pool for reuse
  void release(T widget) {
    if (_inUse.remove(widget) && _available.length < _maxSize) {
      _available.add(widget);
    }
  }

  /// Clear all pooled widgets
  void clear() {
    _available.clear();
    _inUse.clear();
  }

  int get availableCount => _available.length;
  int get inUseCount => _inUse.length;
}

/// Singleton widget pool manager
class WidgetPoolManager {
  static final WidgetPoolManager _instance = WidgetPoolManager._();
  static WidgetPoolManager get instance => _instance;
  WidgetPoolManager._();

  final Map<Type, WidgetPool> _pools = {};

  /// Get or create a pool for widget type
  WidgetPool<T> getPool<T extends Widget>(T Function() factory) {
    return _pools.putIfAbsent(T, () => WidgetPool<T>(factory: factory)) as WidgetPool<T>;
  }

  /// Clear all pools
  void clearAll() {
    for (final pool in _pools.values) {
      pool.clear();
    }
    _pools.clear();
  }
}