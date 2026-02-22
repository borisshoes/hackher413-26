shader_type spatial;
render_mode unshaded;

uniform sampler2D sprite_index_tex : filter_nearest, repeat_disable;
uniform sampler2D new_palette : filter_nearest, repeat_disable;
uniform int color_count;
uniform bool debug_magenta = false;

void fragment() {
    // Sample the index texture (R channel = 0..1) and alpha
    vec4 idx_tex = texture(sprite_index_tex, UV);
    float idx_f = idx_tex.r;
    float alpha = idx_tex.a;

    // Fully transparent pixels stay transparent
    if (alpha < 0.01) {
        ALBEDO = vec3(0.0);
        ALPHA = 0.0;
    }

    vec4 result;

    if (debug_magenta) {
        result.rgb = vec3(1.0, 0.0, 1.0);
        result.a = 1.0;
    } else {
        // Convert normalized 0..1 to integer index 0..color_count-1
        int idx = int(floor(idx_f * float(color_count) + 0.5));

        // Fetch the color from the palette
        float u = (float(idx) + 0.5) / float(color_count);
        result = texture(new_palette, vec2(u, 0.5));
    }

    ALBEDO = result.rgb;
    ALPHA = alpha; // preserve original transparency
}