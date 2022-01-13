#!/bin/bash
# THIS FILE IS USED ONLY WHEN USING DEPRECATED STUPIDI3ONLYMETHOD=1 in config.sh
#
#
#

if [[ "$STUPIDI3ONLYMETHOD" != "1" ]]
then
	>&2 echo "You can't use this file, because this is for deprecated method (for STUPIDI3ONLYMETHOD=1). Read README. Exiting."
	exit 1
fi

sleep 1
#export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#XDG_SESSION_TYPE=wayland
#WAYLAND_DISPLAY=wayland-1
#WLC_BG=0   ?
VNC_WILL_BE_AT_DESKTOP="${1:-${VNC_WILL_BE_AT_DESKTOP:-3}}" #counting from 1
HOST_RES=${HOST_RES:-$(xdpyinfo | grep imensions | grep -Eo '[0-9]+x[0-9]+ pixels' | grep -Eo '[0-9]+x[0-9]+' )}
#^example HOST_RES value is 1920x1080
HOST_W=${HOST_W:-$(echo "${HOST_RES}" | sed -r 's/x.+//g')}
HOST_H=${HOST_H:-$(echo "${HOST_RES}" | sed -r 's/[0-9]+x//g')}

GUEST_RES=${GUEST_RES:-"${1:-${GUEST_RES:-1280x720}}"}
GUEST_W=${GUEST_W:-$(echo "${GUEST_RES}" | sed -r 's/x.+//g')}
GUEST_H=${GUEST_H:-$(echo "${GUEST_RES}" | sed -r 's/[0-9]+x//g')}

echo "fixWindows:: GUEST_RES=$GUEST_RES"
echo "fixWindows:: HOST_RES=$HOST_RES"


# VNCVIEWER_AND_MPV_H is without menu, only useful area
# (although we don't see 1px at the bottom because we 1 pixel of menu at the top).
if [ ${UPRES:+1} ]; then
	VNCVIEWER_AND_MPV_W=$(echo "${UPRES}" | sed -r 's/x.+//ig')
	VNCVIEWER_AND_MPV_H=$(echo "${UPRES}" | sed -r 's/[0-9]+x//ig')
else
	#VNCVIEWER_AND_MPV_W=${VNCVIEWER_AND_MPV_W:-$(( HOST_H * (GUEST_W / GUEST_H) ))}
	VNCVIEWER_AND_MPV_W=${VNCVIEWER_AND_MPV_W:-`calc "floor(${HOST_H} * (${GUEST_W} / ${GUEST_H}))"`}
	VNCVIEWER_AND_MPV_H=${VNCVIEWER_AND_MPV_H:-${HOST_H}}
fi
#echo "${HOST_H} * (${GUEST_W} / ${GUEST_H}) = " \
#	`calc "${HOST_H} * (${GUEST_W} / ${GUEST_H})"`
VNCVIEWER_AND_MPV_RES=${VNCVIEWER_AND_MPV_RES:-${UPRES:-"${VNCVIEWER_AND_MPV_W}x${VNCVIEWER_AND_MPV_H}"}}

VNCVIEWER_AND_MPV_POS_X=${VNCVIEWER_AND_MPV_POS_X:-${UPX:-`calc "floor((${HOST_W} - ${VNCVIEWER_AND_MPV_W}) / 2)"`}}
VNCVIEWER_AND_MPV_POS_Y=${VNCVIEWER_AND_MPV_POS_Y:-${UPY:-`calc "floor((${HOST_H} - ${VNCVIEWER_AND_MPV_H}) / 2)"`}}
${I3MSG} "workspace ${VNC_WILL_BE_AT_DESKTOP}"

# if your dpi!=96, change this value
MENU_HEIGHT=0

HOW_MANY_PIXELS_OF_VNCVIEWER_ARE_FOCUSABLE=1

#LAST_PART_OF_CAM_PATH=`echo -n "${CAM}" | ssed -Rn 's@.+?/(.+)$@\1@p'`
LAST_PART_OF_CAM_PATH=`echo -n "${CAM}" | grep -Eo '[^/]+$'`

uvncpath="${DIR}/realvnc-vnc-viewer/bin/vncviewer"
if [[ -f "${uvncpath}" ]]
then
	ID=`wmctrl -l | egrep ') - VNC Viewer' | sed -r 's/\s.+//g'`
else
	ID=`wmctrl -l | grep 'GVncViewer' | sed -r 's/\s.+//g'`
fi
# it is video%number% without even a preceding / in `wmctrl -l`
MPVID=`wmctrl -l | grep "${LAST_PART_OF_CAM_PATH}" | grep mpv | sed -r 's/\s.+//g'`


echo "ID=${ID}"
echo "MPVID=${MPVID}"


if [ ${ID:+1} ]; then
	true
else
	MSG="VNC client is not launched for some reason, executing kill.sh"
	echo "${MSG}"
	#zenity --error --text="${MSG}" --display :0 &
	unset MSG
	"${DIR}"/kill.sh
