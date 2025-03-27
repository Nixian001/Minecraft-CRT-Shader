#version 150

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

in vec2 vaUV0;
in vec2 vaPosition;

out vec2 texcoord;

void main() {
	gl_Position = projectionMatrix * (modelViewMatrix * vec4(vaPosition, 0.0, 1.0));
	texcoord    = vaUV0;
}