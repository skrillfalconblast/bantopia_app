shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 screen_uv = SCREEN_UV;
	
	vec3 color = texture(SCREEN_TEXTURE, screen_uv).rgb;
	
	if (color == vec3(1.0, 1.0, 1.0)) {
		COLOR = vec4(0.992, 0.271, 0.337, 1.0);
	} else {
		COLOR.rgb = color;
		COLOR.a = 1.0;
	}
}

