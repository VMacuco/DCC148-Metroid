//Shaders feito pelo Claude, adicionado para acostumar com o uso
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform vec2 game_resolution = vec2(460.8, 259.2);

uniform float curvature : hint_range(0.0, 0.5) = 0.03;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.25;
uniform float mask_strength : hint_range(0.0, 1.0) = 0.15;
uniform float aberration : hint_range(0.0, 0.01) = 0.0000;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.15;
uniform float brightness : hint_range(0.5, 2.0) = 1.15;

vec2 curve_uv(vec2 uv){
	uv = uv * 2.0 - 1.0;
	uv /= 1.0 + curvature;
	uv += uv * dot(uv, uv) * curvature;
	return uv * 0.5 + 0.5;
}

void fragment() {
	vec2 uv = curve_uv(UV);

	// Fora da "tela" curva: borda preta
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		// Aberração cromática leve
		float r = texture(screen_texture, uv + vec2(aberration, 0.0)).r;
		float g = texture(screen_texture, uv).g;
		float b = texture(screen_texture, uv - vec2(aberration, 0.0)).b;
		vec3 col = vec3(r, g, b);

		// Scanlines (1 ciclo por pixel nativo do jogo)
		float s = sin(uv.y * game_resolution.y * TAU);
		col *= 1.0 - scanline_strength * (0.5 - 0.5 * s);

		// Máscara RGB (tríade de fósforo) em pixels da tela real
		vec2 px = UV / SCREEN_PIXEL_SIZE;
		int m = int(mod(px.x, 3.0));
		vec3 mask = vec3(1.0 - mask_strength);
		if (m == 0) mask.r = 1.0;
		else if (m == 1) mask.g = 1.0;
		else mask.b = 1.0;
		col *= mask;

		// Vinheta
		float vig = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
		vig = clamp(pow(16.0 * vig, 0.25), 0.0, 1.0);
		col *= mix(1.0, vig, vignette_strength);

		COLOR = vec4(col * brightness, 1.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
