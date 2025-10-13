shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float time : hint_range(0.0, 1.0) = 0;

void fragment() {
	if (time == 0.0) {
		discard;
	}
	
	float t = time / 4.0 / 4.0;
	
	float cell_size = float(textureSize(screen_texture, 0).x) * t + (1.0 - t);
	
	vec2 num_cells = vec2(textureSize(screen_texture, 0)) / cell_size;
	
	vec2 uv = floor(SCREEN_UV * num_cells) / num_cells;
	vec4 color = texture( screen_texture, uv );
	COLOR = color;
}