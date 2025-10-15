# Liquid Glass Shader Guide

## Overview

The Liquid Glass effect is created using a custom fragment shader written in GLSL (OpenGL Shading Language). This guide explains the shader implementation, parameters, and how to customize the effect.

## Shader File Structure

```
shaders/
└── liquid_glass_lens.frag    # Fragment shader source code
```

## Fragment Shader Analysis

### Header and Includes

```glsl
#include <flutter/runtime_effect.glsl>
```

This include provides Flutter-specific GLSL functions and variables, including:
- `FlutterFragCoord()`: Gets fragment coordinates
- Flutter's uniform binding system
- Platform-specific optimizations

### Uniform Declarations

```glsl
uniform vec2 uResolution;        // Screen resolution (width, height)
uniform vec2 uMouse;             // Mouse/center position (x, y)
uniform float uEffectSize;       // Lens size multiplier (0.1-2.0)
uniform float uBlurIntensity;   // Blur strength (0.0-2.0)
uniform float uDispersionStrength; // Chromatic dispersion (0.0-1.0)
uniform sampler2D uTexture;     // Background texture sampler
```

### Shader Algorithm Breakdown

#### 1. Coordinate Setup
```glsl
vec2 fragCoord = FlutterFragCoord();
vec2 uv = fragCoord / uResolution.xy;
```
- Gets current fragment coordinates
- Normalizes coordinates to 0-1 range

#### 2. Distance Calculation
```glsl
vec2 center = uMouse.xy / uResolution.xy;
vec2 m2 = (uv - center);
```
- Calculates distance from lens center
- Normalizes mouse position to UV space

#### 3. Rounded Box Effect
```glsl
float effectRadius = uEffectSize * 0.5;
float sizeMultiplier = 1.0 / (effectRadius * effectRadius);
float roundedBox = pow(abs(m2.x * uResolution.x / uResolution.y), 4.0) +
                  pow(abs(m2.y), 4.0);
```
- Creates a lens-shaped distortion area
- Uses power of 4 for smooth rounded corners
- Accounts for aspect ratio

#### 4. Effect Zones
```glsl
float baseIntensity = 100.0 * sizeMultiplier;
float rb1 = clamp((1.0 - roundedBox * baseIntensity) * 8.0, 0.0, 1.0); // main lens
float rb2 = clamp((0.95 - roundedBox * baseIntensity * 0.95) * 16.0, 0.0, 1.0) -
            clamp(pow(0.9 - roundedBox * baseIntensity * 0.95, 1.0) * 16.0, 0.0, 1.0); // borders
float rb3 = clamp((1.5 - roundedBox * baseIntensity * 1.1) * 2.0, 0.0, 1.0) -
            clamp(pow(1.0 - roundedBox * baseIntensity * 1.1, 1.0) * 2.0, 0.0, 1.0); // shadow
```
- **rb1**: Main lens distortion area
- **rb2**: Lens border/highlight effect
- **rb3**: Shadow/depth effect

#### 5. Lens Distortion
```glsl
float distortionStrength = 50.0 * sizeMultiplier;
vec2 lens = ((uv - 0.5) * (1.0 - roundedBox * distortionStrength) + 0.5);
```
- Applies curved lens distortion
- Creates magnifying glass effect
- Distortion strength scales with lens size

#### 6. Chromatic Dispersion
```glsl
vec2 dir = normalize(m2);
float dispersionScale = uDispersionStrength * 0.05;
float dispersionMask = smoothstep(0.3, 0.7, roundedBox * baseIntensity);

vec2 redOffset = dir * dispersionScale * 2.0 * dispersionMask;
vec2 greenOffset = dir * dispersionScale * 1.0 * dispersionMask;
vec2 blueOffset = dir * dispersionScale * -1.5 * dispersionMask;
```
- Separates RGB channels for realistic glass effect
- Different offset amounts for each color channel
- Uses smoothstep for edge masking

#### 7. Blur Sampling
```glsl
if (uBlurIntensity > 0.0) {
    float blurRadius = uBlurIntensity / max(uResolution.x, uResolution.y);
    float total = 0.0;
    vec3 colorSum = vec3(0.0);
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x, y) * blurRadius;
            colorSum.r += texture(uTexture, lens + offset + redOffset).r;
            colorSum.g += texture(uTexture, lens + offset + greenOffset).g;
            colorSum.b += texture(uTexture, lens + offset + blueOffset).b;
            total += 1.0;
        }
    }
    colorResult = vec4(colorSum / total, 1.0);
}
```
- 5x5 blur sampling for soft focus
- Applies chromatic dispersion to each sample
- Normalizes by sample count

#### 8. Lighting Effects
```glsl
float gradient = clamp((clamp(m2.y, 0.0, 0.2) + 0.1) / 2.0, 0.0, 1.0) +
                clamp((clamp(-m2.y, -1000.0, 0.2) * rb3 + 0.1) / 2.0, 0.0, 1.0);
```
- Creates realistic lighting gradient
- Simulates light refraction in glass
- Adds depth and dimension

#### 9. Final Composition
```glsl
fragColor = mix(
    texture(uTexture, uv),
    colorResult,
    rb1
);
fragColor = clamp(fragColor + vec4(rb2 * 0.3) + vec4(gradient * 0.2), 0.0, 1.0);
```
- Blends original texture with lens effect
- Adds border highlights and lighting
- Clamps to valid color range

