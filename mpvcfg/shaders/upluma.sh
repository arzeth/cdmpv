#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}/inc.sh"

u=LUMA

for a in "$@"
do
	if [[
		   "${a}" =~ "LUMA"
		|| "${a}" =~ "Krig"
		|| "${a}" =~ "sxbr"
		|| "${a}" =~ "ravu"
		|| "${a}" =~ "YYY"
		|| "${a}" =~ "RGB"
		|| "${a}" =~ "MAIN"
		|| "${a}" =~ "NATIVE"
		|| "${a}" =~ "CHROMA"
	]]
	then
		echo Skipping \`"$a"\`
		continue
	fi
	if [[ "${a}" == *.glsl ]]
	then
		echo -n
	else
		echo Skipping \`"$a"\`
		continue
	fi
	b=${a/.glsl/-LUMA.glsl}
	aa=`basename "$a"|sed 's/.glsl$//'`
	cp "$a" "$b"
#set -x
	#sed -i 's/'${u}'_texOff(vec2(x_off, y_off)/vec4(mat3(1,1,1,0,-0.21482,2.12798,1.28033,-0.38059,0)*'${u}'_texOff(vec2(x_off, y_off).xyz, 0.0)/' "$b"
	sed -Ei 's/#define go_0\(x_off, y_off\) \(MAIN_texOff\(vec2\(x_off, y_off\)\)\)/vec4 yuva2rgba (vec4 yuva)\n{\n#define InvYUV(yuv)   ( mat3('${YUV2RGB_MATRIX}')*yuv )\nreturn vec4(InvYUV(yuva.xyz), 0.0);\n}\n#define go_0(x_off, y_off) (yuva2rgba('${u}'_texOff(vec2(x_off, y_off))))/g' "$b"
	#sed -i 's:return result + MAIN_tex(MAIN_pos);:return vec4(float(rgba2yuva(result) + '${u}'_TEX('${u}'_POS)), 0.0, 0.0, 0.0);:' "$b"

	sed -i -zE 's@(conv1ups\.h\n//!WHEN[^\n]+\n)@\1\n\
vec4 yuva2rgba(vec4 yuva) {return vec4(mat3('${YUV2RGB_MATRIX}')*yuva.xyz, 1.0);}\n\
vec4 rgba2yuva(vec4 rgba) {return vec4(mat3('${RGB2YUV_MATRIX}')*rgba.rgb, 0.0);}\n@' "$b" || exit

	sed -i 's:return vec4(c0, c1, c2, c3) + MAIN_tex(MAIN_pos);:return vec4(float(vec4(mat3('${RGB2YUV_MATRIX}') * vec3(c0, c1, c2), 1.0) + '${u}'_tex('${u}'_pos)), 0.0, 0.0, 0.0);:' "$b"
	sed -i 's:return result + MAIN_tex(MAIN_pos);:\n\
return rgba2yuva(result + yuva2rgba('${u}'_tex('${u}'_pos)));:' \
 "$b" || exit

	if [[ "${u}" != "LUMA" ]]
	then
		#sed -Ei 's:(\(.*\)HOOK MAIN):$1\n//!SAVE '${u}: $b
		sed -Ei 's://!SAVE MAIN://!SAVE '${u}: "$b"
	fi
	sed -i 's/HOOK MAIN/HOOK LUMA/g' "$b"
	sed -i 's/MAIN/'${u}'/g' "$b"
done
