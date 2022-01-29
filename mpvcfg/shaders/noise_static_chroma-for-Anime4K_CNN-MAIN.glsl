//!HOOK MAIN
//!BIND MAIN
//!WIDTH MAIN.w
//!HEIGHT MAIN.h

// Change this to tune the strength of the noise
// Apparently this has to be float on some setups
#define STRENGTH 320.0
// SSIM:
// 60  ⇒ 0.003681572906947287
// 160 => 0.0034563423781667816
// 220 ⇒ 0.0033535064060950842
// 260 ⇒ 0.003301794947646612
// 300 ⇒ 0.003261146734237132
// 320 ⇒ 0.003244548416460475
// 400 ⇒ 0.0031945167069293875
// 500 ⇒ 0.0031620850086005914
// 560 ⇒ 0.0031542018316221268
// 600 ⇒ 0.003151581617229352

// PRNG taken from mpv's deband shader
float mod289(float x)  { return x - floor(x / 289.0) * 289.0; }
float permute(float x) { return mod289((34.0*x + 1.0) * x); }
float rand(float x)    { return fract(x / 41.0); }

vec4 hook()  {
    vec4 old = MAIN_tex(MAIN_pos);
    if (old.r > 0.98 && old.g > 0.98 && old.b > 0.98) return old;
    if ( // don't noise the pink color
        old.g < old.r * 0.7
        &&
        old.g < old.b * 0.7
        &&
        old.b * 0.97 < old.r && old.r < old.b * 1.43
    ) return old;
    //if (old.r > 0.9 && old.g > 0.9 && old.b > 0.9) return old;
    vec3 oldAsYUV = mat3(0.2126,-0.09991,0.615,0.7152,-0.33609,-0.55861,0.0722,0.436,-0.05639)*old.rgb;
    ////if (oldAsYUV.x > 0.9) return old;

    vec3 _m = vec3(MAIN_pos, 0.5) + vec3(1.0);
    float h = permute(permute(permute(_m.x)+_m.y)+_m.z);
    vec2 noise;
    noise.x = rand(h); h = permute(h);
    noise.y = rand(h);
    oldAsYUV.yz += (vec2(STRENGTH/8192.0) * (noise - 0.5));
    vec4 ret = vec4(mat3(1,1,1,0,-0.21482,2.12798,1.28033,-0.38059,0) * oldAsYUV.xyz, old.a);
    if ( // don't noise the pink color
        ret.g < ret.r * 0.7
        &&
        ret.g < ret.b * 0.7
        &&
        ret.b * 0.97 < ret.r && ret.r < ret.b * 1.43
    ) return old;
    return ret;
    //return vec4(oldAsYUV, old.a);
    //return MAIN_tex(MAIN_pos) + vec4(STRENGTH/8192.0) * (noise - 0.5);
}