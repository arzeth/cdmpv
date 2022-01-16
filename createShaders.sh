if [[ "$MPV__CONFIG_DIR" == "" ]]
then
	>&2 echo "This file must be called by x11wid.sh"
	exit 1
fi

s="$MPV__CONFIG_DIR/shaders"

declare -a F=(
	"$s/ACNetGLSL/glsl/ACNet.glsl"
	"$s/ACNetGLSL/glsl/ACNet_HDN_L1.glsl"
	"$s/ACNetGLSL/glsl/ACNet_HDN_L2.glsl"
	"$s/ACNetGLSL/glsl/ACNet_HDN_L3.glsl"
	"$s/TsubaUP.glsl"
	"$s/igv/FSRCNNX_x2_16-0-4-1.glsl"
	"$s/igv/FSRCNNX_x2_8-0-4-1_LineArt.glsl"
	"$s/igv/FSRCNNX_x2_16-0-4-1_anime_enhance.glsl"
	"$s/Anime4K_Upscale_CNN_x2_S.glsl"
	"$s/Anime4K_Upscale_CNN_x2_M.glsl"
	"$s/Anime4K_Upscale_CNN_x2_L.glsl"
	"$s/Anime4K_Upscale_CNN_x2_VL.glsl"
	"$s/Anime4K_Upscale_CNN_x2_UL.glsl"
	"$s/Anime4K_Upscale_Denoise_CNN_x2_S.glsl"
	"$s/Anime4K_Upscale_Denoise_CNN_x2_M.glsl"
	"$s/Anime4K_Upscale_Denoise_CNN_x2_L.glsl"
	"$s/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl"
	"$s/Anime4K_Upscale_Denoise_CNN_x2_UL.glsl"
	"$s/Anime4K_Upscale_GAN_x2_S.glsl"
	"$s/Anime4K_Upscale_GAN_x2_M.glsl"
	"$s/Anime4K_Upscale_GAN_x3_L.glsl"
	"$s/Anime4K_Upscale_GAN_x3_VL.glsl"
	"$s/Anime4K_Upscale_GAN_x4_UL.glsl"
	"$s/Anime4K_Upscale_GAN_x4_UUL.glsl"
	"$s/avisynth/mpv user shaders/LineArt/3x/AiUpscale_HQ_3x_LineArt.glsl"
	"$s/avisynth/mpv user shaders/LineArt/2x/AiUpscale_HQ_2x_LineArt.glsl"
)
for a in "${F[@]}"
do
	if [[ ! -r "$a" ]]; then continue; fi
	b=${a/.glsl/F.glsl}
	if [[ ! -r "$b" ]]
	then
		echo "$b not found, creating it"
		cat "$a" | perl -pe 's@^//!WHEN.+\n@@g' > "$b"
	fi
done



if [[ ! -f "$s/Anime4K_Restore_CNN_Light_Soft_UL-LUMA.glsl" ]]
then
	for a in "$s/Anime4K_Restore"*.glsl
	do
		u=LUMA bash "$s/resluma.sh" "$a"
	done
fi
if [[ ! -f "$s/Anime4K_Restore_CNN_Light_Soft_UL-YYY.glsl" ]]
then
	for a in "$s/Anime4K_Restore"*.glsl
	do
		u=YYY bash "$s/resluma.sh" "$a"
	done
fi

if [[ ! -f "$s/Anime4K_Upscale_CNN_x2_UL-LUMA.glsl" ]]
then
	for a in "$s/Anime4K_Upscale"*.glsl
	do
		u=LUMA bash "$s/upluma.sh" "$a"
	done
fi

if [[ ! -r "$s/Anime4K_Restore_CNN_Light_Soft_VL-YYY-half.glsl" ]]
then
	declare -a H=(
		"$s/Anime4K_Restore_CNN_Light_Soft_S.glsl"
		"$s/Anime4K_Restore_CNN_Light_Soft_VL.glsl"
	)
	for a in "${H[@]}"
	do
		if [[ ! -r "$a" ]]; then
			continue;
		fi
		half=1 u=YYY bash "$s/resluma.sh" "$a"
	done
fi

if [[ ! -r "$s/Anime4K_Restore_CNN_Light_VL-YYY-half.glsl" ]]
then
	declare -a H=(
		"$s/Anime4K_Restore_CNN_Light_VL.glsl"
		"$s/Anime4K_Restore_CNN_Light_S.glsl"
	)
	for a in "${H[@]}"
	do
		if [[ ! -r "$a" ]]; then
			continue;
		fi
		half=1 u=YYY bash "$s/resluma.sh" "$a"
	done
fi
