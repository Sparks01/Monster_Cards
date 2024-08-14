//
//  metallib.metal
//  Monster Cards
//
//  Created by JXMUNOZ on 2/12/24.
//

#include <metal_stdlib>
using namespace metal;

// Vertex structure
typedef struct {
    float4 position [[position]]; // Vertex position
    float2 textureCoordinate;     // Texture coordinate for gradient mapping
} VertexOut;

// Simple vertex shader that passes through position and texture coordinates
vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                              constant float4* positions [[buffer(0)]],
                              constant float2* texCoords [[buffer(1)]]) {
    VertexOut out;
    out.position = positions[vertexID];
    out.textureCoordinate = texCoords[vertexID];
    return out;
}

// Fragment shader for generating a vertical gradient based on texture coordinates
fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    // Simple gradient calculation
    float3 topColor = float3(0.0, 0.0, 0.5); // Dark blue
    float3 bottomColor = float3(0.5, 0.0, 0.0); // Dark red
    float3 colorMix = mix(topColor, bottomColor, in.textureCoordinate.y);
    
    return float4(colorMix, 1.0); // Output color with full opacity
}
