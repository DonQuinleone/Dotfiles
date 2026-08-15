#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float kind;
    float angle;
    float originX;
    float originY;
    float aspect;
    float grain;
    float outgoingCover;
    float incomingCover;
};

layout(binding = 1) uniform sampler2D outgoing;
layout(binding = 2) uniform sampler2D incoming;

const int KIND_CROSSFADE = 0;
const int KIND_WIPE = 1;
const int KIND_GROW = 2;
const int KIND_SHRINK = 3;
const int KIND_DISSOLVE = 4;
const int KIND_PIXELATE = 5;
const int KIND_WAVE = 6;

const float HALF = 0.5;
const float WHOLE = 1.0;
const float TAU = 6.2831853072;
const float HALF_TURN = 3.1415926536;

const float EDGE_SOFTNESS = 0.07;
const float DISC_SOFTNESS = 0.05;
const float DISSOLVE_SOFTNESS = 0.34;
const float DISSOLVE_CELLS = 22.0;
const float WAVE_TRAVEL = 0.055;
const float WAVE_CYCLES = 2.5;
const float BLOCK_CELLS_FINE = 4096.0;
const float BLOCK_CELLS_COARSE = 18.0;
const float BLOCK_SWAP_SOFTNESS = 0.14;

const vec2 HASH_AXES = vec2(127.1, 311.7);
const float HASH_SCALE = 43758.5453;

vec2 framePoint(vec2 uv) {
    return vec2(uv.x * aspect, uv.y);
}

vec2 discOrigin() {
    return framePoint(vec2(originX, originY));
}

vec2 heading() {
    return vec2(cos(angle), sin(angle));
}

float alongAxis(vec2 uv, vec2 axis) {
    vec2 offset = framePoint(uv) - framePoint(vec2(HALF));
    float halfSpan = HALF * (aspect * abs(axis.x) + abs(axis.y));
    return (dot(offset, axis) + halfSpan) / (halfSpan + halfSpan);
}

float sweep(float here, float shift, float softness) {
    float front = mix(-softness, WHOLE + softness, shift);
    return WHOLE
        - smoothstep(front - softness, front + softness, here);
}

float hash(vec2 cell) {
    return fract(sin(dot(cell, HASH_AXES) + grain) * HASH_SCALE);
}

float speckle(vec2 point) {
    vec2 cell = floor(point);
    vec2 blend = smoothstep(vec2(0.0), vec2(WHOLE), fract(point));
    return mix(
        mix(hash(cell), hash(cell + vec2(WHOLE, 0.0)), blend.x),
        mix(hash(cell + vec2(0.0, WHOLE)),
            hash(cell + vec2(WHOLE)), blend.x),
        blend.y);
}

float discMask(vec2 uv, float radius) {
    float reach = length(framePoint(uv) - discOrigin());
    return WHOLE - smoothstep(
        radius - DISC_SOFTNESS, radius + DISC_SOFTNESS, reach);
}

float cornerReach() {
    vec2 origin = discOrigin();
    return length(max(origin, vec2(aspect, WHOLE) - origin));
}

float wipeMask(vec2 uv, float shift) {
    return sweep(alongAxis(uv, heading()), shift, EDGE_SOFTNESS);
}

float waveMask(vec2 uv, float shift) {
    vec2 axis = heading();
    vec2 sideways = vec2(-axis.y, axis.x);
    float ripple = WAVE_TRAVEL
        * sin(alongAxis(uv, sideways) * WAVE_CYCLES * TAU);
    return sweep(
        alongAxis(uv, axis) + ripple, shift, EDGE_SOFTNESS);
}

float dissolveMask(vec2 uv, float shift) {
    vec2 field = uv * vec2(aspect, WHOLE) * DISSOLVE_CELLS;
    return sweep(speckle(field), shift, DISSOLVE_SOFTNESS);
}

float blockMask(float shift) {
    return smoothstep(HALF - BLOCK_SWAP_SOFTNESS,
        HALF + BLOCK_SWAP_SOFTNESS, shift);
}

float blendMask(int chosen, vec2 uv, float shift) {
    if (chosen == KIND_WIPE) return wipeMask(uv, shift);
    if (chosen == KIND_WAVE) return waveMask(uv, shift);
    if (chosen == KIND_DISSOLVE) return dissolveMask(uv, shift);
    if (chosen == KIND_PIXELATE) return blockMask(shift);
    if (chosen == KIND_GROW) {
        return discMask(uv, shift * cornerReach());
    }
    if (chosen == KIND_SHRINK) {
        return WHOLE
            - discMask(uv, (WHOLE - shift) * cornerReach());
    }
    return shift;
}

vec2 blockUv(vec2 uv, float shift) {
    float bulge = sin(shift * HALF_TURN);
    float cells = exp(mix(
        log(BLOCK_CELLS_FINE), log(BLOCK_CELLS_COARSE), bulge));
    vec2 grid = vec2(cells * aspect, cells);
    return (floor(uv * grid) + HALF) / grid;
}

vec2 sampleUv(int chosen, vec2 uv, float shift) {
    if (chosen == KIND_PIXELATE) return blockUv(uv, shift);
    return uv;
}

vec2 cover(vec2 uv, float ratio) {
    vec2 factor =
        vec2(min(ratio, WHOLE), min(WHOLE / ratio, WHOLE));
    return vec2(HALF) + (uv - vec2(HALF)) * factor;
}

void main() {
    float shift = clamp(progress, 0.0, WHOLE);
    int chosen = int(kind + HALF);
    vec2 uv = sampleUv(chosen, qt_TexCoord0, shift);
    float mask = blendMask(chosen, qt_TexCoord0, shift);

    vec4 was = texture(outgoing, cover(uv, outgoingCover));
    vec4 now = texture(incoming, cover(uv, incomingCover));

    fragColor = mix(was, now, mask) * qt_Opacity;
}