## Parameter Tuning

### Effect Size (uEffectSize)
- **Range**: 0.1 - 2.0
- **Default**: 5.0
- **Effect**: Controls lens size and distortion strength
- **Usage**: Larger values = bigger lens, more distortion

### Blur Intensity (uBlurIntensity)
- **Range**: 0.0 - 2.0
- **Default**: 0.0 (no blur)
- **Effect**: Adds soft focus to the lens
- **Usage**: Higher values = more blur, softer edges

### Dispersion Strength (uDispersionStrength)
- **Range**: 0.0 - 1.0
- **Default**: 0.4
- **Effect**: Controls chromatic dispersion (rainbow effect)
- **Usage**: Higher values = more color separation

## Custom Shader Development

### Creating a New Effect

1. **Create Fragment Shader**:
```glsl
// shaders/my_effect.frag
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform sampler2D uTexture;
out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord() / uResolution.xy;
    fragColor = texture(uTexture, uv);
}
```

2. **Implement Shader Class**:
```dart
class MyCustomShader extends BaseShader {
  MyCustomShader() : super(shaderAssetPath: 'shaders/my_effect.frag');
  
  @override
  void updateShaderUniforms({
    required double width,
    required double height,
    required ui.Image? backgroundImage,
  }) {
    if (!isLoaded) return;
    
    shader.setFloat(0, width);
    shader.setFloat(1, height);
    
    if (backgroundImage != null) {
      shader.setImageSampler(0, backgroundImage);
    }
  }
}
```

### Advanced Shader Techniques

#### 1. Multiple Texture Sampling
```glsl
uniform sampler2D uTexture1;
uniform sampler2D uTexture2;

// In main():
vec4 color1 = texture(uTexture1, uv);
vec4 color2 = texture(uTexture2, uv);
fragColor = mix(color1, color2, 0.5);
```

#### 2. Time-Based Animation
```glsl
uniform float uTime;

// In main():
float wave = sin(uv.x * 10.0 + uTime) * 0.1;
vec2 distortedUV = uv + vec2(wave, 0.0);
fragColor = texture(uTexture, distortedUV);
```

#### 3. Noise Functions
```glsl
float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

// In main():
float n = noise(uv * 10.0);
fragColor = texture(uTexture, uv + vec2(n * 0.1));
```

## Performance Optimization

### Shader Optimization Tips

1. **Minimize Texture Lookups**:
   - Cache texture samples when possible
   - Use texture coordinates efficiently

2. **Optimize Loops**:
   - Unroll small loops when possible
   - Use constant loop bounds

3. **Reduce Precision**:
   - Use `mediump` for non-critical calculations
   - Reserve `highp` for final color calculations

4. **Conditional Execution**:
   - Use early returns for edge cases
   - Minimize branching in hot paths

### Example Optimized Shader

```glsl
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uEffectSize;
uniform sampler2D uTexture;
out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord() / uResolution.xy;
    
    // Early exit for pixels outside effect area
    float dist = length(uv - 0.5);
    if (dist > uEffectSize) {
        fragColor = texture(uTexture, uv);
        return;
    }
    
    // Optimized effect calculation
    vec2 lens = (uv - 0.5) * (1.0 - dist * 2.0) + 0.5;
    fragColor = texture(uTexture, lens);
}
```

## Debugging Shaders

### Common Issues

1. **Compilation Errors**:
   - Check GLSL syntax
   - Verify uniform declarations
   - Ensure proper includes

2. **Runtime Errors**:
   - Validate uniform values
   - Check texture binding
   - Verify coordinate calculations

3. **Visual Artifacts**:
   - Check UV coordinate ranges
   - Validate color clamping
   - Verify aspect ratio handling

### Debug Techniques

1. **Visual Debugging**:
```glsl
// Show UV coordinates as colors
fragColor = vec4(uv, 0.0, 1.0);

// Show distance as grayscale
float dist = length(uv - 0.5);
fragColor = vec4(vec3(dist), 1.0);
```

2. **Uniform Validation**:
```dart
// In your shader class
void updateShaderUniforms({...}) {
  if (!isLoaded) return;
  
  // Validate parameters
  assert(width > 0 && height > 0, 'Invalid dimensions');
  assert(backgroundImage != null, 'Background image required');
  
  // Set uniforms with error handling
  try {
    shader.setFloat(0, width);
    shader.setFloat(1, height);
  } catch (e) {
    debugPrint('Uniform error: $e');
  }
}
```

## Platform Considerations

### Mobile (Android/iOS)
- Use `mediump` precision for better performance
- Limit texture size for memory efficiency
- Test on various device capabilities

### Web
- Ensure WebGL 2.0 compatibility
- Use fallbacks for older browsers
- Consider texture size limits

### Desktop
- Take advantage of higher precision
- Use more complex effects
- Consider multi-sampling for quality

## Best Practices

1. **Code Organization**:
   - Comment complex calculations
   - Use meaningful variable names
   - Group related operations

2. **Performance**:
   - Profile on target devices
   - Use appropriate precision
   - Optimize hot paths

3. **Compatibility**:
   - Test across platforms
   - Provide fallbacks
   - Handle edge cases

4. **Maintainability**:
   - Document parameters
   - Use consistent naming
   - Version your shaders
