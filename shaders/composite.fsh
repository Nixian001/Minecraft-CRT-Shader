#version 150
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D colortex0;

// Properties Tab
uniform float SCREEN_CURVE_STRENGTH = 0.25;	// 0.25
uniform vec3  SCREEN_CURVE_COLOR = vec3(0.0, 0.0, 0.0); // 000

uniform float SCAN_LINE_BAR_HEIGHT = 8.00;		// 8.0
uniform float SCAN_LINE_FREQUENCY  = 16.0;		// 16.0
uniform float SCAN_LINE_DARKNESS   = 0.50;		// 0.5

uniform float BLOOM_STRENGTH = 2;			// 2
uniform float BLOOM_SIZE = 0.8;				// 0.8

uniform float SATURATION_INTENSITY = 1.5;    // 1.5

uniform float POSTERIZATION_LEVEL = 7;		// 6


in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 colortex0Out;

void main() {
	vec2 uv = texcoord * 2.0 - 1.0; // Convert to -1 to 1 space (centered)
	float strength = SCREEN_CURVE_STRENGTH; // Adjust for more/less curve
	vec2 offset = uv * (1.0 + strength * (dot(uv, uv) - 1.0));
	vec2 distortedTexcoord = (offset + 1.0) / 2.0; // Convert back to 0-1 range

		// Check if out of screen bounds
	if (distortedTexcoord.x < 0.0 || distortedTexcoord.x > 1.0 ||
		distortedTexcoord.y < 0.0 || distortedTexcoord.y > 1.0) {
		colortex0Out = vec4(SCREEN_CURVE_COLOR, 1.0); // Black mask
	} else {
		vec3 color = texture(colortex0, distortedTexcoord).rgb;

		// Bloom effect
		vec3 bloomColor = vec3(0.0);
		float offsetStep = 1.0/1024.0 * BLOOM_SIZE; // Adjust this based on your texture resolution
		for (int i = -1; i <= 1; i++) {
			for (int j = -1; j <= 1; j++) {
				bloomColor += texture(colortex0, distortedTexcoord + vec2(i, j) * offsetStep).rgb;
			}
		}
		bloomColor /= 9.0; // Average of the 9 samples
		
		float luminance = dot(bloomColor, vec3(0.299, 0.587, 0.114));
		float bloomIntensity = BLOOM_STRENGTH; // Adjust how strong the bloom is
		color = mix(color, bloomColor, bloomIntensity * luminance);




		// Scan Lines (Dimming Instead of Black)
		float yPos = gl_FragCoord.y;
		if (mod(yPos, SCAN_LINE_FREQUENCY) < SCAN_LINE_BAR_HEIGHT) { 
			color *= SCAN_LINE_DARKNESS; 
		}



		// Over-Saturation
		float intensity = SATURATION_INTENSITY; 
		float avg = (color.r + color.g + color.b) / 3.0;
		color = mix(vec3(avg), color, intensity);



		// Posterization (Reduce Color Levels)
		float levels = POSTERIZATION_LEVEL;
		color = floor(color * levels) / levels;



		// Return Color
		colortex0Out = vec4(color, 1.0);
	}
}
