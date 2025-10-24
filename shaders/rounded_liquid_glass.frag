#include <flutter/runtime_effect.glsl>

// Uniforms from Flutter (matching original shader layout)
uniform vec2 uResolution;
uniform vec2 uMouse;
uniform float uEffectSize;
uniform float uBlurIntensity;
uniform float uDispersionStrength;
uniform float uBorderRadius;
uniform sampler2D uTexture;

// Output
out vec4 fragColor;

// Function to create rounded rectangle distance field
float roundedBoxSDF(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void main() {
    // Get fragment coordinates
    vec2 fragCoord = FlutterFragCoord();
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / uResolution.xy;
    
    // Calculate center of the widget in normalized coordinates
    vec2 center = vec2(0.5, 0.5);
    
    // Calculate half size of the widget in normalized coordinates
    vec2 halfSize = vec2(uResolution.x / uResolution.y, 1.0) * 0.5;
    vec2 boxSize = halfSize - vec2(uBorderRadius / uResolution.x, uBorderRadius / uResolution.y);
    
    // Position relative to the center of the widget
    vec2 p = uv - center;
    
    // Scale p to match aspect ratio for consistent rounding
    p.x *= uResolution.x / uResolution.y;
    
    // Calculate distance from the rounded box
    float dist = roundedBoxSDF(p, boxSize, uBorderRadius / uResolution.y);
    
    // Create a mask for the rounded box with smooth edges
    float roundedBoxMask = smoothstep(0.0, fwidth(dist), -dist);
    
    // Only apply effect inside the rounded box
    if (roundedBoxMask > 0.0) {
        // Calculate distance from mouse/center for lens effect
        vec2 mousePos = uMouse.xy / uResolution.xy;
        vec2 m2 = (uv - mousePos);
        
        // Create lens effect with size control
        float effectRadius = uEffectSize * 0.5;
        float sizeMultiplier = 1.0 / (effectRadius * effectRadius);
        float roundedBoxEffect = pow(abs(m2.x * uResolution.x / uResolution.y), 4.0) +
                                 pow(abs(m2.y), 4.0);
        
        // Calculate different zones of the effect
        float baseIntensity = 100.0 * sizeMultiplier;
        float rb1 = clamp((1.0 - roundedBoxEffect * baseIntensity) * 8.0, 0.0, 1.0);
        float rb2 = clamp((0.95 - roundedBoxEffect * baseIntensity * 0.95) * 16.0, 0.0, 1.0) -
                     clamp(pow(0.9 - roundedBoxEffect * baseIntensity * 0.95, 1.0) * 16.0, 0.0, 1.0);
        float rb3 = clamp((1.5 - roundedBoxEffect * baseIntensity * 1.1) * 2.0, 0.0, 1.0) -
                     clamp(pow(1.0 - roundedBoxEffect * baseIntensity * 1.1, 1.0) * 2.0, 0.0, 1.0);
        
        // Lens distortion effect
        float distortionStrength = 50.0 * sizeMultiplier;
        vec2 lens = ((uv - 0.5) * (1.0 - roundedBoxEffect * distortionStrength) + 0.5);
        
        // Enhanced chromatic dispersion calculation
        vec2 dir = normalize(m2);
        float dispersionScale = uDispersionStrength * 0.05;
        
        // Create edge mask based on distance from center
        float dispersionMask = smoothstep(0.3, 0.7, roundedBoxEffect * baseIntensity);
        
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
                         clamp((clamp(-m2.y, -1000.0, 0.2) * rb3 + 0.1) / 2.0, 0.0, 1.0);
        
        // Combine all effects
        fragColor = mix(
            texture(uTexture, uv),
            colorResult,
            rb1
        );
        fragColor = clamp(fragColor + vec4(rb2 * 0.3) + vec4(gradient * 0.2), 0.0, 1.0);
        
        // Apply the rounded box mask to the final color
        fragColor *= roundedBoxMask;
        
    } else {
        // Outside the rounded box, just sample the background texture
        fragColor = texture(uTexture, uv);
    }
}