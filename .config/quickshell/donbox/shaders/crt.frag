#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float scanPitch;
    float scanWeight;
    float vignetteWeight;
    float vignetteSpread;
    vec4 tint;
};

const float TAU = 6.2831853072;
const float HALF = 0.5;
const float CENTRE = 0.5;
const float EDGE_SPAN = 2.0;

void main() {
    vec2 uv = qt_TexCoord0;

    float ripple = HALF + HALF * cos(uv.y * scanPitch * TAU);
    float lines = ripple * scanWeight;

    vec2 offset = (uv - CENTRE) * EDGE_SPAN;
    float reach = dot(offset, offset) * vignetteSpread;
    float corner = clamp(reach, 0.0, 1.0);

    float shade = clamp(lines + corner * vignetteWeight, 0.0, 1.0);
    shade *= qt_Opacity;

    fragColor = vec4(tint.rgb * shade, shade);
}
