shader_type canvas_item;
uniform vec4 green : source_color;
uniform vec4 white : source_color;
uniform vec4 black : source_color;
void fragment(){
 COLOR = texture(TEXTURE, UV);

 COLOR.r=0.0;
 COLOR.b=0.84;
 COLOR.b = 0.35;
}