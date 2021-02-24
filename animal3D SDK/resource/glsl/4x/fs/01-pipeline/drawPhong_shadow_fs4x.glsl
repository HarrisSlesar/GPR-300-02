/*
	Copyright 2011-2021 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawPhong_shadow_fs4x.glsl
	Output Phong shading with shadow mapping.
*/

#version 450

// ****TO-DO:
// 1) Phong shading
//	-> identical to outcome of last project
// 2) shadow mapping
//	-> declare shadow map texture
//	-> declare shadow coordinate varying
//	-> perform manual "perspective divide" on shadow coordinate
//	-> perform "shadow test" (explained in class)

layout (location = 0) out vec4 rtFragColor;

uniform int uCount;

uniform sampler2D uTex_shadow;


in vec4 vShadowcoord;
in vec4 vPosition;
in vec4 vNormal;
in vec2 vTexcoord;

uniform vec4 uLightPos; // world/camera space
uniform vec4 uLightCol;
uniform vec4 uColor;
uniform sampler2D uAtlas;

float shininess = 128.0;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE LIME
	//rtFragColor = vec4(0.5, 1.0, 0.0, 1.0);

	// diffuse coeff = dot(unit surface normal,
	//                     unit light vector)

	vec4 N = normalize(vNormal);
	vec4 L = normalize(uLightPos - vPosition);

	float kd = dot(N,L); //The diffuse coeff

	vec4 pixelColor = texture2D(uAtlas, vTexcoord); //Getting the pixelColor from the sampler
	vec4 materialColor = pixelColor * uColor; //combining it with uColor for the material

	vec4 ambient = vec4(0.1, 0.1, 0.1, 1.0); //ambient light

	vec4 reflection = reflect(-L, N); //The reflection for the specular calculation
	float eyeReflectionAngle = max(0.0, dot(N,reflection)); //The angle for the reflection
	float spec = pow(eyeReflectionAngle, shininess);  //the specular coeff

	vec4 specularColor = uLightCol * materialColor * spec; //The specular color

	vec4 diffuseColor = materialColor * uLightCol * kd; //the diffuse color

	vec4 phong = ambient + diffuseColor + specularColor;
	
	rtFragColor = textureProj(uTex_shadow, vShadowcoord) * phong;
	// DEBUGGING
	//rtFragColor = vec4(kd,kd,kd,1.0);
}

