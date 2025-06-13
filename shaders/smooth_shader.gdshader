shader_type canvas_item;

void fragment() {
	// Smooth interpolation, même si stretch filter est off
	COLOR = texture(TEXTURE, UV);
}
