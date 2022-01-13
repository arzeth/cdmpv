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

//!DESC Anime4K-v4.0-De-Ring-Compute-Statistics
//!HOOK MAIN
//!BIND HOOKED
//!SAVE STATSMAX
//!COMPONENTS 1

#define KERNELSIZE 5 //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE 2 //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).

vec3 sRGBToLinear(vec3 rgb)
{
  // See https://gamedev.stackexchange.com/questions/92015/optimized-linear-to-srgb-glsl
  return mix(pow((rgb + 0.055) * (1.0 / 1.055), vec3(2.4)),
             rgb * (1.0/12.92),
             lessThanEqual(rgb, vec3(0.04045)));
}

vec3 LinearToSRGB(vec3 rgb)
{
  // See https://gamedev.stackexchange.com/questions/92015/optimized-linear-to-srgb-glsl
  return mix(1.055 * pow(rgb, vec3(1.0 / 2.4)) - 0.055,
             rgb * 12.92,
             lessThanEqual(rgb, vec3(0.0031308)));
}

vec3 rgb2xyz(vec3 c) {
    /*vec3 tmp;
    tmp.x = (c.r > 0.04045) ? pow( (c.r + 0.055) / 1.055, 2.4) : c.r / 12.92;
    tmp.y = (c.g > 0.04045) ? pow( (c.g + 0.055) / 1.055, 2.4) : c.g / 12.92;
    tmp.z = (c.b > 0.04045) ? pow( (c.b + 0.055) / 1.055, 2.4) : c.b / 12.92;*/
	 vec3 tmp = sRGBToLinear(c);
    
    return 100.0 * tmp * mat3(0.4124, 0.3576, 0.1805,
                              0.2126, 0.7152, 0.0722,
                              0.0193, 0.1192, 0.9505);
}

vec3 xyz2lab(vec3 c) {
    vec3 n = c / vec3(95.047, 100, 108.883);
    vec3 v;
	 v.x = (n.x > 216/24389) ? pow(n.x, 1.0 / 3.0) : (7.787 * n.x) + (16.0 / 116.0);
    //v.y = (n.y > 216/24389) ? pow(n.y, 1.0 / 3.0) : (7.787 * n.y) + (16.0 / 116.0);
    v.z = (n.z > 216/24389) ? pow(n.z, 1.0 / 3.0) : (7.787 * n.z) + (16.0 / 116.0);
    
    //v.x = (n.x > 216/24389) ? pow(n.x, 1.0 / 3.0)*116.0-16.0 : n.y* (24389/27);
    v.y = (n.y > 216/24389) ? pow(n.y, 1.0 / 3.0)*116.0-16.0 : n.y* (24389/27);
    //v.z = (n.z > 216/24389) ? pow(n.z, 1.0 / 3.0)*116.0-16.0 : n.y* (24389/27);
    
	 //return vec3((116.0 * v.y) - 16.0, 500.0 * (v.x - v.y), 200.0 * (v.y - v.z));
    return vec3(v.y, 500.0 * (v.x - v.y), 200.0 * (v.y - v.z));
}

vec3 rgb2lab(vec3 c) {
   vec3 lab = xyz2lab(rgb2xyz(c));
   return vec3(lab.x / 100.0, 0.5 + 0.5 * (lab.y / 127.0), 0.5 + 0.5 * (lab.z / 127.0));
}



