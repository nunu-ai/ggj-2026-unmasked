shader_type canvas_item;
render_mode unshaded;

// Pulsate “yellow-ish” pixels (like club lights reacting to music) and add a soft
// glow/bleed into surrounding pixels by sampling the screen texture.
//
// Usage notes:
// - Apply this shader as a `ShaderMaterial` on a `ColorRect` for full-screen post,
//   or on any CanvasItem you want to affect. For true “surroundings bleed” you
//   typically want it on a full-screen ColorRect drawn last.
// - Requires screen reading, so we use `screen_texture` + `SCREEN_UV`.
//
// Tuning tips:
// - Start with `pulse_speed=2..4`, `beat_amount=0.5..0.8`, `glow_radius_px=3..8`.
// - If it affects too many colors, increase `yellow_threshold` or reduce `yellow_width`.

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

// Screen size in pixels (set from code). Used to convert pixel radius to UV radius.
uniform vec2 screen_size = vec2(1280.0, 720.0);

// --- Pulse (music-like) ---
uniform float pulse_speed : hint_range(0.0, 20.0) = 13.0;			// Overall tempo
uniform float beat_amount : hint_range(0.0, 2.0) = 0.8;			// How hard the “beat” hits
uniform float shimmer_amount : hint_range(0.0, 1.0) = 0.15;		// Subtle higher-frequency modulation
uniform float min_pulse : hint_range(0.0, 1.0) = 0.15;			// Baseline so it never fully turns off
uniform bool sync_all_lights = true;								// If false, varies phase across screen
uniform float phase_variation : hint_range(0.0, 6.283185) = 0.0;	// Additional phase offset

// --- Yellow detection ---
uniform vec3 target_yellow : source_color = vec3(1.0, 0.9, 0.25);
uniform float yellow_threshold : hint_range(0.0, 1.5) = 0.45;		// Higher = stricter
uniform float yellow_width : hint_range(0.001, 1.0) = 0.25;		// Softness of threshold (smaller = tighter)
uniform float brightness_threshold : hint_range(0.0, 1.0) = 0.12;	// Ignore very dark pixels
uniform float yellow_sensitivity : hint_range(0.0, 2.0) = 1.0;

// --- Color/strength ---
uniform float intensity : hint_range(0.0, 2.0) = 0.9;				// Main amplification of pulsing
uniform float saturation_boost : hint_range(0.0, 1.0) = 0.2;		// Extra “neon” feel on yellows

// --- Glow / bleed ---
uniform float glow_radius_px : hint_range(0.0, 24.0) = 6.0;		// Radius in pixels (screen-space)
uniform float glow_intensity : hint_range(0.0, 3.0) = 0.9;		// How much glow adds back in
uniform int glow_samples : hint_range(4, 32) = 12;					// Radial taps
uniform float glow_falloff : hint_range(0.5, 6.0) = 2.2;			// Higher = tighter glow

// If you want the effect to ONLY add light (and never darken), keep this on.
uniform bool additive_only = true;

