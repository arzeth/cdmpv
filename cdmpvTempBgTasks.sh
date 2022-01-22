#!/bin/bash
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}"/config.sh
source "${DIR}"/vars.sh

trap "trap - SIGTERM && echo 'Caught SIGTERM, sending SIGTERM to process group' && kill -9 -- -$$" SIGINT SIGTERM EXIT
#trap "trap - SIGTERM && (/bin/kill --verbose --timeout 1000 TERM --timeout 1000 KILL --signal QUIT -- $$ || true) && sleep 0.2 && screen -xr mpv0 -X kill" SIGINT SIGTERM EXIT


#if [ "${BASH_SOURCE[0]}" -ef "$0" ]
if [ "$1" -ne "123456" ]
then
	echo "This file is supposed to be executed by another script. Exiting."
	exit 1
fi



sleep 2 # todo: do we need this line?

# cvt is better than gtf according to what I read;
# But gtf is better for virtual monitors because cvt outputs 59.86 Hz when asked for 60.00 Hz
modeline=`gtf ${GUEST_W} ${GUEST_H} ${GUEST_FPS} | grep Modeline | sed -r 's/^\s+//' |cut -d' ' -f2- | tr '"' ' '`
echo $modeline > /tmp/vncmodeline
XRANDR_RES=`echo -n ${modeline} | cut -d' ' -f1`
#XRANDR_RES=1280x720


# TODO: rg --pcre2 ..... ${GUEST_FPS}(?![0-9]) but Debian&Ubuntu's ripgrep is compiled without pcre2

# Fix resolution in the guest
function fixRes {
	# if the guest is Sway:
	#swaymsg output <name> --custom "${GUEST_W}x${GUEST_H}@${GUEST_FPS}Hz"
	# Do we need to this?:
	#swaymsg output <name> subpixel rgb|bgr|vrgb|vbgr|none

	# else:
	# Check if we already have the requested resolution at the requested refresh rate
	if [[ "$GUEST_FPS" != "60" ]]
	then
		(xrandr | grep "${GUEST_RES}"'(\s+[0-9.]{4,6}\*?\+?)*\s+'"${GUEST_FPS}" >/dev/null) || (xrandr --newmode $modeline && xrandr --addmode VNC-0 "${XRANDR_RES}")
		xrandr -s "${XRANDR_RES}" -r $GUEST_FPS
	fi
	xrandr --dpi 96
}
fixRes

# if we don't specify I3SOCK,
# then the child i3 will steal parent i3's sock;
# and when the child i3 would die,
# it would delete the sock so that both i3 had no sock.
# TODO: XCURSOR_SIZE=0?
mkfifo "${DIR}/i3-ipc-socket"
i3cfg="${DIR}/.i3-child-config.halfautogened_dontedit"
if [ ${SWAYSOCK}:+1 ]
then
	# xset (TODO: maybe also Xmodmap and setxkbmap?) work with Xwayland
	# pacman -S bemenu-wayland (wlroots-based compositors only)
	cat "${DIR}/i3-child-config" | sed 's/i3-msg/swaymsg/g' | grep -v xrandr | grep -v 'Xmodmap|setxkbmap' > "${i3cfg}"
else
	cat "${DIR}/i3-child-config" > "${i3cfg}"
fi
#echo 'exec "autocutsel -fork"' >> "${i3cfg}"

