shader_type canvas_item;

uniform float time : hint_range(0.0, 1.0) = 0.0;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
	float x = UV.x - center.x;
	float y = UV.y - center.y;
	if (x * x + y * y < (1.0 - time) / 2.0) {
		discard;
	}
}