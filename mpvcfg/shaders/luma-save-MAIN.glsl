//!HOOK MAIN
//!BIND HOOKED
//!WIDTH HOOKED.w
//!HEIGHT HOOKED.h
//!COMPONENTS 1
//!DESC Save the Y channel
//!SAVE OLDLUMA
vec4 hook ()
{
    return dot(HOOKED_texOff(0).rgb, vec3(0.2126, 0.7152, 0.0722)).xxxx;
}
