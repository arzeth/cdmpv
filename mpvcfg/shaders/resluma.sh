#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}/inc.sh"

u="${u:-LUMA}"
#u=LUMAXXX
#u=LUMA

if [[ "$YYY" == "1" ]]
then
	u=YYY
fi


for a in "$@"
do
	if [[
		   "${a}" =~ "LUMA"
		|| "${a}" =~ "Krig"
		|| "${a}" =~ "sxbr"
		|| "${a}" =~ "ravu"
		|| "${a}" =~ "percent"
		|| "${a}" =~ "YYY"
		|| "${a}" =~ "RGB"
		|| "${a}" =~ "MAIN"
		|| "${a}" =~ "NATIVE"
		|| "${a}" =~ "CHROMA"
	]]
	then
		#echo Skipping \`"$a"\`
		continue
	fi
	if [[ "${a}" == *.glsl ]]
	then
		echo -n
	else
		#echo Skipping \`"$a"\`
		continue
	fi
	if [[ "${u}" == "LUMA" || "${u}" == "YYY" ]]
	then
		b=${a/.glsl/-${u}.glsl}
		if [[ "$percent" == "50" ]]
		then
			b=${b/.glsl/-half.glsl}
		elif [[ "$percent" != "" ]]
		then
			b=${b/.glsl/-percent${percent}.glsl}
		fi
	else
		b=${a/.glsl/-LUMA-var-${u}.glsl}
	fi
	aa=`basename "$a"|sed 's/.glsl$//'`
	cp "$a" "$b"
#set -x
	if [[ "${u}" != "YYY" ]]
	then
		#sed -i 's/'${u}'_texOff(vec2(x_off, y_off)/vec4(mat3(1,1,1,0,-0.21482,2.12798,1.28033,-0.38059,0)*'${u}'_texOff(vec2(x_off, y_off).xyz, 0.0)/' "$b"
		sed -Ei 's/#define go_0\(x_off, y_off\) \(MAIN_texOff\(vec2\(x_off, y_off\)\)\)/vec4 yuva2rgba (vec4 yuva)\n{\n#define InvYUV(yuv)   ( mat3('${YUV2RGB_MATRIX}')*yuv )\nreturn vec4(InvYUV(yuva.xyz), 0.0);\n}\n#define go_0(x_off, y_off) (yuva2rgba('${u}'_texOff(vec2(x_off, y_off))))/g' "$b"
		#sed -i 's:return result + MAIN_tex(MAIN_pos);:return vec4(float(rgba2yuva(result) + '${u}'_TEX('${u}'_POS)), 0.0, 0.0, 0.0);:' "$b"
	fi

if [[ "0" == "1" ]]; then
 echo "\
vec4 ret = vec4(c0, c1, c2, c3) + yuva2rgba(LUMA_tex(LUMA_pos));\
    return vec4(\
        (mat3(0.2126,-0.09991,0.615,0.7152,-0.33609,-0.55861,0.0722,0.436,-0.05639) * ret.xyz).x,\
        0.0,\
        0.0,\
        1.0\
    );"
fi
	if [[ "${u}" != "YYY" ]]
	then
		sed -i 's:return result + MAIN_tex(MAIN_pos);:return vec4(float(vec4(mat3('${RGB2YUV_MATRIX}') * clamp(result.rgb, 0.0, 1.0), 1.0) + '${u}'_tex('${u}'_pos)), 0.0, 0.0, 0.0);:' "$b"
		if [[ "${u}" != "LUMA" ]]
		then
			#sed -Ei 's:(\(.*\)HOOK MAIN):$1\n//!SAVE '${u}: $b
			sed -Ei 's://!SAVE MAIN://!SAVE '${u}: "$b"
		fi
	fi
	if [[ "${u}" != "YYY" ]]
	then
		sed -i 's/HOOK MAIN/HOOK LUMA/g' "$b"
		sed -i 's/MAIN/'${u}'/g' "$b"
	fi
	if [[ "${u}" == "YYY" ]]
	then
		if [[ "$percent" == "50" ]]
		then
			xValue='(resultAsYUV.x + oldAsYUV.x) / 2'
		#elif [[ "$percent" == "75" ]]
		#then
			#xValue='(resultAsYUV.x + (resultAsYUV.x + oldAsYUV.x) / 2) / 2'
		#elif [[ "$percent" == "25" ]]
		#then
			#xValue='(oldAsYUV.x + (resultAsYUV.x + oldAsYUV.x) / 2) / 2'
		elif [[ "$percent" == "" ]]
		then
			xValue='resultAsYUV.x'
		else
			revPercent=`calc "1.0-0.${percent}" | sed 's/[^0-9.]//g' | tr -d "\n"`
			xValue="oldAsYUV.x < resultAsYUV.x ? oldAsYUV.x + (resultAsYUV.x - oldAsYUV.x) * 0.${percent} : resultAsYUV.x + (oldAsYUV.x - resultAsYUV.x) * ${revPercent}"
		fi
		sed -i 's^return result + MAIN_tex(MAIN_pos);^\
    vec4 old = MAIN_tex(MAIN_pos);\n\
    result += old;\n\
    vec3 resultAsYUV = mat3(0.2126,-0.09991,0.615,0.7152,-0.33609,-0.55861,0.0722,0.436,-0.05639)*result.rgb;\n\
    vec3 oldAsYUV = mat3(0.2126,-0.09991,0.615,0.7152,-0.33609,-0.55861,0.0722,0.436,-0.05639)*old.rgb;\n\
    oldAsYUV.x = '"$xValue"';\n\
    return vec4(mat3(1,1,1,0,-0.21482,2.12798,1.28033,-0.38059,0) * oldAsYUV.xyz, result.a);^' "$b"
	fi

	if [[ "${u}" == "LANCZOS3" || "${u}" == "LUMAXXX" ]]
	then
		b_va=`cat "$b"`
		#qf="${DIR}/avisynth/mpv user shaders/LineArt/2x/AiUpscale_HQ_2x_LineArtFCla.glsl"
		qf="${DIR}/avisynth/mpv user shaders/LineArt/3x/AiUpscale_HQ_3x_LineArtFCla.glsl"
		#qf="${DIR}/avisynth/mpv user shaders/LineArt/3x/AiUpscale_HQ_3x_LineArtF.glsl"
		qfb="${qf/.glsl/}---$aa.glsl"
		cat "$qf" | sed -z 's/\n/ѫ/g' | sed -E 's|//@p.+||' | sed -z 's/ѫ/\n/g' > "$qfb"
		echo >> "$qfb"
		cat "$b" >> "$qfb"
		echo >> "$qfb"
		cat "$qf" | sed -z 's/\n/ѫ/g' | sed -E 's|.+//@p||' | sed -z 's/ѫ/\n/g' >> "$qfb"
	fi
done

unset b
unset b_va
unset qf
unset qfb
unset xValue
unset revPercent
unset aa
unset u
