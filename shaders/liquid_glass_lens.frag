#include <flutter/runtime_effect.glsl>

// Uniforms from Flutter
uniform vec2 uResolution;
uniform vec2 uMouse;
uniform float uEffectSize; // Controls the size of the lens effect (0.1 to 2.0 recommended)
uniform float uBlurIntensity; // Controls the blur strength (0.0 = no blur, 2.0 = heavy blur)
uniform float uDispersionStrength; // Add chromatic dispersion control
uniform sampler2D uTexture;

// Output
out vec4 fragColor;

void main() {
    // Get fragment coordinates
    vec2 fragCoord = FlutterFragCoord();

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / uResolution.xy;
    
    // WEB DEPLOYMENT FIX: Add boundary safety check
    // Ensure we're within valid texture coordinates
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 0.0); // Transparent outside bounds
        return;
    }

    // Calculate distance from mouse/center
    vec2 center = uMouse.xy / uResolution.xy;
    vec2 m2 = (uv - center);

    // Create rounded box effect - size controlled by uEffectSize
    float effectRadius = uEffectSize * 0.5;
    float sizeMultiplier = 1.0 / (effectRadius * effectRadius);
    
    // ENHANCED BOUNDARY CONTROL: Clamp the effect calculations
    float aspectRatio = uResolution.x / uResolution.y;
    float roundedBox = pow(abs(clamp(m2.x * aspectRatio, -1.0, 1.0)), 4.0) +
                      pow(abs(clamp(m2.y, -1.0, 1.0)), 4.0);

    // Calculate different zones of the effect with stricter bounds
    float baseIntensity = 100.0 * sizeMultiplier;
    float rb1 = clamp((1.0 - roundedBox * baseIntensity) * 8.0, 0.0, 1.0); // main lens
    float rb2 = clamp((0.95 - roundedBox * baseIntensity * 0.95) * 16.0, 0.0, 1.0) -
                clamp(pow(0.9 - roundedBox * baseIntensity * 0.95, 1.0) * 16.0, 0.0, 1.0); // borders
    float rb3 = clamp((1.5 - roundedBox * baseIntensity * 1.1) * 2.0, 0.0, 1.0) -
                clamp(pow(1.0 - roundedBox * baseIntensity * 1.1, 1.0) * 2.0, 0.0, 1.0); // shadow

    fragColor = vec4(0.0);

    if (rb1 + rb2 > 0.0) {
        // Lens distortion effect
        float distortionStrength = 50.0 * sizeMultiplier;
        vec2 lens = ((uv - 0.5) * (1.0 - roundedBox * distortionStrength) + 0.5);
        
        // WEB SAFETY: Clamp lens coordinates to valid texture bounds
        lens = clamp(lens, vec2(0.001), vec2(0.999));

        // Enhanced chromatic dispersion calculation
        vec2 dir = normalize(m2);
        float dispersionScale = uDispersionStrength * 0.05;

        // Create edge mask based on distance from center
        float dispersionMask = smoothstep(0.3, 0.7, roundedBox * baseIntensity);

        // Apply mask to dispersion offsets with boundary safety
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
                    // SAFE TEXTURE SAMPLING: Clamp all coordinates
                    vec2 redCoord = clamp(lens + offset + redOffset, vec2(0.001), vec2(0.999));
                    vec2 greenCoord = clamp(lens + offset + greenOffset, vec2(0.001), vec2(0.999));
                    vec2 blueCoord = clamp(lens + offset + blueOffset, vec2(0.001), vec2(0.999));
                    
                    colorSum.r += texture(uTexture, redCoord).r;
                    colorSum.g += texture(uTexture, greenCoord).g;
                    colorSum.b += texture(uTexture, blueCoord).b;
                    total += 1.0;
                }
            }
            colorResult = vec4(colorSum / total, 1.0);
        } else {
            // Enhanced single sample with directional offsets and safety clamping
            vec2 redCoord = clamp(lens + redOffset, vec2(0.001), vec2(0.999));
            vec2 greenCoord = clamp(lens + greenOffset, vec2(0.001), vec2(0.999));
            vec2 blueCoord = clamp(lens + blueOffset, vec2(0.001), vec2(0.999));
            
            colorResult.r = texture(uTexture, redCoord).r;
            colorResult.g = texture(uTexture, greenCoord).g;
            colorResult.b = texture(uTexture, blueCoord).b;
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

    } else {
        fragColor = texture(uTexture, uv);
    }
}