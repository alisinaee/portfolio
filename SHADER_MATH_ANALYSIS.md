# Liquid Glass Shader Mathematical Analysis

## Mathematical Relationships Between Parameters and Visual Output

### 1. **Effect Size (uEffectSize) → Visual Radius**

**Formula:**
```
effectRadius = uEffectSize * 0.5
sizeMultiplier = 1.0 / (effectRadius * effectRadius)
baseIntensity = 100.0 * sizeMultiplier
```

**Mathematical Relationship:**
- **Inverse Square Law**: `sizeMultiplier = 4 / (uEffectSize²)`
- **Effect Radius**: `R = uEffectSize * 0.5`
- **Intensity**: `I = 100 * 4 / (uEffectSize²) = 400 / (uEffectSize²)`

**Prediction Formula:**
```
Visual_Radius = uEffectSize * 0.5
Effect_Intensity = 400 / (uEffectSize²)
```

### 2. **Dispersion Strength (uDispersionStrength) → Chromatic Aberration**

**Formula:**
```
dispersionScale = uDispersionStrength * 0.05
redOffset = dir * dispersionScale * 2.0 * dispersionMask
greenOffset = dir * dispersionScale * 1.0 * dispersionMask  
blueOffset = dir * dispersionScale * -1.5 * dispersionMask
```

**Mathematical Relationship:**
- **Red Channel**: `offset = direction * uDispersionStrength * 0.1 * mask`
- **Green Channel**: `offset = direction * uDispersionStrength * 0.05 * mask`
- **Blue Channel**: `offset = direction * uDispersionStrength * -0.075 * mask`

**Prediction Formula:**
```
Chromatic_Separation = uDispersionStrength * 0.05 * distance_from_center
Red_Offset = 2.0 * Chromatic_Separation
Green_Offset = 1.0 * Chromatic_Separation
Blue_Offset = -1.5 * Chromatic_Separation
```

### 3. **Blur Intensity (uBlurIntensity) → Blur Radius**

**Formula:**
```
blurRadius = uBlurIntensity / max(uResolution.x, uResolution.y)
```

**Mathematical Relationship:**
- **Normalized Blur**: `blurRadius = uBlurIntensity / max(width, height)`
- **Sample Count**: `5x5 = 25 samples` (fixed)
- **Blur Quality**: Higher `uBlurIntensity` = more blur

**Prediction Formula:**
```
Blur_Radius = uBlurIntensity / max(width, height)
Blur_Quality = 25 samples (5x5 grid)
```

### 4. **Distance from Center → Effect Zones**

**Formula:**
```
roundedBox = pow(abs(m2.x * uResolution.x / uResolution.y), 4.0) + pow(abs(m2.y), 4.0)
rb1 = clamp((1.0 - roundedBox * baseIntensity) * 8.0, 0.0, 1.0) // main lens
rb2 = clamp((0.95 - roundedBox * baseIntensity * 0.95) * 16.0, 0.0, 1.0) // borders
rb3 = clamp((1.5 - roundedBox * baseIntensity * 1.1) * 2.0, 0.0, 1.0) // shadow
```

**Mathematical Relationship:**
- **Distance Function**: `d = (|x|⁴ + |y|⁴)^(1/4)` (L4 norm)
- **Main Lens**: `rb1 = max(0, min(1, (1 - d² * I) * 8))`
- **Borders**: `rb2 = max(0, min(1, (0.95 - d² * I * 0.95) * 16))`
- **Shadow**: `rb3 = max(0, min(1, (1.5 - d² * I * 1.1) * 2))`

**Prediction Formula:**
```
Distance = (|x|⁴ + |y|⁴)^(1/4)
Main_Lens_Strength = clamp((1 - Distance² * 400/uEffectSize²) * 8, 0, 1)
Border_Strength = clamp((0.95 - Distance² * 400/uEffectSize² * 0.95) * 16, 0, 1)
Shadow_Strength = clamp((1.5 - Distance² * 400/uEffectSize² * 1.1) * 2, 0, 1)
```

### 5. **Distortion Strength → Lens Effect**

**Formula:**
```
distortionStrength = 50.0 * sizeMultiplier
lens = ((uv - 0.5) * (1.0 - roundedBox * distortionStrength) + 0.5)
```

**Mathematical Relationship:**
- **Distortion Factor**: `D = 50 * 4 / (uEffectSize²) = 200 / (uEffectSize²)`
- **Lens Transformation**: `lens = center + (uv - center) * (1 - distance² * D)`

**Prediction Formula:**
```
Distortion_Strength = 200 / (uEffectSize²)
Lens_UV = center + (original_UV - center) * (1 - distance² * Distortion_Strength)
```

## **Complete Prediction Formula**

For any point (x, y) with parameters (effectSize, dispersionStrength, blurIntensity):

```
1. Calculate distance: d = (|x|⁴ + |y|⁴)^(1/4)
2. Calculate intensity: I = 400 / (effectSize²)
3. Calculate zones:
   - Main lens: rb1 = clamp((1 - d² * I) * 8, 0, 1)
   - Borders: rb2 = clamp((0.95 - d² * I * 0.95) * 16, 0, 1)
   - Shadow: rb3 = clamp((1.5 - d² * I * 1.1) * 2, 0, 1)
4. Calculate chromatic offsets:
   - Red: offset = direction * dispersionStrength * 0.1 * mask
   - Green: offset = direction * dispersionStrength * 0.05 * mask
   - Blue: offset = direction * dispersionStrength * -0.075 * mask
5. Calculate blur: blurRadius = blurIntensity / max(width, height)
6. Final effect: mix(original, distorted, rb1) + borders + shadow
```

## **Practical Predictions**

### **Effect Size Predictions:**
- `uEffectSize = 1.0` → Very large effect, low intensity
- `uEffectSize = 5.0` → Medium effect, medium intensity  
- `uEffectSize = 10.0` → Small effect, high intensity

### **Dispersion Predictions:**
- `uDispersionStrength = 0.1` → Subtle chromatic aberration
- `uDispersionStrength = 0.4` → Moderate rainbow effect
- `uDispersionStrength = 1.0` → Strong chromatic separation

### **Blur Predictions:**
- `uBlurIntensity = 0.0` → No blur, sharp edges
- `uBlurIntensity = 0.5` → Light blur
- `uBlurIntensity = 2.0` → Heavy blur

## **Optimization Recommendations**

1. **For subtle effects**: `effectSize = 8-10, dispersionStrength = 0.2-0.3`
2. **For dramatic effects**: `effectSize = 3-5, dispersionStrength = 0.6-0.8`
3. **For performance**: Lower `blurIntensity`, higher `effectSize`
4. **For quality**: Higher `blurIntensity`, lower `effectSize`
