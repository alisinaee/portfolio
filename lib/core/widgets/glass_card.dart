import 'package:flutter/material.dart';

/// A simple glass card widget that creates a beautiful glass-like appearance
/// without complex shaders - just using gradients and effects
class GlassCard extends StatelessWidget {
  /// The child widget to display on top of the glass effect
  final Widget child;
  
  /// Width of the card
  final double? width;
  
  /// Height of the card
  final double? height;
  
  /// Border radius of the card
  final double borderRadius;
  
  /// Border color
  final Color borderColor;
  
  /// Border width
  final double borderWidth;
  
  /// Background color (behind the glass effect)
  final Color backgroundColor;
  
  /// Glass effect intensity (0.0 to 1.0)
  final double glassIntensity;
  
  /// Glass blur intensity
  final double blurIntensity;
  
  /// Padding inside the card
  final EdgeInsetsGeometry padding;
  
  /// Margin around the card
  final EdgeInsetsGeometry margin;
  
  /// Whether the card is draggable
  final bool isDraggable;
  
  /// Initial position for draggable cards
  final Offset? initialPosition;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 15.0,
    this.borderColor = const Color(0xFF404040),
    this.borderWidth = 1.0,
    this.backgroundColor = Colors.transparent,
    this.glassIntensity = 0.3,
    this.blurIntensity = 0.5,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.isDraggable = false,
    this.initialPosition,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        // Glass effect using gradients and shadows
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: glassIntensity * 0.1),
            Colors.white.withValues(alpha: glassIntensity * 0.05),
            Colors.white.withValues(alpha: glassIntensity * 0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: blurIntensity * 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: blurIntensity * 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Glass reflection effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: glassIntensity * 0.2),
                      Colors.transparent,
                      Colors.white.withValues(alpha: glassIntensity * 0.1),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            
            // Child content on top
            Positioned.fill(
              child: child,
            ),
          ],
        ),
      ),
    );

    // Return draggable or static version
    if (isDraggable) {
      return Draggable(
        feedback: cardContent,
        childWhenDragging: cardContent,
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }
}

/// Predefined glass card styles for common use cases
class GlassCardStyles {
  /// A small card for icons or small content
  static Widget small({
    required Widget child,
    Color? borderColor,
    double glassIntensity = 0.2,
  }) {
    return GlassCard(
      width: 80,
      height: 80,
      borderRadius: 12.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      glassIntensity: glassIntensity,
      child: child,
    );
  }

  /// A medium card for text content or buttons
  static Widget medium({
    required Widget child,
    Color? borderColor,
    double? width,
    double? height,
    double glassIntensity = 0.3,
  }) {
    return GlassCard(
      width: width ?? 200,
      height: height ?? 120,
      borderRadius: 15.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      glassIntensity: glassIntensity,
      child: child,
    );
  }

  /// A large card for main content areas
  static Widget large({
    required Widget child,
    Color? borderColor,
    double? width,
    double? height,
    double glassIntensity = 0.4,
  }) {
    return GlassCard(
      width: width ?? 300,
      height: height ?? 200,
      borderRadius: 20.0,
      borderColor: borderColor ?? const Color(0xFF404040),
      glassIntensity: glassIntensity,
      child: child,
    );
  }

  /// A card with custom styling for special effects
  static Widget custom({
    required Widget child,
    double borderRadius = 15.0,
    Color borderColor = const Color(0xFF404040),
    double borderWidth = 1.0,
    double glassIntensity = 0.3,
    double blurIntensity = 0.5,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    bool isDraggable = false,
  }) {
    return GlassCard(
      width: width,
      height: height,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      glassIntensity: glassIntensity,
      blurIntensity: blurIntensity,
      padding: padding,
      margin: margin,
      isDraggable: isDraggable,
      child: child,
    );
  }
}
