shader_type canvas_item;
render_mode blend_mix;

uniform float time = 0;
uniform vec4 colour1 = vec4(1,1,1,1);
uniform vec4 colour2 = vec4(1,1,1,1);
uniform vec4 colour3 = vec4(1,1,1,1);
uniform vec4 colour4 = vec4(1,1,1,1);
uniform vec4 colour5 = vec4(1,1,1,1);
uniform vec4 colour6 = vec4(1,1,1,1);
uniform vec4 colour7 = vec4(1,1,1,1);
uniform vec4 colour8 = vec4(1,1,1,1);
uniform vec4 colour9 = vec4(1,1,1,1);

vec4 lerp(vec4 v0, vec4 v1, float t) {
	return (1.0 - t) * v0 + t * v1;
}

vec3 tint(vec3 source, vec4 new) {
	float r = (new.r - source.r) * new.a + source.r;
	float g = (new.g - source.g) * new.a + source.g;
	float b = (new.b - source.b) * new.a + source.b;
	return vec3(r, g, b);
}

void fragment() {
	vec3 screen = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	vec4 colour = colour1;
	
	float s = time; 
	//float s = mod(TIME/ 10.0, 1.0);
	
	if(s >= 0.0 && s <= 0.125) {
		float sMin = 0.0;
		float sMax = 0.125;
		float newS = ((s - sMin)) / (sMax - sMin);
		colour = lerp(colour1, colour2, newS);
	}
	else if(s >= 0.125 && s <= 0.250) {
		float sMin = 0.125;
		float sMax = 0.250;
		float newS = ((s - sMin)) / (sMax - sMin);
		colour = lerp(colour2, colour3, newS);
	}
	else if(s >= 0.250 && s <= 0.375) {
		float sMin = 0.250;
		float sMax = 0.375;
		float newS = ((s - sMin)) / (sMax - sMin);
		colour = lerp(colour3, colour4, newS);
	}
	else if(s >= 0.375 && s <= 0.500) {
		float sMin = 0.375;
		float sMax = 0.500;
		float newS = ((s - sMin)) / (sMax - sMin);
		colour = lerp(colour4, colour5, newS);
	}
	else if(s >= 0.500 && s <= 0.625) {
		float sMin = 0.500;
		float sMax = 0.625;
		float newS = ((s - sMin)) / (sMax - sMin);
		colour = lerp(colour5, colour6, newS);
	}
	else if(s >= 0.625 && s <= 0.750) {
		float sMin = 0.625;
		float sMax = 0.750;
		float newS = ((s - sMin)) / (sMax - sMin);
		colour = lerp(colour6, colour7, newS);
	}
	else if(s >= 0.750 && s <= 0.875) {
		float sMin = 0.750;
		float sMax = 0.875;
		float newS = ((s - sMin)) / (sMax - sMin);
		colour = lerp(colour7, colour8, newS);
	}
	else if(s >= 0.875 && s <= 1.0) {
		float sMin = 0.875;
		float sMax = 1.0;
		float newS = ((s - sMin)) / (sMax - sMin);
		colour = lerp(colour8, colour9, newS);
	}
	
	COLOR.rgb = tint(screen, colour);
}