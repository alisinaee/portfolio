#include <flutter/runtime_effect.glsl>

// Uniforms for entire surface liquid glass effect
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
    
    // Sample the background texture
    vec4 backgroundColor = texture(uTexture, uv);
    
    // Create subtle distortion across the entire surface
    vec2 distortion = vec2(
        sin(uv.x * 10.0 + uv.y * 8.0) * 0.02,
        sin(uv.x * 12.0 - uv.y * 9.0) * 0.02
    );
    
    // Add mouse influence
    vec2 mousePos = uMouse.xy / uResolution.xy;
    vec2 mouseDistortion = (uv - mousePos) * 0.05 * uGlassIntensity;
    
    // Combine distortions
    vec2 totalDistortion = distortion + mouseDistortion;
    vec2 distortedUV = uv + totalDistortion;
    
    // Clamp to valid texture coordinates
    distortedUV = clamp(distortedUV, 0.0, 1.0);
    
    // Sample with distortion
    vec4 distortedColor = texture(uTexture, distortedUV);
    
    // Add subtle glass tinting
    vec3 glassTint = vec3(0.9, 0.95, 1.0);
    distortedColor.rgb = mix(distortedColor.rgb, distortedColor.rgb * glassTint, uGlassIntensity * 0.3);
    
    // Add brightness variation
    float brightness = 0.8 + 0.2 * sin(uv.x * 15.0) * sin(uv.y * 12.0);
    distortedColor.rgb *= brightness;
    
    fragColor = distortedColor;
}
