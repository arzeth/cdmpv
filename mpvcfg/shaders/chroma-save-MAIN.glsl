//!HOOK MAIN
//!BIND HOOKED
//!WIDTH HOOKED.w
//!HEIGHT HOOKED.h
//!COMPONENTS 2
//!DESC Save the UV channels
//!SAVE OLDCHROMA
vec4 hook() {
	return vec4(
		(
			mat3(0.2126,-0.09991,0.615,0.7152,-0.33609,-0.55861,0.0722,0.436,-0.05639)*HOOKED_tex(HOOKED_pos).rgb
		).yz,
		0,
		0
	);
}
