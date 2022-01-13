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

//!DESC Anime4K-v3.2-Denoise-Bilateral-MeanFix-CHROMA
//!HOOK CHROMA
//!BIND LUMA
//!BIND CHROMA

#define INTENSITY_SIGMA 0.02 //Intensity window size, higher is stronger denoise, must be a positive real number
#define SPATIAL_SIGMA 1.0 //Spatial window size, higher is stronger denoise, must be a positive real number.

#define INTENSITY_POWER_CURVE 1.0 //Intensity window power curve. Setting it to 0 will make the intensity window treat all intensities equally, while increasing it will make the window narrower in darker intensities and wider in brighter intensities.

#define KERNELSIZE (max(int(ceil(SPATIAL_SIGMA * 2.0)), 1) * 2 + 1) //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE (int(KERNELSIZE/2)) //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).
#define KERNELLEN (KERNELSIZE * KERNELSIZE) //Total area of kernel. Must be equal to KERNELSIZE * KERNELSIZE.

#define GETOFFSET(i) vec2((i % KERNELSIZE) - KERNELHALFSIZE, (i / KERNELSIZE) - KERNELHALFSIZE)

vec4 gaussian_vec(vec4 x, vec4 s, vec4 m) {
	vec4 scaled = (x - m) / s;
	return exp(-0.5 * scaled * scaled);
}

float gaussian(float x, float s, float m) {
	float scaled = (x - m) / s;
	return exp(-0.5 * scaled * scaled);
}

vec4 hook() {
	vec4 sum = vec4(0.0);
	vec4 n = vec4(0.0);
	
	//vec4 vc = CHROMA_tex(CHROMA_pos);
	vec3 oldAsYUV = vec3(1.0/*LUMA_tex(LUMA_pos).x*/, CHROMA_tex(CHROMA_pos).xy);
	vec4 vc = vec4(mat3(1,1,1,0,-0.21482,2.12798,1.28033,-0.38059,0)*oldAsYUV, 0.0);

	
	vec4 is = pow(vc + 0.0001, vec4(INTENSITY_POWER_CURVE)) * INTENSITY_SIGMA;
	float ss = SPATIAL_SIGMA;
	
	for (int i=0; i<KERNELLEN; i++) {
		vec2 ipos = GETOFFSET(i);
		//vec4 v = CHROMA_texOff(ipos);
		vec4 v = vec4(
			mat3(1,1,1,0,-0.21482,2.12798,1.28033,-0.38059,0)
			*
			vec3(1.0/*LUMA_texOff(ipos).x*/, CHROMA_texOff(ipos).xy),
			0.0
		);
		vec4 d = gaussian_vec(v, is, vc) * gaussian(length(ipos), ss, 0.0);
		sum += d * v;
		n += d;
	}
	
	vec4 retAsRGB = sum / n;
	return vec4(
		(mat3(0.2126,-0.09991,0.615,0.7152,-0.33609,-0.55861,0.0722,0.436,-0.05639)*retAsRGB.rgb).yz, 
		0.0, 
		0.0
	);//1.0);
}