float get_luma(vec4 rgba) {
	return dot(vec4(0.299, 0.587, 0.114, 0.0), rgba);
	//return float(rgb2lab(rgba.rgb));
	//return dot(vec4(ret.r, ret.g, ret.b, 0.0), rgba);
	//return dot(vec4(0.2126, 0.7152, 0.0722, 0.0), rgba);
	/*return (
		0.241*pow(rgba.r, 2)
		+
		0.691*pow(rgba.g, 2)
		+
		0.068*pow(rgba.b, 2)
	);*/
	return sqrt(
		0.299*pow(rgba.r, 2)
		+
		0.587*pow(rgba.g, 2)
		+
		0.114*pow(rgba.b, 2)
	);
	//rgba.r /= 2;
	//rgba.b /= 2;
	//rgba.a /= 2;
	rgba.r = clamp(rgba.r, 0.0, 1.0);
	rgba.g = clamp(rgba.g, 0.0, 1.0);
	rgba.b = clamp(rgba.b, 0.0, 1.0);
	/*if (rgba.r > 1.0) rgba.r = 1.0;
	if (rgba.g > 1.0) rgba.g = 1.0;
	if (rgba.b > 1.0) rgba.b = 1.0;
	if (rgba.a > 1.0) rgba.a = 1.0;

	if (rgba.r < 0.0) rgba.r = 0.0;
	if (rgba.g < 0.0) rgba.g = 0.0;
	if (rgba.b < 0.0) rgba.b = 0.0;
	if (rgba.a < 0.0) rgba.a = 0.0;*/
	float r = (rgba.r > 0.04045) ? pow((rgba.r + 0.055) / 1.055, 2.4) : rgba.r / 12.92;
	float g = (rgba.g > 0.04045) ? pow((rgba.g + 0.055) / 1.055, 2.4) : rgba.g / 12.92;
	float b = (rgba.b > 0.04045) ? pow((rgba.b + 0.055) / 1.055, 2.4) : rgba.b / 12.92;

	float x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047;
	float y = (r * 0.2126 + g * 0.7152 + b * 0.0722);// / 1.00000;
	float z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883;

	return y;
	//return dot(vec4(x, y, z, 0.0), rgba);

  /*x = (x > 216/24389) ? pow(x, 1/3) : (7.787 * x) + 16/116;
  y = (y > 216/24389) ? pow(y, 1/3) : (7.787 * y) + 16/116;
  z = (z > 216/24389) ? pow(z, 1/3) : (7.787 * z) + 16/116;

  float A = (116 * y) - 16;
  float B = 500 * (x - y);
  float C = 200 * (y - z);*/
  //return A;
  //return dot(vec4(B/255, A/255, C/255, 0.0), rgba);

	/*if ( x <= (216/24389)) {       // The CIE standard states 0.008856 but 216/24389 is the intent for 0.008856451679036
		x = (x * (24389/27)) / 100;  // The CIE standard states 903.3, but 24389/27 is the intent, making 903.296296296296296
	} else {
		x = (pow(x, (1/3)) * 116 - 16) / 100;
	}
	if ( y <= (216/24389)) {       // The CIE standard states 0.008856 but 216/24389 is the intent for 0.008856451679036
		y = (y * (24389/27)) / 100;  // The CIE standard states 903.3, but 24389/27 is the intent, making 903.296296296296296
	} else {
		y = (pow(y, (1/3)) * 116 - 16) / 100;
	}
	if ( z <= (216/24389)) {       // The CIE standard states 0.008856 but 216/24389 is the intent for 0.008856451679036
		z = (z * (24389/27)) / 100;  // The CIE standard states 903.3, but 24389/27 is the intent, making 903.296296296296296
	} else {
		z = (pow(z, (1/3)) * 116 - 16) / 100;
	}*/
	
}

vec4 hook() {

	float gmax = 0.0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float g = get_luma(MAIN_texOff(vec2(i - KERNELHALFSIZE, 0)));
		
		gmax = max(g, gmax);
	}
	
	return vec4(gmax, 0.0, 0.0, 0.0);
}

//!DESC Anime4K-v4.0-De-Ring-Compute-Statistics
//!HOOK MAIN
//!BIND HOOKED
//!BIND STATSMAX
//!SAVE STATSMAX
//!COMPONENTS 1

#define KERNELSIZE 5 //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE 2 //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).

