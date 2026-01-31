shader_type canvas_item;

uniform vec3 color1 : source_color = vec3(0.1, 0.05, 0.2);
uniform vec3 color2 : source_color = vec3(0.5, 0.2, 0.6);
uniform vec3 color3 : source_color = vec3(0.3, 0.1, 0.4);
uniform vec3 background_color : source_color = vec3(0.05, 0.02, 0.1);

uniform float wave_speed : hint_range(0.1, 2.0) = 0.5;
uniform float wave_scale : hint_range(0.5, 5.0) = 2.0;

void fragment() {
	vec2 uv = UV;
	float time = TIME * wave_speed;

	// Layer 1 - Back layer (slowest, largest waves)
	float wave1_freq = 1.0 * wave_scale;
	float wave1_amp = 0.15;
	float wave1_speed = time * 0.3;
	float wave1 = sin(uv.x * wave1_freq + wave1_speed) * wave1_amp;
	wave1 += sin(uv.x * wave1_freq * 0.5 + wave1_speed * 0.7) * wave1_amp * 0.5;
	float layer1 = smoothstep(0.0, 0.1, uv.y - (0.7 + wave1));

	// Layer 2 - Middle layer (medium speed)
	float wave2_freq = 1.0 * wave_scale;
	float wave2_amp = 0.12;
	float wave2_speed = time * 0.3;
	float wave2 = sin(uv.x * wave2_freq + wave2_speed + 1.0) * wave2_amp;
	wave2 += sin(uv.x * wave2_freq * 0.7 + wave2_speed * 0.8 + 2.0) * wave2_amp * 0.6;
	float layer2 = smoothstep(0.0, 0.08, uv.y - (0.5 + wave2));

	// Layer 3 - Front layer (fastest, smallest waves)
	float wave3_freq = 2.0 * wave_scale;
	float wave3_amp = 0.1;
	float wave3_speed = time * 0.8;
	float wave3 = sin(uv.x * wave3_freq + wave3_speed + 2.5) * wave3_amp;
	wave3 += sin(uv.x * wave3_freq * 0.6 + wave3_speed * 1.1 + 0.5) * wave3_amp * 0.4;
	float layer3 = smoothstep(0.0, 0.06, uv.y - (0.3 + wave3));

	// Combine layers with colors
	vec3 final_color = background_color;

	// Apply layers from back to front
	final_color = mix(color1, final_color, layer1);
	final_color = mix(color2, final_color, layer2);
	final_color = mix(color3, final_color, layer3);

	// Add subtle gradient overlay
	float gradient = 1.0 - uv.y * 0.3;
	final_color *= gradient;

	COLOR = vec4(final_color, 1.0);
}
