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
	
	postDeferredShading_fs4x.glsl
	Calculate full-screen deferred Phong shading.
*/

#version 450

#define MAX_LIGHTS 1024

// ****TO-DO:
//	-> this one is pretty similar to the forward shading algorithm (Phong NM) 
//		except it happens on a plane, given images of the scene's geometric 
//		data (the "g-buffers"); all of the information about the scene comes 
//		from screen-sized textures, so use the texcoord varying as the UV
//	-> declare point light data structure and uniform block
//	-> declare pertinent samplers with geometry data ("g-buffers")
//	-> use screen-space coord (the inbound UV) to sample g-buffers
//	-> calculate view-space fragment position using depth sample
//		(hint: modify screen-space coord, use appropriate matrix to get it 
//		back to view-space, perspective divide)
//	-> calculate and accumulate final diffuse and specular shading

in vec4 vTexcoord_atlas;

uniform int uCount;

uniform sampler2D uImage00; // Diffuse Atlas
uniform sampler2D uImage01; // Specular Atlas

uniform sampler2D uImage04; // texCoords g-buffer
uniform sampler2D uImage05; // normals  g-buffer
//uniform sampler2D uImage06; // position g-buffer
uniform sampler2D uImage07; // depth g-buffer

//Testing
uniform sampler2D uImage02, uImage03; //nrm, ht


layout (location = 0) out vec4 rtFragColor;



void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE ORANGE
	//rtFragColor = vec4(1.0, 0.5, 0.0, 1.0);

	vec4 sceneTexcoord = texture(uImage04, vTexcoord_atlas.xy);

	vec4 diffuseSample = texture(uImage00,  sceneTexcoord.xy);
	vec4 specularSample = texture(uImage01,  sceneTexcoord.xy);

	// Phong shading:
	// ambient
	// + diffuse color * diffuse light
	// + specular color * specular light
	//have:
	// -> diffuse/specular colors
	// have not:
	// -> light stuff
	//		-> light data -> light data struct -> uniform buffer
	//		-> normals, position, depth -> geometry buffers!!!
	//	-> texture coords -> g-buffer
	//		


	// DEBUGGING
	rtFragColor = diffuseSample * specularSample;
	//rtFragColor = texture(uImage02, vTexcoord_atlas.xy);  Normal
	//rtFragColor = texture(uImage07, vTexcoord_atlas.xy); depth
}