// --- Helpers ---
float luma(vec3 c) {
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

vec3 boost_saturation(vec3 c, float amount) {
	float y = luma(c);
	vec3 gray = vec3(y);
	return mix(c, c + (c - gray), amount);
}

// 0..1 “how yellow is this pixel?”
float yellow_mask(vec3 c) {
	float b = luma(c);
	if (b < brightness_threshold) {
		return 0.0;
	}

	// Compare chroma direction rather than absolute brightness.
	vec3 cn = normalize(c + vec3(0.0001));
	vec3 tn = normalize(target_yellow + vec3(0.0001));

	// Smaller distance => more similar.
	float d = distance(cn, tn);

	// Threshold with soft edge.
	// d <= yellow_threshold => ~1, d >= yellow_threshold+yellow_width => ~0
	float m = 1.0 - smoothstep(yellow_threshold, yellow_threshold + yellow_width, d);

	// Also ensure it “behaves” like yellow: strong R & G relative to B.
	float rg = min(c.r, c.g);
	float blue_penalty = c.b;
	float structural = clamp((rg - blue_penalty) * 2.0, 0.0, 1.0);

	m *= structural;
	m *= yellow_sensitivity;

	return clamp(m, 0.0, 1.0);
}

// Beat-like pulse: a rounded “kick” plus a little shimmer.
float pulse_value(vec2 uv, float t) {
	float phase = 0.0;
	if (!sync_all_lights) {
		// Stable screen-space phase variation.
		phase = uv.x * 3.14159 + uv.y * 2.71828 + phase_variation;
	} else {
		phase = phase_variation;
	}

	// Base sine
	float s = sin(t * pulse_speed + phase) * 0.5 + 0.5;

	// Shape into a “beat”: emphasize peaks.
	// pow makes it more percussive (like reacting to music).
	float beat = pow(s, 3.0);

	// Add subtle shimmer (higher frequency) so it doesn't feel like a pure sine.
	float shimmer = sin(t * pulse_speed * 3.7 + phase * 1.3) * 0.5 + 0.5;

	float p = mix(beat, beat * (0.85 + 0.30 * shimmer), shimmer_amount);
	p = clamp(p, 0.0, 1.0);

	// Apply minimum baseline.
	return max(min_pulse, p);
}

vec3 sample_screen(vec2 uv) {
	return textureLod(screen_texture, uv, 0.0).rgb;
}

// Radial glow sampling around current pixel, weighted and masked by “yellow-ness”.
vec3 compute_glow(vec2 suv) {
	if (glow_radius_px <= 0.0 || glow_intensity <= 0.0) {
		return vec3(0.0);
	}

	// Pixel size in UV space.
	vec2 px = 1.0 / max(screen_size, vec2(1.0));
	float radius = glow_radius_px;
	float n = float(glow_samples);

	vec3 accum = vec3(0.0);
	float wsum = 0.0;

	// Include center as well (helps tight halos).
	{
		vec3 c0 = sample_screen(suv);
		float m0 = yellow_mask(c0);
		float w0 = 1.0;
		accum += c0 * (m0 * w0);
		wsum += (m0 * w0);
	}

	for (int i = 0; i < 32; i++) {
		if (i >= glow_samples) {
			break;
		}

		float a = (float(i) / n) * 6.28318530718;
		vec2 dir = vec2(cos(a), sin(a));

		// One sample on the ring.
		vec2 offset = dir * radius * px;
		vec2 uv = clamp(suv + offset, vec2(0.0), vec2(1.0));

		vec3 c = sample_screen(uv);
		float m = yellow_mask(c);

		// Weight by distance falloff (ring samples use same radius, but keep generic).
		float dist = radius;
		float w = 1.0 / pow(max(dist, 0.001), glow_falloff);

		accum += c * (m * w);
		wsum += (m * w);
	}

	if (wsum <= 0.00001) {
		return vec3(0.0);
	}

	// Return the “yellow-ish neighborhood” color.
	return accum / wsum;
}

void fragment() {
	vec2 suv = SCREEN_UV;
	vec3 base = sample_screen(suv);

	float m = yellow_mask(base);
	float p = pulse_value(UV, TIME);

	// Main pulse contribution on the pixel itself.
	float amp = beat_amount * p;
	vec3 pulsed = base;

	// Brighten + saturate selectively.
	vec3 boosted = base * (1.0 + intensity * amp);
	boosted = boost_saturation(boosted, saturation_boost * amp);

	pulsed = mix(base, boosted, m);

	// Glow/bleed: gather nearby yellow-ish color and add it back in, also modulated by pulse.
	vec3 glow_col = compute_glow(suv);
	vec3 glow_add = glow_col * (glow_intensity * m) * amp;

	vec3 out_col;
	if (additive_only) {
		out_col = max(pulsed, pulsed + glow_add);
	} else {
		out_col = pulsed + glow_add;
	}

	COLOR = vec4(out_col, 1.0);
}
