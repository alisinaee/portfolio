# Liquid Glass Box Sizing Guide

## Overview
This guide explains how to create liquid glass boxes of different sizes in the Flutter app using the `LiquidGlassBoxWidget`.

## Widget Parameters

### Required Parameters
- `width`: Double - The width of the liquid glass box in pixels
- `height`: Double - The height of the liquid glass box in pixels  
- `initialPosition`: Offset - The initial position (x, y) of the box on screen
- `backgroundKey`: GlobalKey - Reference to the background for capture

### Optional Parameters
- `borderRadius`: Double - Border radius for rounded corners (default: 6.0)
- `child`: Widget - Content to display inside the liquid glass box
- `key`: Key - Widget key for identification

## Size Examples

### Tiny Box (60x60)
```dart
LiquidGlassBoxWidget(
  backgroundKey: backgroundKey,
  width: 60,
  height: 60,
  initialPosition: Offset(100, 300),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
    ),
    child: const Center(
      child: Text('Tiny', style: TextStyle(color: Colors.white, fontSize: 10)),
    ),
  ),
)
```

### Small Box (80x80)
```dart
LiquidGlassBoxWidget(
  backgroundKey: backgroundKey,
  width: 80,
  height: 80,
  initialPosition: Offset(300, 100),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
    ),
    child: const Center(
      child: Text('Small', style: TextStyle(color: Colors.white, fontSize: 12)),
    ),
  ),
)
```

### Medium Box (120x120)
```dart
LiquidGlassBoxWidget(
  backgroundKey: backgroundKey,
  width: 120,
  height: 120,
  initialPosition: Offset(450, 150),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
    ),
    child: const Center(
      child: Text('Medium', style: TextStyle(color: Colors.white, fontSize: 16)),
    ),
  ),
)
```

### Large Box (200x200)
```dart
LiquidGlassBoxWidget(
  backgroundKey: backgroundKey,
  width: 200,
  height: 200,
  initialPosition: Offset(200, 300),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
    ),
    child: const Center(
      child: Text('Large', style: TextStyle(color: Colors.white, fontSize: 20)),
    ),
  ),
)
```

### Extra Large Box (300x150)
```dart
LiquidGlassBoxWidget(
  backgroundKey: backgroundKey,
  width: 300,
  height: 150,
  initialPosition: Offset(500, 350),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
    ),
    child: const Center(
      child: Text('Extra Large', style: TextStyle(color: Colors.white, fontSize: 18)),
    ),
  ),
)
```

## Customization Tips

### 1. Size Guidelines
- **Minimum size**: 40x40 pixels (smaller may not show liquid glass effect clearly)
- **Maximum size**: 500x500 pixels (larger may impact performance)
- **Recommended sizes**: 60x60, 80x80, 120x120, 160x160, 200x200

### 2. Position Guidelines
- Use `Offset(x, y)` where x and y are pixel coordinates
- Consider screen boundaries when positioning
- Leave space between multiple boxes to avoid overlap

### 3. Child Content
- Keep child content simple for best liquid glass effect visibility
- Use semi-transparent backgrounds with borders
- Match border radius to box size (smaller boxes = smaller radius)

### 4. Performance Considerations
- Each liquid glass box captures background independently
- More boxes = more background capture operations
- Consider limiting to 5-10 boxes maximum for smooth performance

## Border Radius Examples

### Small Radius (R10)
```dart
LiquidGlassBoxWidget(
  backgroundKey: backgroundKey,
  width: 120,
  height: 120,
  initialPosition: Offset(600, 300),
  borderRadius: 10.0,
  child: const Center(child: Text('R10')),
)
```

### Medium Radius (R20)
```dart
LiquidGlassBoxWidget(
  backgroundKey: backgroundKey,
  width: 80,
  height: 80,
  initialPosition: Offset(400, 100),
  borderRadius: 20.0,
  child: const Center(child: Text('R20')),
)
```

### Large Radius (R40)
```dart
LiquidGlassBoxWidget(
  backgroundKey: backgroundKey,
  width: 100,
  height: 100,
  initialPosition: Offset(500, 200),
  borderRadius: 40.0,
  child: const Center(child: Text('R40')),
)
```

### Very Large Radius (R50 - Almost Circle)
```dart
LiquidGlassBoxWidget(
  backgroundKey: backgroundKey,
  width: 100,
  height: 100,
  initialPosition: Offset(150, 500),
  borderRadius: 50.0,
  child: const Center(child: Text('R50')),
)
```

### Extra Large Radius (R60)
```dart
LiquidGlassBoxWidget(
  backgroundKey: backgroundKey,
  width: 120,
  height: 120,
  initialPosition: Offset(300, 400),
  borderRadius: 60.0,
  child: const Center(child: Text('R60')),
)
```

### Pill Shape (200x80, R40)
```dart
LiquidGlassBoxWidget(
  backgroundKey: backgroundKey,
  width: 200,
  height: 80,
  initialPosition: Offset(400, 500),
  borderRadius: 40.0,
  child: const Center(child: Text('Pill')),
)
```

## Implementation in Landing Page

The landing page now includes examples of all different sizes and border radius values:
- Original 160x160 box (AboutSectionWidget)
- Tiny 60x60 box
- Small 80x80 box  
- Medium 120x120 box
- Large 200x200 box
- Extra Large 300x150 box
- **R10**: 120x120 with small radius
- **R20**: 80x80 with medium radius
- **R40**: 100x100 with large radius
- **R50**: 100x100 almost circular
- **R60**: 120x120 extra large radius
- **Pill**: 200x80 pill shape

Each box is positioned at different locations and includes descriptive text labels showing the border radius value.
