#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float aspect;
    float glow;
    vec4 ground;
    vec4 tintA;
    vec4 tintB;
    vec4 tintC;
};

const int BLOB_COUNT = 7;
const int TINT_COUNT = 3;

const float GOLDEN_FRACTION = 0.6180339887;
const float GOLDEN_ANGLE = 2.3999632297;

const float LANE_SPREAD = 0.84;
const float SWAY_TRAVEL = 0.06;
const float SWAY_RATE = 0.031;
const float RISE_TRAVEL = 0.40;
const float RISE_RATE_FLOOR = 0.055;
const float RISE_RATE_SPREAD = 0.035;

const float RADIUS_FLOOR = 0.085;
const float RADIUS_SPREAD = 0.055;
const float RADIUS_PULSE = 0.014;
const float PULSE_RATE = 0.07;

const float SURFACE_LEVEL = 1.0;
const float SURFACE_SOFTNESS = 0.55;
const float CORE_SOFTNESS = 2.2;
const float CORE_SHARE = 0.45;

const float EPSILON = 1e-5;

float spread(float seed, float scale) {
    return fract(seed * scale);
}

void main() {
    vec2 point = vec2(qt_TexCoord0.x * aspect, qt_TexCoord0.y);
    vec3 tints[TINT_COUNT] = vec3[TINT_COUNT](
        tintA.rgb, tintB.rgb, tintC.rgb);

    float field = 0.0;
    vec3 molten = vec3(0.0);

    for (int index = 0; index < BLOB_COUNT; ++index) {
        float seed = float(index) + 1.0;
        float lane = spread(seed, GOLDEN_FRACTION);
        float phase = seed * GOLDEN_ANGLE;
        float riseRate = RISE_RATE_FLOOR + RISE_RATE_SPREAD * lane;
        float radius = RADIUS_FLOOR
            + RADIUS_SPREAD * spread(seed, GOLDEN_ANGLE)
            + RADIUS_PULSE * sin(time * PULSE_RATE + phase);

        vec2 centre = vec2(
            0.5 + (lane - 0.5) * LANE_SPREAD
                + SWAY_TRAVEL * sin(time * SWAY_RATE + phase),
            0.5 + RISE_TRAVEL * sin(time * riseRate + phase));
        centre.x *= aspect;

        vec2 offset = point - centre;
        float weight =
            radius * radius / max(dot(offset, offset), EPSILON);
        field += weight;
        molten += tints[index % TINT_COUNT] * weight;
    }

    molten /= max(field, EPSILON);

    float surface = smoothstep(
        SURFACE_LEVEL, SURFACE_LEVEL + SURFACE_SOFTNESS, field);
    float core = smoothstep(
        SURFACE_LEVEL, SURFACE_LEVEL + CORE_SOFTNESS, field);
    float intensity = mix(surface, core, CORE_SHARE) * glow;

    fragColor =
        vec4(mix(ground.rgb, molten, intensity), 1.0) * qt_Opacity;
}
