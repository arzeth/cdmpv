#!/bin/bash
trap "trap - SIGTERM && echo 'Caught SIGTERM, sending SIGTERM to process group' && kill -9 -- -$$" SIGINT SIGTERM EXIT
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}"/config.sh
source "${DIR}"/vars.sh
source "${DIR}"/.env-of-current-process
#D=${D/:/}

res_re='^[0-9]+x[0-9]+$'
fps_re='^[0-9]+(\.[0-9]+)?(/[0-9]+(\.[0-9]+)?)?$'

if [[ "$1" =~ $res_re && "$2" =~ $fps_re ]]
then
	UPSCALED_FPS="$2"
	GUEST_RES="$1"
else
	UPSCALED_FPS=${1:-${UPSCALED_FPS:-10}}
	GUEST_RES=${2:-${GUEST_RES:-800x600}}
fi

unset res_re
unset fps_re


D=${3:-${GUEST_DISPLAY:-${DISPLAY}}}


source "$DIR"/createShaders.sh


MPV=mpv
#MPV=/u/mpv-fork/build/mpv
FFMPEG=ffmpeg
#FFMPEG=/u/FFmpeg/ffmpeg

#fgw=`cat /tmp/game`
#wup=`cat /tmp/WUP`


if [[ "$GUEST_RES" == "800x600" ]]
then
	if [[ "$C" == "" || "$C" == "0" ]]
	then
		C=""
	elif [[ "$C" == "2" ]]
	then
		#C="800:460:0:70"
		C="800:460:0:30"
	elif [[ "$C" == "3" ]]
	then
		C="800:450:0:60"
	else
		C="800:550:0:25"
	fi
elif [[ "$GUEST_RES" == "1280x720" ]]
then
	if [[ "$C" == "2" ]]
	then
		C="1280:680:0:0"
		#--video-pan-y=-0.030
	fi
fi

if [[ "$C" == "" ]]
then
	newWidth=`echo -n "$GUEST_RES" | grep -oE '^[0-9]+' | tr -d "\n"`
	newHeight=`echo -n "$GUEST_RES" | grep -oE 'x[0-9]+' | grep -oE '[0-9]' | tr -d "\n"`
	newRes="$GUEST_RES"
else
	newWidth=`echo -n "$C" | grep -oE '^[0-9]+' | tr -d "\n"`
	newHeight=`echo -n "$C" | grep -oE ':[0-9]+:' | grep -oE '[0-9]' | tr -d "\n"`
	newRes="${newWidth}x${newHeight}"
fi

# if -framerate is less than child display server's refresh rate
# then MPV even with --vf=fps=10 display 2-3 FPS

#-vf mpdecimate,scale=w=640:h=480:flags=lanczos \

if [[ "$MP" == "1" ]]; then
	AAA="hi=$((64*1)):lo=$((64*1)):frac=0.1"
elif [[ "$MP" == "2" ]]; then
	AAA="hi=$((64*36)):lo=$((64*15)):frac=0.1"
elif [[ "$MP" == "3" ]]; then
	AAA="hi=$((64*108)):lo=$((64*15)):frac=0.1"
elif [[ "$MP" == "4" ]]; then
	AAA="hi=$((64*2034)):lo=$((64*15)):frac=0.1"
elif [[ "$MP" == "5" ]]; then
	AAA="hi=$((64*4068)):lo=$((64*15)):frac=0.1"
elif [[ "$MP" == "6" ]]; then
	AAA="hi=$((64*8100)):lo=$((64*7)):frac=0.1"
elif [[ "$MP" == "7" ]]; then
	AAA="hi=$((64*32400)):lo=$((64*1)):frac=0.5"
elif [[ "$MP" == "8" ]]; then
	AAA="hi=$((64*32400)):lo=$((64*500)):frac=0.5"
fi



max=`calc "floor($UPSCALED_FPS * $FORCE_RERENDER_EVERY)" | sed 's/\s//g' | tr -d "\n"`

UU1="rawvideo"
UU2="-vf"
if [[ "$GUEST_RES" == "800x600" && "$NC" == "1" ]]
then
	if [[ "$MP" == "0" || "$MP" == "" ]]
	then
		UU1="copy"
		UU2="-an"
		UU3="-an"
	else
		UU3="mpdecimate=${AAA}:max=$max"
	fi
else
	if [[ "$GUEST_RES" == "800x600" || "$C" != "" ]]
	then
		if [[ "$MP" == "0" ]]
		then
			UU3="crop=$C"
		else
			UU3="crop=$C,mpdecimate=${AAA}:max=$max"
		fi
	else
		if [[ "$MP" == "0" ]]
		then
			UU1="copy"
			UU2="-an"
			UU3="-an"
		else
			UU3="mpdecimate=${AAA}:max=$max"
		fi
	fi
fi


