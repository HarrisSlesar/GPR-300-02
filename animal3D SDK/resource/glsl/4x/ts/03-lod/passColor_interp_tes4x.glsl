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
	
	passColor_interp_tes4x.glsl
	Pass color, outputting result of interpolation.
*/

#version 450

// ****DONE: 
//	-> declare uniform block for spline waypoint and handle data
//	-> implement spline interpolation algorithm based on scene object's path
//	-> interpolate along curve using correct inputs and project result

layout (isolines, equal_spacing) in;

uniform ubCurve
{
	vec4 uCurveWaypoint[32];
	vec4 uCurveTangent[32];
};
uniform int uCount;

uniform mat4 uP;

out vec4 vColor;

mat4 MH = mat4(
				2, -2, 1, 1,
				-3, 3, -2, -1,
				0, 0, 1, 0,
				1, 0, 0, 0);

float s = 0.5;

mat4 CRBasis = mat4(
				-s, 2-s, s-2, s,
				2s, s-3, 3-float(2s), -s,
				-s, 0, s, 0,
				0, 1, 0, 0);

mat4 MCR = mat4(
				0, -1, 2, -1,
				2, 0, -5, 3,
				0, 1, 4, -3,
				0, 0, -1, 1);

mat4 M = mat4(
				0, 2, 0, 0,
				-1, 0, 1, 0,
				1, -5, 4, -1,
				-1, 3, -3, 1);

void main()
{
	int i0 = gl_PrimitiveID;
	int i1 = (i0 + 1) % uCount;
	float t = gl_TessCoord.x;
	
	/*
	vec4 p = mix(
		uCurveWaypoint[i0],
		uCurveWaypoint[i1],
		t);
		*/
	//Replace this linear interpolation with another algorithm to draw a curve
	
	
	vec4 p;
	//vec4 slope0 = uCurveTangent[i0] - uCurveWaypoint[i0];
	//vec4 slope1 = uCurveTangent[i1] - uCurveWaypoint[i1];

	vec4 point0= uCurveWaypoint[(i0-1)%uCount];
	vec4 point1= uCurveWaypoint[i0];
	vec4 point2= uCurveWaypoint[i1];
	vec4 point3= uCurveWaypoint[(i1+1) % uCount];

	mat4 influenceMat = mat4(point0,point1,point2,point3);

	vec4 tVec = vec4(1,t,pow(t,2),pow(t,3));

	vec4 testVec = vec4(-t+2*pow(t,2)-pow(t,3),
						2-5*pow(t,2)+3*pow(t,3),
						t + 4*pow(t,2)-3*pow(t,3),
						-pow(t,2) + pow(t,3));


	p =0.5 * (influenceMat * testVec);

	

	
	
	



	//vec4 p = vec4(gl_TessCoord.xy, -1.0, 1.0);


	gl_Position = uP * p;

	vColor = vec4(0.5, 0.5, t, 1.0);
}
