// Final Fight 2: one dim physical row per integer pixel group.
// Pixel-locked approach inspired by the user's TvC profiles; no tint or mask.
// This small original GLSL implementation is dedicated to CC0-1.0.
#ifdef VERTEX
in vec2 VertexCoord;
in vec2 TexCoord;
out vec2 vTexCoord;
void main() {
    vTexCoord = TexCoord;
    gl_Position = vec4(VertexCoord * 2.0 - 1.0, 0.0, 1.0);
}
#endif
#ifdef FRAGMENT
uniform sampler2D Texture;
uniform vec2 OutputSize;
in vec2 vTexCoord;
out vec4 FragColor;
void main() {
    // Dense cadence like TvC: at 672px high use a 2px group, at 1440 a 3px
    // group. Always just ONE physical row darkened, never a thick UV band.
    float spacing = max(2.0, floor(OutputSize.y / 480.0 + 0.5));
    float outputRow = floor(vTexCoord.y * OutputSize.y);
    float multiplier = mod(outputRow, spacing) < 1.0 ? 0.86 : 1.018;
    vec4 source = texture(Texture, vTexCoord);
    FragColor = vec4(min(source.rgb * multiplier, vec3(1.0)), source.a);
}
#endif