#-vf 'setpts=(RTCTIME - RTCSTART) / (TB * 1000000)' \
#ffmpeg -hide_banner -nostdin -vsync cfr -use_wallclock_as_timestamps 1 -fflags '+genpts' \
#-s "${GUEST_RES}" \
#if (( ${newWidth} < 1035 || ${prelumarepair} == 1 ))
if [[ "$prelumarepair" == "1" ]]
then
DISPLAY="${D}" "$FFMPEG" -hide_banner -nostdin -fflags '+flush_packets' \
-vsync vfr \
-nostats \
-f x11grab \
-framerate "${UPSCALED_FPS}" \
-i "${D}".0+0,0 \
\
-c:v "$UU1" \
-an \
-vsync vfr \
"$UU2" "$UU3" \
-threads 0 \
-f nut - \
\
\
| DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" "$MPV" --no-config --msg-level=all=no \
--no-pause --keep-open=no --interpolation=no --gpu-api=opengl --gpu-context=x11 --spirv-compiler=shaderc --fbo-format=rgba16f \
--no-input-default-bindings \
--no-input-terminal \
--no-input-cursor \
--no-input-vo-keyboard \
--gpu-shader-cache-dir="$MPV__SHADER_CACHE" \
--vo=none --vf="gpu=w=${newWidth}:h=${newHeight}" \
--glsl-shaders="$MPV__CONFIG_DIR/shaders/Anime4K_Restore_CNN_Moderate_Soft_M-YYY-percent25.glsl" \
--o=pipe:1 --ovc=rawvideo --of=nut \
\
\
--no-demuxer-thread --no-audio --keepaspect=yes \
--deband=no \
--stop-screensaver=no \
--video-latency-hacks=yes \
--demuxer=lavf --demuxer-lavf-format=nut \
--demuxer-lavf-probe-info=no \
--demuxer-lavf-o-add="avoid_negative_ts=make_zero" \
--demuxer-lavf-o-add="copyts=1" \
--demuxer-lavf-o-add="start_at_zero=1" \
--demuxer-lavf-o-add="fflags=+nobuffer+fastseek+flush_packets" \
--demuxer-lavf-probe-info=nostreams \
--demuxer-lavf-analyzeduration=0.1 \
--demuxer-readahead-secs=0 \
--demuxer-rawvideo-fps="${UPSCALED_FPS}" \
--no-correct-pts --untimed --cache=no --cache-pause=no - \
| \
\
\
DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" "$MPV" \
-v --no-audio --keepaspect=yes --keep-open=no --no-initial-audio-sync --profile=qrawvideo \
\
--title="cd_mp_v" \
--wid=`DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" wmctrl -l 2>/dev/null| egrep -i 'cdmpv' | egrep -i VNC | grep -vi 'Terminal' | sed -r 's/\s.+//g' | tr -d "\n"` \
--no-input-default-bindings \
--input-terminal \
--no-input-cursor \
--no-input-vo-keyboard \
--stop-screensaver=no \
--input-ipc-server="${DIR}/mpvsocket" \
--config-dir="$MPV__CONFIG_DIR" \
--input-conf="$MPV__INPUT_CONF" \
--gpu-shader-cache-dir="$MPV__SHADER_CACHE" \
\
--vd-lavc-threads=1 \
--interpolation=yes \
--deband=no \
--video-latency-hacks=yes \
--cache-pause=no \
--no-demuxer-thread \
--demuxer=lavf --demuxer-lavf-format=nut \
--demuxer-lavf-probe-info=no \
--demuxer-lavf-o-add="avoid_negative_ts=make_zero" \
--demuxer-lavf-o-add="copyts=1" \
--demuxer-lavf-o-add="start_at_zero=1" \
--demuxer-lavf-o-add="fflags=+nobuffer+fastseek+flush_packets" \
--demuxer-lavf-probe-info=nostreams \
--demuxer-lavf-analyzeduration=0.1 \
--demuxer-readahead-secs=0 \
--demuxer-rawvideo-fps="${UPSCALED_FPS}" \
--no-correct-pts --untimed --cache=no --cache-pause=no --no-pause - 
#-vf 'scale=w=640:h=360:flags=lanczos,setpts=(RTCTIME - RTCSTART) / (TB * 1000000)' 


#--no-correct-pts --untimed 
#--demuxer-lavf-o-add="use_wallclock_as_timestamps=1" 








else









DISPLAY="${D}" "$FFMPEG" -hide_banner -nostdin -fflags '+flush_packets' \
-vsync vfr \
-nostats \
-f x11grab \
-framerate "${UPSCALED_FPS}" \
-i "${D}".0+0,0 \
\
-c:v "$UU1" \
-an \
-vsync vfr \
"$UU2" "$UU3" \
-threads 0 \
-f nut - \
\
|
\
DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" "$MPV" \
-v --no-audio --keepaspect=yes --keep-open=no --no-initial-audio-sync --profile=qrawvideo \
\
--title="cd_mp_v" \
--wid=`DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" wmctrl -l 2>/dev/null| egrep -i 'cdmpv' | egrep -i VNC | grep -vi 'Terminal' | sed -r 's/\s.+//g' | tr -d "\n"` \
--no-input-default-bindings \
--input-terminal \
--no-input-cursor \
--no-input-vo-keyboard \
--stop-screensaver=no \
--input-ipc-server="${DIR}/mpvsocket" \
--config-dir="$MPV__CONFIG_DIR" \
--input-conf="$MPV__INPUT_CONF" \
--gpu-shader-cache-dir="$MPV__SHADER_CACHE" \
\
--vd-lavc-threads=1 \
--interpolation=yes \
--deband=no \
--video-latency-hacks=yes \
--cache-pause=no \
--no-demuxer-thread \
--demuxer=lavf --demuxer-lavf-format=nut \
--demuxer-lavf-probe-info=no \
--demuxer-lavf-o-add="avoid_negative_ts=make_zero" \
--demuxer-lavf-o-add="copyts=1" \
--demuxer-lavf-o-add="start_at_zero=1" \
--demuxer-lavf-o-add="fflags=+nobuffer+fastseek+flush_packets" \
--demuxer-lavf-probe-info=nostreams \
--demuxer-lavf-analyzeduration=0.1 \
--demuxer-readahead-secs=0 \
--demuxer-rawvideo-fps="${UPSCALED_FPS}" \
--no-correct-pts --untimed --cache=no --cache-pause=no --no-pause - \
#-vf 'scale=w=640:h=360:flags=lanczos,setpts=(RTCTIME - RTCSTART) / (TB * 1000000)' \


#--no-correct-pts --untimed 
#--demuxer-lavf-o-add="use_wallclock_as_timestamps=1" \

fi
