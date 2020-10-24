shader_type canvas_item;
render_mode blend_mix;

uniform vec2 size = vec2(1200, 900);

void fragment() {
	vec2 new_uv = round(SCREEN_UV * size) / size;
	COLOR.rgb = textureLod(SCREEN_TEXTURE, new_uv, 0.0).rgb;
}