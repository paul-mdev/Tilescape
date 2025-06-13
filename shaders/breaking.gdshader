shader_type canvas_item;

// This shader simulates a breaking effect for a sprite offsetting parts of the texture using cellular noise

uniform float break_intensity : hint_range(0.0, 1.0, 0.01) = 0.04;
uniform float color_shift_intensity : hint_range(0.0, 1.0, 0.01) = 0.32;
uniform float break_progress : hint_range(0.0, 1.0, 0.333) = 0.;

// This sample texture should be a cellular noise texture with 'Return Type: Cell Value'
uniform sampler2D break_texture;

void fragment() {
    if(break_progress > 0.) {
        // We sample using break_progress to make the break differ on every change.
        // This only looks good if the increases are sudden (like pickaxes hitting a rock), instead of gradual
        vec4 noise = texture(break_texture, UV * break_progress);
        COLOR = texture(TEXTURE, UV + ((vec2(noise.r / 2.  )) - 0.25) * break_intensity * break_progress , 0.0);
        COLOR.rgb -=  noise.r * break_progress * color_shift_intensity;
    }
}