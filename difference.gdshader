shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

void fragment() {
	vec4 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	vec4 texture_color = texture(TEXTURE, UV);
	
	COLOR = vec4(abs(COLOR.rgb - screen_color.rgb), texture_color.a);
}
