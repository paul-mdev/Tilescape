shader_type canvas_item;

uniform float wind_speed = 0.75;
uniform float wind_strength = 1.5;
uniform float wind_scale = 2.0;
uniform vec2 tile_size = vec2(16.0, 16.0);

void vertex() {
    float t = TIME * wind_speed;
    float offset_x = sin((VERTEX.y + t) * wind_scale);
    float offset_y = cos((VERTEX.x + t * 0.5) * wind_scale);
    VERTEX.x += offset_x * wind_strength;
    
    VERTEX.y += offset_y * wind_strength * 0.3;
}




uniform float wind_speed_f = 1.5;
uniform float wind_strength_f = 1.0;
uniform float wind_scale_f = 1.0;

void fragment() {
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    vec2 tile_uv_size = tile_size / tex_size;

    // Coord du tile
    vec2 tile_id = floor(UV / tile_uv_size);
    vec2 local_uv = fract(UV / tile_uv_size);

    // Phase pseudo-aléatoire stable par tile
    float tile_phase = fract(sin(dot(tile_id, vec2(12.9898, 78.233))) * 43758.5453);
    float time = TIME * wind_speed_f + tile_phase * 6.283;

    // Onde locale (en y), cohérente sur toute la grille
    float wave = sin((local_uv.y + tile_phase) * wind_scale_f * 6.283 + time) * (wind_strength_f / 100.0);

    local_uv.x += wave;

    float margin = wind_strength_f / 100.0;
    local_uv = clamp(local_uv, vec2(0.0) + margin, vec2(1.0) - margin);

    vec2 final_uv = tile_id * tile_uv_size + local_uv * tile_uv_size;
    COLOR = texture(TEXTURE, final_uv);
}