if [ "${PREFER_AUTOCUTSEL}" == "1" ]
then
	if [ "${ALLOW_COPYOUTOF}" == "1" ]
	then
		#echo 'exec "'"${DIR}"'/autocutsel/autocutsel -s PRIMARY -rawhex | (while read line ; do echo -n $line | xxd -r -p | env DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" xclip  -sel primary -d $HOST_DISPLAY ; done )"' >> "${i3cfg}"
		#echo 'exec "'"${DIR}"'/autocutsel/autocutsel -s CLIPBOARD -rawhex | (while read line ; do echo -n $line | xxd -r -p | env DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" xclip  -sel clipboard -d $HOST_DISPLAY ; done )"' >> "${i3cfg}"
		#("${DIR}"/autocutsel/autocutsel -s PRIMARY -rawhex | (while read line ; do echo -n $line | xxd -r -p | env DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" xclip  -sel primary -d $HOST_DISPLAY ; done ) ) &
		("${DIR}"/autocutsel/autocutsel -s CLIPBOARD -rawhex | (while read line ; do echo -n $line | xxd -r -p | env DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" xclip  -sel clipboard -d $HOST_DISPLAY ; done ) ) &
	fi
	ALLOW_COPYOUTOF=0
	ALLOW_COPYINTO=0
fi

I3MSG="${I3MSG}" I3SOCK="${DIR}/i3-ipc-socket" i3 -c "${i3cfg}" &
sleep 3 &&
fixRes
sleep 0.2


echo -n > "${DIR}/.env-of-current-process"
echo "# This file was generated by cdmpvTempBgTasks.sh" >> "${DIR}/.env-of-current-process"
echo "# This file is generated every time you launch cdmpv.sh" >> "${DIR}/.env-of-current-process"
echo "# This file is used only by x11wid.sh" >> "${DIR}/.env-of-current-process"
echo HOST_DISPLAY=\"${HOST_DISPLAY}\" >> "${DIR}/.env-of-current-process"
echo GUEST_DISPLAY=\"${DISPLAY}\" >> "${DIR}/.env-of-current-process"
echo WAYLAND_DISPLAY=\"${HOST_WAYLAND_DISPLAY}\" >> "${DIR}/.env-of-current-process"
echo GUEST_RES=\"${GUEST_RES}\" >> "${DIR}/.env-of-current-process"
echo GUEST_FPS=\"${GUEST_FPS}\" >> "${DIR}/.env-of-current-process"
echo RMPV=\"${RMPV}\" >> "${DIR}/.env-of-current-process"

if [[ "${STUPIDI3ONLYMETHOD}" == "1" ]]
then
	VNCVIEWER_AND_MPV_POS_X=`calc "floor((${HOST_W} - ${VNCVIEWER_AND_MPV_W}) / 2)"`
	VNCVIEWER_AND_MPV_POS_Y=`calc "floor((${HOST_H} - ${VNCVIEWER_AND_MPV_H}) / 2)"`
	#bash "${DIR}"/fixVncViewerAndMpvWindows.sh


	echo "geometry=${VNCVIEWER_AND_MPV_RES}+${VNCVIEWER_AND_MPV_POS_X}+${VNCVIEWER_AND_MPV_POS_Y}\n\n"
	sleep 0.1
	# fourcc is BGR3, while yuv pixel format is BGR24. Or I don't the terminology
	# beforce TsubaUp:
	#--demuxer-rawvideo-format=BGR3 \
	#--demuxer-rawvideo-mp-format=bgr24 \
	#  --speed=1.05 \
	#  --untimed \
	# if the input is not created 0 (and/or 1?) frame durations ago, then remove --no-correct-pts
	#DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" screen -Dm  -L -Logfile "/tmp/mpv0-$(date -Iseconds).log" -S mpv0 \
	DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" screen -Dm -S mpv0 \
	mpv \
--no-fs \
--demuxer-rawvideo-w="${GUEST_W}" \
--demuxer-rawvideo-h="${GUEST_H}" \
--demuxer-rawvideo-format=BGR3 \
--demuxer-rawvideo-mp-format=bgr24 \
--demuxer-rawvideo-fps="${GUEST_FPS}" \
--geometry="${VNCVIEWER_AND_MPV_RES}+${VNCVIEWER_AND_MPV_POS_X}+${VNCVIEWER_AND_MPV_POS_Y}" \
\
--input-conf="${MPV__INPUT_CONF}" \
--af="" \
--untimed \
--vf-pre="mpdecimate" \
--vf-pre="fps=${RMPV}" \
--fps="${RMPV}" \
--input-ipc-server="${DIR}"/mpvsocket \
--correct-pts \
--vd-lavc-threads=1 \
--cache-pause=no \
--demuxer-lavf-o-add="fflags=+nobuffer+fastseek+flush_packets" \
--demuxer-lavf-probe-info=nostreams \
--demuxer-lavf-analyzeduration=0.1 \
--demuxer-readahead-secs=0 \
--demuxer-thread=yes \
--interpolation=no \
--deband=no \
--no-audio \
--vd-queue-max-samples=2 \
--ad-queue-max-samples=1 \
--video-latency-hacks=yes \
--profile=low-latency \
--no-pause \
--force-window=yes \
--network-timeout=0 \
"av://v4l2:${CAM}" &
#  --demuxer-max-bytes=500MiB \


	#FIXME: or demuxerthread=no?
	rvncpath="${DIR}/realvnc-vnc-viewer/bin/vncviewer"
	if [[ -f "${rvncpath}" ]]
	then
		# Possible values for MenuKey: /usr/include/X11/keysymdef.h (just remove XK_)
		# But Super_L doesn't work. It seems only F1..F12 work
		#what's faster: Full or rgb111?
		DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" nice -n -15 "${rvncpath}" :0 -GrabKeyboard=0 -FullScreen=1 -PreferredEncoding=Raw -Quality=Low -ColorLevel=Full -AutoReconnect=0 -MenuKey= -DotWhenNoCursor=0 -UpdateScreenshot=0 -EnableToolbar=0 -ServerCutText=0 -SendPrimary=0 -RelativePtr=1 -Encryption=PreferOff -WarnUnencrypted=0 -Scaling=FitHeight &
		PICOM_ARGS="--opacity-rule='0:name *= \"cdmpv) - VNC Vie''wer\"'"
	else
		DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" nice -n -15 gvncviewer :0 &
		PICOM_ARGS="--opacity-rule='0:name *= \"GVncVie''wer\"'"
	fi
	unset rvncpath

	#if you somehow manage TigerVNC to upscale, then use: -PreferredEncoding=Raw -CompressLevel=0 -NoJpeg=1 in order to avoid stutters
	#ColorLevel

	sleep 1

	if ! pidof picom compton > /dev/null
	then
		PICOM_BIN=`( (whereis picom | grep -v ':$')>/dev/null && echo -n picom) || echo -n compton`
		if [ "$isNvidia" == "1" ]; then
			PICOM_ARGS="${PICOM_ARGS} --vsync --xrender-sync-fence"
		else
			PICOM_ARGS="${PICOM_ARGS} --vsync"
		fi
		#DISPLAY="${HOST_DISPLAY}" "$PICOM_BIN" $PICOM_ARGS &
		(echo -n "$PICOM_BIN" $PICOM_ARGS | DISPLAY="${HOST_DISPLAY}" bash) &
		unset PICOM_BIN
	fi
	unset PICOM_ARGS

	sleep 3
	DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" source "${DIR}"/fixVncViewerAndMpvWindows.sh "${VNC_WILL_BE_AT_DESKTOP}"
	fixRes
	sleep 2
	fixRes
else
	set -x
	DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" \
		vncviewer :0 -PreferredEncoding=Raw -CompressLevel=0 -NoJpeg=1 -MenuKey=F11 -AcceptClipboard=$ALLOW_COPYOUTOF -SendClipboard=$ALLOW_COPYINTO &
	sleep 3
	GUEST_DISPLAY="${DISPLAY}" DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" bash "${DIR}"/x11wid.sh &
	set +x
	sleep 3
	fixRes
	sleep 2
	fixRes
	sleep 2
	fixRes
	sleep 2
	fixRes
	sleep 2
	fixRes
fi
