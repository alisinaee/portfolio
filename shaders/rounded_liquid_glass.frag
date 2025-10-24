#include <flutter/runtime_effect.glsl>

// Uniforms from Flutter
uniform vec2 uResolution;
uniform vec2 uMouse;
uniform float uEffectSize; // Controls the size of the lens effect (0.1 to 2.0 recommended)
uniform float uBlurIntensity; // Controls the blur strength (0.0 = no blur, 2.0 = heavy blur)
uniform float uDispersionStrength; // Add chromatic dispersion control
uniform float uBorderRadius; // Border radius for rounded rectangles
uniform sampler2D uTexture;

// Output
out vec4 fragColor;

// Function to create rounded rectangle distance field
float roundedBoxSDF(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

// Function to create smooth rounded rectangle mask
float roundedBoxMask(vec2 uv, vec2 size, float radius) {
    vec2 center = vec2(0.5, 0.5);
    vec2 p = (uv - center) * 2.0; // Convert to [-1, 1] range
    vec2 boxSize = size * 0.5; // Half size for distance calculation
    
    float distance = roundedBoxSDF(p, boxSize, radius);
    return 1.0 - smoothstep(0.0, 0.02, distance);
}

void main() {
    // Get fragment coordinates
    vec2 fragCoord = FlutterFragCoord();
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / uResolution.xy;
    
    // Calculate box dimensions and border radius
    vec2 boxSize = vec2(1.0, 1.0); // Full size by default
    float radius = uBorderRadius / min(uResolution.x, uResolution.y); // Normalize radius
    
    // Create rounded rectangle mask
    float mask = roundedBoxMask(uv, boxSize, radius);
    
    // Only apply liquid glass effect inside the rounded rectangle
    if (mask > 0.0) {
        // Calculate distance from center for distortion
        vec2 center = vec2(0.5, 0.5);
        vec2 m2 = (uv - center);
        float dist = length(m2);
        
        // Create lens distortion effect
        float effectRadius = uEffectSize * 0.5;
        float distortionStrength = 50.0 * (1.0 / (effectRadius * effectRadius));
        
        // Apply distortion only within the rounded rectangle
        vec2 lens = ((uv - center) * (1.0 - dist * distortionStrength * mask) + center);
        
        // Enhanced chromatic dispersion calculation
        vec2 dir = normalize(m2);
        float dispersionScale = uDispersionStrength * 0.05;
        
        // Create edge mask based on distance from center
        float dispersionMask = smoothstep(0.3, 0.7, dist * 4.0) * mask;
        
        // Apply mask to dispersion offsets
        vec2 redOffset = dir * dispersionScale * 2.0 * dispersionMask;
        vec2 greenOffset = dir * dispersionScale * 1.0 * dispersionMask;
        vec2 blueOffset = dir * dispersionScale * -1.5 * dispersionMask;
        
        vec4 colorResult = vec4(0.0);
        
        // Blur sampling with enhanced chromatic dispersion
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
        } else {
            // Enhanced single sample with directional offsets
            colorResult.r = texture(uTexture, lens + redOffset).r;
            colorResult.g = texture(uTexture, lens + greenOffset).g;
            colorResult.b = texture(uTexture, lens + blueOffset).b;
            colorResult.a = 1.0;
        }
        
        // Add lighting effects
        float gradient = clamp((clamp(m2.y, 0.0, 0.2) + 0.1) / 2.0, 0.0, 1.0) +
                        clamp((clamp(-m2.y, -1000.0, 0.2) + 0.1) / 2.0, 0.0, 1.0);
        
        // Combine all effects with mask
        fragColor = mix(
            texture(uTexture, uv),
            colorResult,
            mask
        );
        fragColor = clamp(fragColor + vec4(mask * 0.3) + vec4(gradient * 0.2 * mask), 0.0, 1.0);
        
    } else {
        // Outside the rounded rectangle, show original texture
        fragColor = texture(uTexture, uv);
    }
}
