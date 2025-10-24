#include <flutter/runtime_effect.glsl>

// Simple test shader without texture dependency
uniform vec2 uResolution;
uniform vec2 uMouse;
uniform float uEffectSize;
uniform float uBlurIntensity;
uniform float uDispersionStrength;
uniform float uGlassIntensity;

// Output
out vec4 fragColor;

void main() {
    // Get fragment coordinates
    vec2 fragCoord = FlutterFragCoord();
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / uResolution.xy;
    
    // Calculate distance from mouse/center
    vec2 center = uMouse.xy / uResolution.xy;
    vec2 m2 = (uv - center);
    
    // Create a simple liquid glass effect without texture
    float effectRadius = uEffectSize * 0.5;
    float sizeMultiplier = 1.0 / (effectRadius * effectRadius);
    float roundedBox = pow(abs(m2.x * uResolution.x / uResolution.y), 4.0) +
                      pow(abs(m2.y), 4.0);
    
    // Calculate different zones of the effect
    float baseIntensity = 100.0 * sizeMultiplier;
    float rb1 = clamp((1.0 - roundedBox * baseIntensity) * 8.0, 0.0, 1.0);
    
    // Create a colorful liquid glass effect
    vec3 baseColor = vec3(0.1, 0.2, 0.4); // Dark blue base
    vec3 glassColor = vec3(0.8, 0.9, 1.0); // Light blue glass
    
    // Add some animated color variation
    float time = uGlassIntensity * 10.0;
    vec3 animatedColor = vec3(
        0.5 + 0.5 * sin(time + uv.x * 10.0),
        0.5 + 0.5 * sin(time + uv.y * 10.0 + 2.0),
        0.5 + 0.5 * sin(time + (uv.x + uv.y) * 5.0 + 4.0)
    );
    
    // Mix colors based on effect
    vec3 finalColor = mix(baseColor, glassColor * animatedColor, rb1 * uGlassIntensity);
    
    // Add some brightness variation
    float brightness = 0.5 + 0.5 * sin(roundedBox * 20.0);
    finalColor *= brightness;
    
    fragColor = vec4(finalColor, 0.8); // Semi-transparent
}
