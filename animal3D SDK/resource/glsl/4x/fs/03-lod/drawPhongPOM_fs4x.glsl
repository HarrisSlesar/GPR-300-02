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
	
	drawPhongPOM_fs4x.glsl
	Output Phong shading with parallax occlusion mapping (POM).
*/

#version 450

#define MAX_LIGHTS 1024

in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
};

struct sPointLight
{
	vec4 viewPos, worldPos, color, radiusInfo;
};

uniform ubLight
{
	sPointLight uPointLight[MAX_LIGHTS];
};

uniform int uCount;

uniform vec4 uColor;

uniform float uSize;

uniform sampler2D uTex_dm, uTex_sm, uTex_nm, uTex_hm;

const vec4 kEyePos = vec4(0.0, 0.0, 0.0, 1.0);

layout (location = 0) out vec4 rtFragColor;
layout (location = 1) out vec4 rtFragNormal;

void calcPhongPoint(out vec4 diffuseColor, out vec4 specularColor, in vec4 eyeVec,
	in vec4 fragPos, in vec4 fragNrm, in vec4 fragColor,
	in vec4 lightPos, in vec4 lightRadiusInfo, in vec4 lightColor);
	
vec3 calcParallaxCoord(in vec3 coord, in vec3 viewVec, const int steps)
{
	// ****TO-DO:
	//	-> step along view vector until intersecting height map
	//	-> determine precise intersection point, return resulting coordinate
	
	vec3 cEND = vec3(coord.xy-viewVec.xy/viewVec.z,0);
	coord.z = 1;
	float n = float(steps);
	float dt = 1/n;
	float t = 0.0f;
	
	/*
	vec2 P = viewVec.xy; 
    vec2 deltaTexCoords = P / float(steps);

	vec2  currentTexCoords = coord.xy;
	float currentDepthMapValue = texture(uTex_dm, currentTexCoords).x;
  
	while(t < currentDepthMapValue)
	{
		// shift texture coordinates along direction of P
		currentTexCoords -= deltaTexCoords;
		// get depthmap value at current texture coordinates
		currentDepthMapValue = texture(uTex_dm, currentTexCoords).x;  
		// get depth of next layer
		t +=dt;  
	}
	*/

	
	vec3 coordT = mix(coord,cEND,t);
	vec3 prevCoordT = coord;

	float coordHeight = coordT.z;
	float prevHeight = prevCoordT.z;

	float bumpHeight = texture(uTex_hm,coordT.xy).x;
	float prevBumpHeight = texture(uTex_hm,prevCoordT.xy).x;

	while(t < 1)
	{
	
		if(bumpHeight > coordHeight)
		{
			float deltaH = coordHeight - prevHeight;
			float deltaB = bumpHeight - prevBumpHeight;

			float x = (prevHeight - prevBumpHeight) / (deltaB - deltaH);
			//return coord-(cEND*bumpHeight);
			return mix(prevCoordT, coordT, x);
		}
		
		
		prevCoordT = coordT;
		coordT = mix(coord,cEND,t);

		prevHeight = coordHeight;
		coordHeight = coordT.z;

		
		prevBumpHeight = bumpHeight;
		bumpHeight = texture(uTex_hm,coordT.xy).x;
		
		t += dt;
	}
	
	// done
	return coord;
}

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE GREEN
//	rtFragColor = vec4(0.0, 1.0, 0.0, 1.0);

	vec4 diffuseColor = vec4(0.0), specularColor = diffuseColor, dd, ds;
	
	// view-space tangent basis
	vec4 tan_view = normalize(vTangentBasis_view[0]);
	vec4 bit_view = normalize(vTangentBasis_view[1]);
	vec4 nrm_view = normalize(vTangentBasis_view[2]);
	vec4 pos_view = vTangentBasis_view[3];
	
	

	// view-space view vector
	vec4 viewVec = normalize(kEyePos - pos_view);
	
	// ****TO-DO:
	//	-> convert view vector into tangent space
	//		(hint: the above TBN bases convert tangent to view, figure out 
	//		an efficient way of representing the required matrix operation)

	mat4 TBN = inverse(mat4(tan_view,bit_view,nrm_view, pos_view));

	//mat4 TBNInv = inverse(TBN);

	// tangent-space view vector
	vec3 viewVec_tan = (TBN * viewVec).xyz;

	
	// parallax occlusion mapping
	vec3 texcoord = vec3(vTexcoord_atlas.xy, uSize);
	texcoord = calcParallaxCoord(texcoord, viewVec_tan, 256);
	
	// read and calculate view normal
	vec4 sample_nm = texture(uTex_nm, texcoord.xy);
	nrm_view = mat4(tan_view, bit_view, nrm_view, kEyePos)
		* vec4((sample_nm.xyz * 2.0 - 1.0), 0.0);
	
	int i;
	for (i = 0; i < uCount; ++i)
	{
		calcPhongPoint(dd, ds, viewVec, pos_view, nrm_view, uColor, 
			uPointLight[i].viewPos, uPointLight[i].radiusInfo,
			uPointLight[i].color);
		diffuseColor += dd;
		specularColor += ds;
	}

	vec4 sample_dm = texture(uTex_dm, texcoord.xy);
	vec4 sample_sm = texture(uTex_sm, texcoord.xy);
	rtFragColor = sample_dm * diffuseColor + sample_sm * specularColor;
	rtFragColor.a = sample_dm.a;
	
	// MRT
	rtFragNormal = vec4(nrm_view.xyz * 0.5 + 0.5, 1.0);
	
	// DEBUGGING
	//rtFragColor.rgb = texcoord;
}
