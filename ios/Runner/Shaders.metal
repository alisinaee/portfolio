#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct LiquidGlassUniforms {
    float2 resolution;
    float2 mouse;
    float effectSize;
    float blurIntensity;
    float dispersionStrength;
    float glassIntensity;
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = in.position;
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                            texture2d<float> inputTexture [[texture(0)]],
                            constant LiquidGlassUniforms& uniforms [[buffer(0)]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    float2 fragCoord = in.texCoord * uniforms.resolution;
    float2 uv = fragCoord / uniforms.resolution;
    float2 center = uniforms.mouse / uniforms.resolution;
    float2 m2 = (uv - center);
    
    // Create rounded box effect
    float effectRadius = uniforms.effectSize * 0.5;
    float sizeMultiplier = 1.0 / (effectRadius * effectRadius);
    float roundedBox = pow(abs(m2.x * uniforms.resolution.x / uniforms.resolution.y), 4.0) +
                      pow(abs(m2.y), 4.0);
    
    // Calculate different zones
    float baseIntensity = 100.0 * sizeMultiplier;
    float rb1 = clamp((1.0 - roundedBox * baseIntensity) * 8.0, 0.0, 1.0);
    float rb2 = clamp((0.95 - roundedBox * baseIntensity * 0.95) * 16.0, 0.0, 1.0) -
                clamp(pow(0.9 - roundedBox * baseIntensity * 0.95, 1.0) * 16.0, 0.0, 1.0);
    float rb3 = clamp((1.5 - roundedBox * baseIntensity * 1.1) * 2.0, 0.0, 1.0) -
                clamp(pow(1.0 - roundedBox * baseIntensity * 1.1, 1.0) * 2.0, 0.0, 1.0);
    
    float4 colorResult = inputTexture.sample(textureSampler, uv);
    
    if (rb1 + rb2 > 0.0) {
        // Lens distortion effect
        float distortionStrength = 50.0 * sizeMultiplier;
        float2 lens = ((uv - 0.5) * (1.0 - roundedBox * distortionStrength) + 0.5);
        
        // Enhanced chromatic dispersion
        float2 dir = normalize(m2);
        float dispersionScale = uniforms.dispersionStrength * 0.05;
        float dispersionMask = smoothstep(0.3, 0.7, roundedBox * baseIntensity);
        
        float2 redOffset = dir * dispersionScale * 2.0 * dispersionMask;
        float2 greenOffset = dir * dispersionScale * 1.0 * dispersionMask;
        float2 blueOffset = dir * dispersionScale * -1.5 * dispersionMask;
        
        // Blur sampling with chromatic dispersion
        if (uniforms.blurIntensity > 0.0) {
            float blurRadius = uniforms.blurIntensity / max(uniforms.resolution.x, uniforms.resolution.y);
            float3 colorSum = float3(0.0);
            float total = 0.0;
            for (float x = -2.0; x <= 2.0; x += 1.0) {
                for (float y = -2.0; y <= 2.0; y += 1.0) {
                    float2 offset = float2(x, y) * blurRadius;
                    colorSum.r += inputTexture.sample(textureSampler, lens + offset + redOffset).r;
                    colorSum.g += inputTexture.sample(textureSampler, lens + offset + greenOffset).g;
                    colorSum.b += inputTexture.sample(textureSampler, lens + offset + blueOffset).b;
                    total += 1.0;
                }
            }
            colorResult = float4(colorSum / total, 1.0);
        } else {
            colorResult.r = inputTexture.sample(textureSampler, lens + redOffset).r;
            colorResult.g = inputTexture.sample(textureSampler, lens + greenOffset).g;
            colorResult.b = inputTexture.sample(textureSampler, lens + blueOffset).b;
            colorResult.a = 1.0;
        }
        
        // Add lighting effects
        float gradient = clamp((clamp(m2.y, 0.0, 0.2) + 0.1) / 2.0, 0.0, 1.0) +
                        clamp((clamp(-m2.y, -1000.0, 0.2) * rb3 + 0.1) / 2.0, 0.0, 1.0);
        
        colorResult = mix(
            inputTexture.sample(textureSampler, uv),
            colorResult,
            rb1
        );
        colorResult = clamp(colorResult + float4(rb2 * 0.3) + float4(gradient * 0.2), 0.0, 1.0);
    }
    
    return colorResult;
}
