shader_type canvas_item;
render_mode blend_mix;

uniform float rotation = 0.0;

void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	COLOR = texture(TEXTURE, UV);
	
	float c = cos(rotation);
	float s = sin(rotation);
	
	float x = ps.x * c - ps.y * s;
	float y = ps.x * s + ps.y * c;
	vec2 pixel_offset = vec2(x, y);
	
	if(texture(TEXTURE, UV).a == 0.0 && texture(TEXTURE, UV - pixel_offset).a != 0.0) {
		COLOR = vec4(0,0,0,0.2)
	}
}