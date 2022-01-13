//!DESC Anime4K-v4.0-De-Ring-Clamp
//!HOOK LUMA
//!BIND HOOKED
//!BIND STATSMAX

vec4 hook() {

	float current_luma = HOOKED_tex(HOOKED_pos).x;
	float new_luma = min(current_luma, STATSMAX_tex(HOOKED_pos).x);
	// or:
	// float($var) or $var.x
	// ^ result is the same, I don't know what's better. The original uses .x.
	
	//This trick is only possible if the inverse Y->RGB matrix has 1 for every row... (which is the case for BT.709)
	//Otherwise we would need to convert RGB to YUV, modify Y then convert back to RGB.
	return HOOKED_tex(HOOKED_pos) - (current_luma - new_luma); 
}

