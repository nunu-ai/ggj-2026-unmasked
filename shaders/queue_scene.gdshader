shader_type canvas_item;

uniform vec3 base_color : source_color = vec3(0.1, 0.05, 0.15);
uniform vec3 halo_color : source_color = vec3(0.8, 0.4, 0.9);
uniform vec3 dot_color : source_color = vec3(1.0, 0.8, 0.3);
uniform float halo_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float halo_size : hint_range(0.05, 0.5) = 0.15;
uniform float halo_softness : hint_range(0.01, 0.3) = 0.1;
uniform int num_halos : hint_range(1, 8) = 4;
uniform float dot_size : hint_range(0.005, 0.05) = 0.015;
uniform int num_dots : hint_range(4, 32) = 12;
uniform float dot_speed : hint_range(0.1, 2.0) = 0.5;
uniform float bounce_speed : hint_range(0.1, 2.0) = 0.5;

// Simple hash function for pseudo-random values
float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

// Get bouncing halo position
vec2 get_halo_position(int index, float time) {
	float seed = float(index) * 127.1;
	float speed_x = (hash(seed) * 0.4 + 0.3) * bounce_speed;
	float speed_y = (hash(seed + 50.0) * 0.4 + 0.3) * bounce_speed;
	float offset_x = hash(seed + 100.0) * 6.28;
	float offset_y = hash(seed + 150.0) * 6.28;

	// Bouncing motion using abs(sin) for smooth bounce effect
	float x = abs(sin(time * speed_x + offset_x));
	float y = abs(sin(time * speed_y + offset_y));

	// Add some margin so halos don't go exactly to edges
	float margin = halo_size * 0.5;
	x = margin + x * (1.0 - 2.0 * margin);
	y = margin + y * (1.0 - 2.0 * margin);

	return vec2(x, y);
}

// Calculate halo contribution at a point
float halo_at(vec2 uv, vec2 center) {
	float dist = distance(uv, center);
	float halo = smoothstep(halo_size + halo_softness, halo_size - halo_softness, dist);
	return halo * halo_intensity;
}

// Get position along the border (0 to 1 maps to full perimeter clockwise)
vec2 get_border_position(float t) {
	// Perimeter segments: top (0-0.25), right (0.25-0.5), bottom (0.5-0.75), left (0.75-1.0)
	float margin = 0.02;

	if (t < 0.25) {
		// Top edge: left to right
		float local_t = t / 0.25;
		return vec2(margin + local_t * (1.0 - 2.0 * margin), margin);
	} else if (t < 0.5) {
		// Right edge: top to bottom
		float local_t = (t - 0.25) / 0.25;
		return vec2(1.0 - margin, margin + local_t * (1.0 - 2.0 * margin));
	} else if (t < 0.75) {
		// Bottom edge: right to left
		float local_t = (t - 0.5) / 0.25;
		return vec2(1.0 - margin - local_t * (1.0 - 2.0 * margin), 1.0 - margin);
	} else {
		// Left edge: bottom to top
		float local_t = (t - 0.75) / 0.25;
		return vec2(margin, 1.0 - margin - local_t * (1.0 - 2.0 * margin));
	}
}

// Calculate dot contribution
float dot_at(vec2 uv, vec2 center, vec2 pixel_size) {
	// Adjust for aspect ratio
	vec2 diff = uv - center;
	float dist = length(diff);
	return smoothstep(dot_size, dot_size * 0.3, dist);
}

void fragment() {
	vec2 uv = UV;

	// Start with base color
	vec3 color = base_color;

	// Add bouncing halos
	float total_halo = 0.0;
	for (int i = 0; i < num_halos; i++) {
		if (i >= num_halos) break;
		vec2 halo_pos = get_halo_position(i, TIME);
		total_halo += halo_at(uv, halo_pos);
	}
	total_halo = clamp(total_halo, 0.0, 1.0);
	color = mix(color, halo_color, total_halo);

	// Add circling border dots
	float dot_contribution = 0.0;
	for (int i = 0; i < num_dots; i++) {
		if (i >= num_dots) break;
		float base_t = float(i) / float(num_dots);
		float animated_t = fract(base_t + TIME * dot_speed);
		vec2 dot_pos = get_border_position(animated_t);
		dot_contribution += dot_at(uv, dot_pos, SCREEN_PIXEL_SIZE);
	}
	dot_contribution = clamp(dot_contribution, 0.0, 1.0);
	color = mix(color, dot_color, dot_contribution);

	COLOR = vec4(color, 1.0);
}
