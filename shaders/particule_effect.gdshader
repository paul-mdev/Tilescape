shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform bool enabled=true;
uniform sampler2D blend;  //Blending mode texture
uniform float Intensity : hint_range(0, 1) =0.5;  //Default should be 1 but syntax doesn't allow it currently?

void fragment() {
	if (enabled){
		vec4 bgColor;
		vec4 Color = texture(TEXTURE, UV);
		vec4 blendColor;
	   	vec4 output = vec4(1,1,1,1);

		bgColor = texture( SCREEN_TEXTURE, SCREEN_UV);

		output.a = Color.a;

		blendColor = texture( blend, vec2(bgColor.r, Color.r) );
		output.r = blendColor.r;
		blendColor = texture( blend, vec2(bgColor.g, Color.g) );
		output.g = blendColor.g;
		blendColor = texture( blend, vec2(bgColor.b, Color.b) );
		output.b = blendColor.b;

		output.rgb = mix(Color.rgb, output.rgb, Intensity);
		COLOR = output;

	} else {
		COLOR = texture(TEXTURE, UV);
	}
}