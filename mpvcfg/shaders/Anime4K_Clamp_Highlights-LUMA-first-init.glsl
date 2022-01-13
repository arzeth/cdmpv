//!DESC Anime4K-v4.0-De-Ring-Compute-Statistics
//!HOOK LUMA
//!BIND HOOKED
//!SAVE STATSMAX
//!COMPONENTS 1


// 7+3 & 3+1 is better than 3+1 & 3+1, but 7+3 & 3+1 produce worse fonts
// 3+1 & 5+2 is better than 3+1 & 3+1 because 3+1 & 3+1 darkens more and worse fonts
#define KERNELSIZE 5 //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE 2 //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).

vec4 hook() {

	float gmax = 0.0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float g = LUMA_texOff(vec2(i - KERNELHALFSIZE, 0)).x;
		
		gmax = max(g, gmax);
	}
	
	return vec4(gmax, 0.0, 0.0, 0.0);
}




//!DESC Anime4K-v4.0-De-Ring-Compute-Statistics
//!HOOK LUMA
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