vec4 hook() {

	float gmax = 0.0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float g = STATSMAX_texOff(vec2(0, i - KERNELHALFSIZE)).x;
		
		gmax = max(g, gmax);
	}
	
	return vec4(gmax, 0.0, 0.0, 0.0);
}

//!DESC Anime4K-v4.0-De-Ring-Clamp
//!HOOK PREKERNEL
//!BIND HOOKED
//!BIND STATSMAX


vec3 sRGBToLinear(vec3 rgb)
{
  // See https://gamedev.stackexchange.com/questions/92015/optimized-linear-to-srgb-glsl
  return mix(pow((rgb + 0.055) * (1.0 / 1.055), vec3(2.4)),
             rgb * (1.0/12.92),
             lessThanEqual(rgb, vec3(0.04045)));
}

vec3 LinearToSRGB(vec3 rgb)
{
  // See https://gamedev.stackexchange.com/questions/92015/optimized-linear-to-srgb-glsl
  return mix(1.055 * pow(rgb, vec3(1.0 / 2.4)) - 0.055,
             rgb * 12.92,
             lessThanEqual(rgb, vec3(0.0031308)));
}

vec3 rgb2xyz(vec3 c) {
    /*vec3 tmp;
    tmp.x = (c.r > 0.04045) ? pow( (c.r + 0.055) / 1.055, 2.4) : c.r / 12.92;
    tmp.y = (c.g > 0.04045) ? pow( (c.g + 0.055) / 1.055, 2.4) : c.g / 12.92;
    tmp.z = (c.b > 0.04045) ? pow( (c.b + 0.055) / 1.055, 2.4) : c.b / 12.92;*/
	 vec3 tmp = sRGBToLinear(c);
    
    return 100.0 * tmp * mat3(0.4124, 0.3576, 0.1805,
                              0.2126, 0.7152, 0.0722,
                              0.0193, 0.1192, 0.9505);
}

vec3 xyz2lab(vec3 c) {
    vec3 n = c / vec3(95.047, 100, 108.883);
    vec3 v;
	 v.x = (n.x > 216/24389) ? pow(n.x, 1.0 / 3.0) : (7.787 * n.x) + (16.0 / 116.0);
    //v.y = (n.y > 216/24389) ? pow(n.y, 1.0 / 3.0) : (7.787 * n.y) + (16.0 / 116.0);
    v.z = (n.z > 216/24389) ? pow(n.z, 1.0 / 3.0) : (7.787 * n.z) + (16.0 / 116.0);
    
    //v.x = (n.x > 216/24389) ? pow(n.x, 1.0 / 3.0)*116.0-16.0 : n.y* (24389/27);
    v.y = (n.y > 216/24389) ? pow(n.y, 1.0 / 3.0)*116.0-16.0 : n.y* (24389/27);
    //v.z = (n.z > 216/24389) ? pow(n.z, 1.0 / 3.0)*116.0-16.0 : n.y* (24389/27);
    
	 //return vec3((116.0 * v.y) - 16.0, 500.0 * (v.x - v.y), 200.0 * (v.y - v.z));
    return vec3(v.y, 500.0 * (v.x - v.y), 200.0 * (v.y - v.z));
}

vec3 rgb2lab(vec3 c) {
   vec3 lab = xyz2lab(rgb2xyz(c));
   return vec3(lab.x / 100.0, 0.5 + 0.5 * (lab.y / 127.0), 0.5 + 0.5 * (lab.z / 127.0));
}



