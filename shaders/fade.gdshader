shader_type canvas_item;

uniform float time : hint_range(0.0, 1.0) = 0;

const float steps = 4.0;

void fragment() {
	float t = floor(time * steps) / steps;
	COLOR.a = t;
}