shader_type canvas_item;

// === PARAMÈTRES POUR LE VERTEX (déplacement de la surface) ===
uniform float wave_speed = 1.0;
uniform float wave_height = 2.0;
uniform float wave_frequency = 4.0;
uniform vec2 tile_size = vec2(16.0, 16.0);

// === PARAMÈTRES POUR LE FRAGMENT (déformation de texture) ===
uniform float flow_speed = 1.0;
uniform float flow_strength = 1.5;
uniform float flow_scale = 1.0;

void vertex() {
    float time = TIME * wave_speed;

    // Déplacement vertical basé sur la position horizontale
    float wave = sin((VERTEX.x / tile_size.x + time) * wave_frequency) * wave_height;

    VERTEX.y += wave;
}

void fragment() {
    // Taille de la texture en pixels
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    vec2 tile_uv_size = tile_size / tex_size;

    // Identifier le tile et obtenir les UV locales
    vec2 tile_id = floor(UV / tile_uv_size);
    vec2 local_uv = fract(UV / tile_uv_size);

    // Générer une phase pseudo-aléatoire stable par tile
    float tile_phase = fract(sin(dot(tile_id, vec2(12.9898, 78.233))) * 43758.5453);
    float time = TIME * flow_speed + tile_phase * 6.283;

    // Déformation horizontale (écoulement)
    float flow = sin((local_uv.y + tile_phase) * flow_scale * 6.283 + time) * (flow_strength / 100.0);

    local_uv.x += flow;

    // Clamp pour éviter les artefacts aux bords
    float margin = flow_strength / 100.0;
    local_uv = clamp(local_uv, vec2(0.0) + margin, vec2(1.0) - margin);

    // Reconstruction des UV finaux
    vec2 final_uv = tile_id * tile_uv_size + local_uv * tile_uv_size;

    COLOR = texture(TEXTURE, final_uv);
}