float get_luma(vec4 rgba) {
	return dot(vec4(0.299, 0.587, 0.114, 0.0), rgba);
	//return float(rgb2lab(rgba.rgb));
	//return dot(vec4(ret.r, ret.g, ret.b, 0.0), rgba);
	//return dot(vec4(0.2126, 0.7152, 0.0722, 0.0), rgba);
	/*return (
		0.241*pow(rgba.r, 2)
		+
		0.691*pow(rgba.g, 2)
		+
		0.068*pow(rgba.b, 2)
	);*/
	return sqrt(
		0.299*pow(rgba.r, 2)
		+
		0.587*pow(rgba.g, 2)
		+
		0.114*pow(rgba.b, 2)
	);

	//rgba.r /= 2;
	//rgba.b /= 2;
	//rgba.a /= 2;
	rgba.r = clamp(rgba.r, 0.0, 1.0);
	rgba.g = clamp(rgba.g, 0.0, 1.0);
	rgba.b = clamp(rgba.b, 0.0, 1.0);
	/*if (rgba.r > 1.0) rgba.r = 1.0;
	if (rgba.g > 1.0) rgba.g = 1.0;
	if (rgba.b > 1.0) rgba.b = 1.0;
	if (rgba.a > 1.0) rgba.a = 1.0;

	if (rgba.r < 0.0) rgba.r = 0.0;
	if (rgba.g < 0.0) rgba.g = 0.0;
	if (rgba.b < 0.0) rgba.b = 0.0;
	if (rgba.a < 0.0) rgba.a = 0.0;*/
	float r = (rgba.r > 0.04045) ? pow((rgba.r + 0.055) / 1.055, 2.4) : rgba.r / 12.92;
	float g = (rgba.g > 0.04045) ? pow((rgba.g + 0.055) / 1.055, 2.4) : rgba.g / 12.92;
	float b = (rgba.b > 0.04045) ? pow((rgba.b + 0.055) / 1.055, 2.4) : rgba.b / 12.92;

	float x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047;
	float y = (r * 0.2126 + g * 0.7152 + b * 0.0722);// / 1.00000;
	float z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883;

	return y;
	//return dot(vec4(x, y, z, 0.0), rgba);

  /*x = (x > 216/24389) ? pow(x, 1/3) : (7.787 * x) + 16/116;
  y = (y > 216/24389) ? pow(y, 1/3) : (7.787 * y) + 16/116;
  z = (z > 216/24389) ? pow(z, 1/3) : (7.787 * z) + 16/116;

  float A = (116 * y) - 16;
  float B = 500 * (x - y);
  float C = 200 * (y - z);*/
  //return A;
  //return dot(vec4(B/255, A/255, C/255, 0.0), rgba);

	/*if ( x <= (216/24389)) {       // The CIE standard states 0.008856 but 216/24389 is the intent for 0.008856451679036
		x = (x * (24389/27)) / 100;  // The CIE standard states 903.3, but 24389/27 is the intent, making 903.296296296296296
	} else {
		x = (pow(x, (1/3)) * 116 - 16) / 100;
	}
	if ( y <= (216/24389)) {       // The CIE standard states 0.008856 but 216/24389 is the intent for 0.008856451679036
		y = (y * (24389/27)) / 100;  // The CIE standard states 903.3, but 24389/27 is the intent, making 903.296296296296296
	} else {
		y = (pow(y, (1/3)) * 116 - 16) / 100;
	}
	if ( z <= (216/24389)) {       // The CIE standard states 0.008856 but 216/24389 is the intent for 0.008856451679036
		z = (z * (24389/27)) / 100;  // The CIE standard states 903.3, but 24389/27 is the intent, making 903.296296296296296
	} else {
		z = (pow(z, (1/3)) * 116 - 16) / 100;
	}*/
	
}

vec4 hook() {
//return HOOKED_tex(HOOKED_pos);
	float current_luma = get_luma(HOOKED_tex(HOOKED_pos));
	float new_luma = min(current_luma, STATSMAX_tex(HOOKED_pos).x);
	
	//This trick is only possible if the inverse Y->RGB matrix has 1 for every row... (which is the case for BT.709)
	//Otherwise we would need to convert RGB to YUV, modify Y then convert back to RGB.
    return HOOKED_tex(HOOKED_pos) - (current_luma - new_luma); 
}