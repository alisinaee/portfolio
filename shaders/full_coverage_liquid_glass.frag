#include <flutter/runtime_effect.glsl>

// Uniforms for full-coverage liquid glass effect
uniform vec2 uResolution;
uniform vec2 uMouse;
uniform float uEffectSize;
uniform float uBlurIntensity;
uniform float uDispersionStrength;
uniform float uGlassIntensity;
uniform sampler2D uTexture;

// Output
out vec4 fragColor;

void main() {
    // Get fragment coordinates
    vec2 fragCoord = FlutterFragCoord();
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / uResolution.xy;
    
    // Calculate distance from mouse position
    vec2 mousePos = uMouse.xy / uResolution.xy;
    vec2 dist = uv - mousePos;
    float distanceFromMouse = length(dist);
    
    // Create a smooth falloff based on distance from mouse
    // This creates a more natural liquid glass effect across the entire surface
    float mouseInfluence = 1.0 - smoothstep(0.0, 0.5, distanceFromMouse);
    
    // Base distortion strength - apply to entire surface with mouse influence
    float baseDistortion = uGlassIntensity * 0.1;
    float distortionStrength = baseDistortion * (0.5 + 0.5 * mouseInfluence);
    
    // Create subtle wave distortion across the entire surface
    float wave1 = sin(uv.x * 20.0 + uv.y * 15.0) * 0.01;
    float wave2 = sin(uv.x * 30.0 - uv.y * 25.0) * 0.008;
    float wave3 = sin(uv.x * 40.0 + uv.y * 35.0) * 0.006;
    
    // Combine waves for organic distortion
    vec2 waveDistortion = vec2(
        wave1 + wave2 + wave3,
        wave1 - wave2 + wave3
    ) * distortionStrength;
    
    // Add mouse-based distortion
    vec2 mouseDistortion = dist * 0.02 * mouseInfluence * uGlassIntensity;
    
    // Final distortion vector
    vec2 totalDistortion = waveDistortion + mouseDistortion;
    
    // Apply distortion to UV coordinates
    vec2 distortedUV = uv + totalDistortion;
    
    // Clamp to valid texture coordinates
    distortedUV = clamp(distortedUV, 0.0, 1.0);
    
    // Sample the background texture with distortion
    vec4 backgroundColor = texture(uTexture, distortedUV);
    
    // Add chromatic aberration effect across the entire surface
    if (uDispersionStrength > 0.0) {
        vec2 aberrationOffset = normalize(dist) * uDispersionStrength * 0.01;
        
        float red = texture(uTexture, distortedUV + aberrationOffset).r;
        float green = texture(uTexture, distortedUV).g;
        float blue = texture(uTexture, distortedUV - aberrationOffset).b;
        
        backgroundColor = vec4(red, green, blue, backgroundColor.a);
    }
    
    // Add subtle blur effect across the entire surface
    if (uBlurIntensity > 0.0) {
        float blurRadius = uBlurIntensity * 0.005;
        vec4 blurColor = vec4(0.0);
        float totalWeight = 0.0;
        
        // Simple blur sampling
        for (float x = -1.0; x <= 1.0; x += 1.0) {
            for (float y = -1.0; y <= 1.0; y += 1.0) {
                vec2 offset = vec2(x, y) * blurRadius;
                vec2 sampleUV = clamp(distortedUV + offset, 0.0, 1.0);
                float weight = 1.0 / (1.0 + length(offset) * 10.0);
                blurColor += texture(uTexture, sampleUV) * weight;
                totalWeight += weight;
            }
        }
        
        if (totalWeight > 0.0) {
            backgroundColor = mix(backgroundColor, blurColor / totalWeight, uBlurIntensity * 0.3);
        }
    }
    
    // Add subtle glass-like tinting across the entire surface
    vec3 glassTint = vec3(0.9, 0.95, 1.0); // Slight blue tint
    backgroundColor.rgb = mix(backgroundColor.rgb, backgroundColor.rgb * glassTint, uGlassIntensity * 0.2);
    
    // Add subtle brightness variation based on position
    float brightnessVariation = 0.8 + 0.2 * sin(uv.x * 10.0) * sin(uv.y * 8.0);
    backgroundColor.rgb *= brightnessVariation;
    
    // Add mouse-based highlight
    float mouseHighlight = 1.0 + 0.3 * mouseInfluence * uGlassIntensity;
    backgroundColor.rgb *= mouseHighlight;
    
    fragColor = backgroundColor;
}
