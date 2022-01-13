// MIT License

// Copyright (c) 2019-2021 bloc97
// All rights reserved.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//!DESC ANTIREDAnime4K-v4.0-De-Ring-Compute-Statistics
//!HOOK MAIN
//!BIND HOOKED
//!WIDTH LUMA.w 3 *
//!HEIGHT LUMA.h 3 *
//!SAVE CRSTATSMAX
//!COMPONENTS 1

#define KERNELSIZE 3 //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE 1 //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).

vec4 hook() {

	float gmax = 0.0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float g = MAIN_texOff(vec2(i - KERNELHALFSIZE, 0)).r;
		
		gmax = max(g, gmax);
	}
	
	return vec4(gmax, 0.0, 0.0, 0.0);
}

//!DESC ANTIREDAnime4K-v4.0-De-Ring-Compute-Statistics
//!HOOK MAIN
//!BIND HOOKED
//!BIND CRSTATSMAX
//!SAVE CRSTATSMAX
//!COMPONENTS 1

#define KERNELSIZE 3 //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE 1 //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).

vec4 hook() {

	float gmax = 0.0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float g = CRSTATSMAX_texOff(vec2(0, i - KERNELHALFSIZE)).x;
		
		gmax = max(g, gmax);
	}
	
	return vec4(gmax, 0.0, 0.0, 0.0);
}

//!DESC ANTIREDAnime4K-v4.0-De-Ring-Clamp
//!HOOK PREKERNEL
//!BIND HOOKED
//!BIND CRSTATSMAX


vec4 hook() {	
	vec3 old = HOOKED_tex(HOOKED_pos).rgb;

	if (old.g < 0.3 && old.b < 0.3 && old.r > 0.03 && (old.r * 0.8 > old.g && old.r * 0.8 > old.b))
	{
		float current_luma = HOOKED_tex(HOOKED_pos).r;
		float new_luma = min(current_luma, CRSTATSMAX_tex(HOOKED_pos).x);
		//const float newR = old.r - (current_luma - new_luma);
		const float newR = new_luma;
		old.r = newR;
	}

	vec4 ret = vec4(
		old.rgb,
		0.0
	);
	return ret;
}