#!/bin/bash
# This file should `source`d.
# Only $DIR is required to `source` this file.
if [ ! ${I3MSG:+1} ] # Don't execute this file multiple times
then
	if ! touch "${DIR}"/.mpv-input-DONTEDIT.conf
	then
		>&2 echo Exiting because failed to create "${DIR}"/.mpv-input-DONTEDIT.conf
		exit 1
	fi
	#cat "$MPV__INPUT_CONF" | grep -iv ' pause ' | sed -r 's/CTRL\+//ig' | perl -pe 's/format=fmt=[^:"]+(?::colorlevels=limited:colormatrix=auto)?//g' > "${MPV__INPUT_CONF}"
	#| perl -pe 's/(ctrl\+a )no-osd set vf "format=fmt=yuv444p10:colorlevels=limited:colormatrix=auto";/$1/gi' \
	#| perl -pe 's/format=fmt=[^:"]+(?::colorlevels=limited:colormatrix=auto)?//g' \
	cat "$MPV__INPUT_CONF" \
	| perl -pe 's/(ctrl\+[ao] no-osd set vf ")format=fmt=yuv444p10:colorlevels=limited:colormatrix=auto";/$1";/gi' \
	| grep -iv ' pause | speed |loop-file' \
	| sed -r 's/CTRL\+//ig' \
	> "${DIR}"/.mpv-input-DONTEDIT.conf
	#format=fmt=[^:"]+(?::colorlevels=limited:colormatrix=auto)?//g' > "${MPV__INPUT_CONF}"
	export MPV__INPUT_CONF="${DIR}"/.mpv-input-DONTEDIT.conf

	HOST_I3SOCK=`i3 --get-socketpath | tr -d "\n"`
	export HOST_DISPLAY=${HOST_DISPLAY:-${DISPLAY}}
	export HOST_WAYLAND_DISPLAY=${WAYLAND_DISPLAY}
	export HOST_RES=${HOST_RES:-$(xdpyinfo | grep imensions | grep -Eo '[0-9]+x[0-9]+ pixels' | grep -Eo '[0-9]+x[0-9]+' )}
	# \d+x\d+(?= pixels)
	#^example HOST_RES value is 1920x1080
	export HOST_W=$(echo -n "${HOST_RES}" | sed -r 's/x.+//g')
	export HOST_H=$(echo -n "${HOST_RES}" | sed -r 's/[0-9]+x//g')

	if [[ "${__GLX_VENDOR_LIBRARY_NAME}" == "nvidia" ]]
	then
		echo "You already have environment variable __GLX_VENDOR_LIBRARY_NAME=nvidia, don't forget"
		export isNvidia=1
	else
		if [[ ! ${__GLX_VENDOR_LIBRARY_NAME:+1} ]]
		then
			(nvidia-smi | grep '[MG]iB')>/dev/null 2>/dev/null && \
			echo 'Setting env var __GLX_VENDOR_LIBRARY_NAME to `nvidia` instead of default `mesa` because it seems you use an NVIDIA GPU' && \
			export __GLX_VENDOR_LIBRARY_NAME=nvidia && \
			export isNvidia=1
			#&& export __NV_PRIME_RENDER_OFFLOAD=1 && \
			#export __VK_LAYER_NV_optimus=NVIDIA_only && \
			#export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-0
		else
			# FIXME: or do not set it?
			#echo "Setting __GLX_VENDOR_LIBRARY_NAME=mesa"
			#export __GLX_VENDOR_LIBRARY_NAME=mesa
			export isNvidia=0
		fi
	fi



	if [ ${SWAYSOCK:+1} ]
	then
		I3MSG=swaymsg
	else
		I3MSG=i3-msg
	fi



	XDOTOOL=xdotool
fi
