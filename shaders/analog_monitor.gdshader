// From godotshaders.com/shader/analog-monitor/

shader_type canvas_item;

// texture to be used as "pixels"
uniform sampler2D tiledtexture: repeat_enable, filter_linear_mipmap;
// how much of the tiled texture to show (1 recommended)
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
// size of pixelation effect
uniform float pixel_size = 0.01;
// whether to greyscale the image or not before applying tiletexture
uniform bool greyscale = true;
uniform float contrast = 1.0;
// grab the camera's view
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// the overriding color of the tiled texture, white by default
uniform vec3 pixel_colors : source_color = vec3(1.0);
// the overriding color of the background, black by default
uniform vec3 background_color : source_color = vec3(0.0);

vec4 to_grayscale(vec4 color) {
	float luminance = 0.21 * color.r + 0.72 * color.g + 0.07 * color.b;
	return vec4(luminance, luminance, luminance, color.a);
}

vec4 adjust_contrast(vec4 color) {
	color.rgb = (color.rgb - 0.5) * max(contrast, 0.0) + 0.5;
	return color;
}

vec4 hard_mix(vec4 color1, vec4 color2) {
	vec4 result;
	for (int i = 0; i < 4; i++) {
		float value = color1[i] + color2[i];
		if (value >= 1.0) {
			result[i] = 1.0;
		} else {
			result[i] = 0.0;
		}
	}
	return result;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 uv2 = SCREEN_UV;

	uv = floor(uv / pixel_size) * pixel_size;
	vec4 color1 = texture(screen_texture, uv);

	if (greyscale) {
		color1 = to_grayscale(color1);
		color1 = adjust_contrast(color1);
	}

	vec4 color2 = texture(tiledtexture, uv2 / pixel_size);
	vec4 final_result = mix(color1, hard_mix(color1, color2), opacity);

	if (final_result == vec4(1.0, 1.0, 1.0, 1.0)) {
		final_result = vec4(pixel_colors, 1.0);
	} else {
		if (final_result == vec4(0.0, 0.0, 0.0, 1.0)) {
			final_result = vec4(background_color, 1.0);
		}
	}

	COLOR = final_result;
}
