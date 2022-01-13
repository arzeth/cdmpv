//!HOOK MAIN
//!BIND MAIN
//!WIDTH MAIN.w
//!HEIGHT MAIN.h
//!SAVE MAIN

// Change this to tune the strength of the noise
// Apparently this has to be float on some setups
#define STRENGTH 220.0
//150 => tmpvk12 0.003482213901122868
//160 => tmpvk12 0.003474808904664766

// PRNG taken from mpv's deband shader
float mod289(float x)  { return x - floor(x / 289.0) * 289.0; }
float permute(float x) { return mod289((34.0*x + 1.0) * x); }
float rand(float x)    { return fract(x / 41.0); }

vec4 hook()  {
    vec3 _m = vec3(MAIN_pos, 0.5) + vec3(1.0);
    float h = permute(permute(permute(_m.x)+_m.y)+_m.z);
    //vec2 noise;
    //noise.x = rand(h);
    vec4 old = MAIN_tex(MAIN_pos);
    vec3 oldAsYUV = mat3(0.2126,-0.09991,0.615,0.7152,-0.33609,-0.55861,0.0722,0.436,-0.05639)*old.rgb;
    oldAsYUV.x += ((STRENGTH/8192.0) * (rand(h) - 0.5));
    return vec4(mat3(1,1,1,0,-0.21482,2.12798,1.28033,-0.38059,0) * oldAsYUV.xyz, old.a);
    //return vec4(oldAsYUV, old.a);
    //return MAIN_tex(MAIN_pos) + vec4(STRENGTH/8192.0) * (noise - 0.5);
}