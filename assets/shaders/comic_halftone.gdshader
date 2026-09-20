shader_type canvas_item;
render_mode unshaded;

uniform vec4 ink_color : source_color = vec4(0.01, 0.008, 0.02, 1.0);
uniform vec4 neon_a : source_color = vec4(0.98, 0.05, 0.42, 1.0);
uniform vec4 neon_b : source_color = vec4(0.16, 0.95, 0.96, 1.0);
uniform float dot_scale = 52.0;
uniform float glow_strength = 0.18;

void fragment() {
	vec2 uv = UV;
	float vignette = smoothstep(0.88, 0.28, distance(uv, vec2(0.5)));
	float drift = sin(TIME * 0.32) * 0.018;
	float slash = pow(max(0.0, 1.0 - abs(uv.x - (0.18 + uv.y * 0.42 + drift)) * 2.7), 7.0);
	float dots = smoothstep(0.62, 0.98, sin((uv.x + TIME * 0.0015) * dot_scale) * sin(uv.y * dot_scale));
	float scan = 0.5 + 0.5 * sin((uv.y * 140.0) + (uv.x * 11.0) + (TIME * 0.65));

	vec3 color = ink_color.rgb;
	color += neon_a.rgb * slash * glow_strength;
	color += neon_b.rgb * dots * 0.055;
	color += neon_a.rgb * scan * 0.012;
	color *= 0.55 + vignette * 0.7;

	COLOR = vec4(color, 1.0);
}