fi

if [ ${MPVID:+1} ]; then
	true
else
	MSG="MPV is not launched for some reason, executing kill.sh"
	echo "${MSG}"
	#zenity --error --text="${MSG}" --display :0 &
	unset MSG
	"${DIR}"/kill.sh
fi


if [ ${ID:+1} ]; then
	wmctrl -ia ${ID}
	sleep 0.1
	${I3MSG} "move container to workspace ${VNC_WILL_BE_AT_DESKTOP}" > /dev/null
fi
#wmctrl -i -t $((VNC_WILL_BE_AT_DESKTOP-1)) ${ID}

#wmctrl -i -t $((VNC_WILL_BE_AT_DESKTOP-1)) ${MPVID}
#
#sleep 0.3
sleep 0.1

if [ ${MPVID:+1} ]; then
	wmctrl -ia ${MPVID}
	sleep 0.1
	${I3MSG} "move container to workspace ${VNC_WILL_BE_AT_DESKTOP}" > /dev/null
fi;


#wmctrl -s $((VNC_WILL_BE_AT_DESKTOP-1))
${I3MSG} "workspace ${VNC_WILL_BE_AT_DESKTOP}"


if [ ${ID:+1} ]; then
	${XDOTOOL} windowstate --remove FULLSCREEN ${ID}
	#${XDOTOOL} windowstate --remove FULLSCREEN --add STICKY ${ID}
	#${XDOTOOL} windowstate --add STICKY ${ID}
fi

if [ ${MPVID:+1} ]; then
	${XDOTOOL} windowstate --remove FULLSCREEN ${MPVID}
	sleep 0.2
	${XDOTOOL} windowstate --add ABOVE ${MPVID}
	if [ ${ID:+1} ]; then
		sleep 0.2
		${XDOTOOL} windowstate --add ABOVE ${ID}
	fi


	wmctrl -ia ${MPVID}
	sleep 0.2
	wmctrl -ia ${MPVID}
	${I3MSG} "border none"
	# TODO: awesome-client something something
	${I3MSG} floating enable
	sleep 0.2
fi;

if [ ${ID:+1} ]; then
	wmctrl -ia ${ID}
	sleep 0.2
	wmctrl -ia ${ID}
	${I3MSG} "border none"
	# TODO: awesome-client something something
	${I3MSG} floating enable

	sleep 0.1
fi


function swaywindowresize ()
{
	swaymsg resize shrink width 10000px
	sleep 0.1
	swaymsg resize grow width ${1}px

	sleep 0.1 # do we need this line?

	swaymsg resize shrink height 10000px
	sleep 0.1
	swaymsg resize grow height ${2}px
}

if [ ${ID:+1} ]; then
	if [ ${SWAYSOCK:+1} ]
	then
		swaywindowresize $VNCVIEWER_AND_MPV_W $((VNCVIEWER_AND_MPV_H + MENU_HEIGHT))
	else
		${XDOTOOL} windowsize $ID $VNCVIEWER_AND_MPV_W $((VNCVIEWER_AND_MPV_H + MENU_HEIGHT))
		#1926x1102
		${XDOTOOL} windowmove $ID $VNCVIEWER_AND_MPV_POS_X $((VNCVIEWER_AND_MPV_POS_Y + -MENU_HEIGHT + HOW_MANY_PIXELS_OF_VNCVIEWER_ARE_FOCUSABLE))
	fi
fi


if [ ${MPVID:+1} ]; then
	echo "vncviewer moved, now lets move mpv"
	if [ ${SWAYSOCK:+1} ]
	then
		wmctrl -ia ${MPVID}
		sleep 0.2
		swaywindowresize $VNCVIEWER_AND_MPV_W $((VNCVIEWER_AND_MPV_H + MENU_HEIGHT))
		sleep 0.2
		wmctrl -ia ${ID}
		sleep 0.2
	else
		${XDOTOOL} windowsize $MPVID $VNCVIEWER_AND_MPV_W $VNCVIEWER_AND_MPV_H
		${XDOTOOL} windowmove $MPVID $VNCVIEWER_AND_MPV_POS_X $VNCVIEWER_AND_MPV_POS_Y
	fi
fi

${XDOTOOL} mousemove $((VNCVIEWER_AND_MPV_POS_X + (VNCVIEWER_AND_MPV_W / 2))) $((VNCVIEWER_AND_MPV_POS_Y + (VNCVIEWER_AND_MPV_H / 2)))

if [ ${ID:+1} ]; then
	sleep 0.2
	wmctrl -ia ${ID}
	# unlike for GVncViewer, we need all these for RealVNC:
	sleep 0.5
	wmctrl -ia ${ID}
	sleep 0.5
	wmctrl -ia ${ID}
	sleep 0.5
	wmctrl -ia ${ID}
	sleep 0.5
	wmctrl -ia ${ID}
fi


#sleep 0.3
