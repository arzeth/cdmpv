#!/bin/bash
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [[ ! -f "${DIR}/config.sh" ]]
then
	if ! touch "${DIR}/config.sh"
	then
		>&2 echo "Exiting because cannot create \`${DIR}/config.sh\`"
		exit 1
	fi
	cat "${DIR}/config.sh.default" | grep -v 'AUTO COPIED' > "${DIR}/config.sh"
fi
source "${DIR}"/config.sh
source "${DIR}"/vars.sh

if [[ "$REMINDER_ABOUT_GIT_PULL" == "1" && -t 0 && "$TERM" != "" && "$WINDOWID" != "" ]]
then
	echo "Every 1-4 days there are updates, so use: git pull"
	echo "Waiting 3.5 seconds just so that you read the above line"
	sleep 3.5
fi

trap "trap - SIGTERM && echo 'Caught SIGTERM, sending SIGTERM to process group' && kill -9 -- -$$ && (kill -9 -- `ps h -C mpv -o pid,cmd | grep "${CAM}" | sed -r 's/^\\s+//g' | cut -d' ' -sf1 | tr \"\\n\" \" \"` && echo killed mpv) 2>/dev/null" SIGINT SIGTERM EXIT

IS_V4L_REQUIRED="${STUPIDI3ONLYMETHOD}"
if [ "${IS_V4L_REQUIRED}" == "1" ] # deprecated `if`
then
	#set -x
	if [[ ! -c "$CAM" ]] # $CAM is used only when config.sh's STUPIDI3ONLYMETHOD=1
	then
		echo "You have no ${CAM} (specified in ${DIR}/config.sh). Result of ls /dev/video* is"
		ls /dev/video*
		echo "Let me make you have it:"
		set -x
		sudo modprobe v4l2loopback devices=4 video_nr=0,7,8,9 card_label=OBS_Cam,Host_Display,Child_Display,Test_Input exclusive_caps=1
		set +x
		if [[ $? != 0 ]]; then
			echo "modprobe failed, cdmpv.sh won't continue"
			exit 1
		fi
		if [[ ! -c "$CAM" ]]; then
			echo "modprobe didn't do anything, maybe you already use v4l2loopback but with other parameters; cdmpv.sh won't continue"
			exit 1
		fi
	fi
fi


ORIGPWD=`pwd`

# "The export XKL_XMODMAP_DISABLE=1 line is needed to avoid keyboard mis-mapping"
export XKL_XMODMAP_DISABLE=1

if [ "${ALLOW_COPYINTO}${ALLOW_COPYOUTOF}" != '00' ]
then
	true
	#if ! grep autocutsel ~/.vnc/xstartup >/dev/null 2>/dev/null
	#then
		#if [[ -f ~/.vnc/xstartup ]]
		#then
			#echo "You already have ~/.vnc/xstartup but it doesn't launch autocutsel"
			#echo "which is used for copying (Ctrl+C) to/from the nested server"
			#echo "Combine the `xstartup` file here in the dir with the one in ~/.vnc/"
			#echo "Or set both ALLOW_COPYINTO and ALLOW_COPYOUTOF to 0"
			#echo "Exiting..."
			#exit 1
		#else
			#mkdir -p ~/.vnc/
			#if ! cp "${DIR}/xstartup" ~/.vnc/
			#then
				#echo "You have no ~/.vnc/xstartup which is needed to launch autocutsel"
				#echo "which is used for copying (Ctrl+C) to/from the nested server"
				#echo "Copying xstartup from here in the dir to ~/.vnc/ has failed."
				#echo "You can also set both ALLOW_COPYINTO and ALLOW_COPYOUTOF to 0."
				#echo "Exiting..."
				#exit 1
			#fi
		#fi
	#fi
fi




bash "${DIR}"/kill.sh

rm "${DIR}/.env-of-current-process" 2>/dev/null

UU=${1:-qwerty}
if [ "$UU" == 'qwerty' ]; then
	echo "No params supplied, read README"
	exit 1
fi
unset UU




( (whereis Xvnc | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/Xvnc not found, won't proceed, see README" && kill $$)
( (whereis i3 | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/i3 not found, won't proceed, see README" && kill $$)
( (i3 --version)>/dev/null) || (echo "/usr(/local)/bin/i3 WAS found, but `i3 --version` failed. Won't proceed." && kill $$)
( (whereis ${I3MSG} | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/${I3MSG} not found, won't proceed, see README" && kill $$)
( (whereis ffmpeg | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/ffmpeg not found, won't proceed, see README" && kill $$)
( (whereis mpv | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/mpv not found, won't proceed, see README" && kill $$)
( (mpv --version) >/dev/null) || (echo "Your MPV is broken, exiting" && kill $$)
( (whereis "${XDOTOOL}" | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/${XDOTOOL} not found, won't proceed, see README" && kill $$)
( (whereis wmctrl | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/wmctrl not found, won't proceed, see README" && kill $$)
( (whereis xrandr | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/xrandr not found, won't proceed, see README" && kill $$)
( (whereis xdpyinfo | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/xdpyinfo not found, won't proceed, see README" && kill $$)
( (whereis xset | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/xset not found, won't proceed, see README" && kill $$)
#( (whereis rg | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/rg not found, won't proceed, see README" && kill $$)
#( (whereis ssed | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/ssed not found, won't proceed, see README" && kill $$)
( (whereis calc | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/calc not found, won't proceed, see README" && kill $$)
#( (whereis cwebp | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/cwebp not found, won't proceed, see README" && kill $$)
#( (whereis setxkbmap | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/setxkbmap not found, won't proceed, see README" && kill $$)
( (whereis xfce4-terminal | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/xfce4-terminal not found, won't proceed, see README" && kill $$)
if [ "${STUPIDI3ONLYMETHOD}" == "1" ]
then
	( (whereis v4l2loopback-ctl | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/v4l2loopback-ctl not found, won't proceed, see README" && kill $$)
else
	( (whereis vncviewer | grep -v ':$')>/dev/null) || (echo "/usr(/local)/bin/vncviewer (TigerVNC) not found, won't proceed, see README" && kill $$)
fi

#( (whereis awk | grep -v ':$')>/dev/null) || (echo "/usr)(/local)/bin/awk not found, won't proceed, see README" && kill $$)

(ffmpeg -hide_banner -demuxers | grep x11grab >/dev/null 2>/dev/null) || (ffmpeg -buildconf && echo "Your FFmpeg is compiled without --enable-libxcb, which is need for: -f x11grab (screen capture), which is used in x11grab.sh file. If you use OBS instead for grabbing windows, then comment this line" && kill $$)

if [ "${PREFER_AUTOCUTSEL}" == "1" ]
then
	if [ ! -d "${DIR}/autocutsel" ]
	then
		echo "Exititing because \`${DIR}/autocutsel\` directory not found, won't proceed. You should git clone https://github.com/arzeth/cdmpv again."
		exit 1
	fi

	"${DIR}/autocutsel/autocutsel" -help
	if [ $? -ne "1" ]
	then
		echo "${DIR}/autocutsel/autocutsel not found, let's compile it"
		cd "${DIR}/autocutsel/"
		chmod +x bootstrap
		./bootstrap
		./configure --prefix=/usr || kill $$
		make || kill $$
		cd "${ORIGPWD}"
	fi
	#	( "${DIR}"/autocutsel/autocutsel -help || ( echo "${DIR}/autocutsel/autocutsel not found, " &&
fi


# There are many `sleep`s that assume the user has SSD or everything cached.
# In case the user uses an HDD, let's precache executables and libraries into RAM.
cat -- "${DIR}"/*.sh "${DIR}"/mpvconfig/* "${DIR}"/mpvconfig/*/* ~/.config/mpv/* ~/.config/mpv/*/* >/dev/null 2>/dev/null
Xvnc -version >/dev/null 2>/dev/null
i3 --help >/dev/null 2>/dev/null
${I3MSG} --help >/dev/null 2>/dev/null
#ffmpeg -decoders >/dev/null 2>/dev/null
mpv >/dev/null 2>/dev/null
${XDOTOOL} >/dev/null 2>/dev/null
wmctrl >/dev/null 2>/dev/null
xrandr >/dev/null 2>/dev/null
xdpyinfo >/dev/null 2>/dev/null
if [ "${STUPIDI3ONLYMETHOD}" == "1" ]
then
	v4l2loopback-ctl >/dev/null 2>/dev/null
else
	vncviewer -help >/dev/null 2>/dev/null
fi
xset >/dev/null 2>/dev/null
#rg >/dev/null 2>/dev/null
#ssed >/dev/null 2>/dev/null
calc '2+2' >/dev/null 2>/dev/null
#awk >/dev/null 2>/dev/null


# kills all background tasks when the script ends OR Ctrl+C
# killable-shell.sh: Kills itself and all children (the whole process group) when killed.
# Adapted from http://stackoverflow.com/a/2173421 and http://veithen.github.io/2014/11/16/sigterm-propagation.html
# Note: Does not work (and cannot work) when the shell itself is killed with SIGKILL, for then the trap is not triggered.
#trap "trap - SIGTERM && (/bin/kill --verbose --timeout 1000 TERM --timeout 1000 KILL --signal QUIT -- $$ || true) && sleep 0.2 && screen -xr mpv0 -X kill" SIGINT SIGTERM EXIT


#https://stackoverflow.com/questions/360201/how-do-i-kill-background-processes-jobs-when-my-shell-script-exits
#trap "trap - SIGTERM && (kill -9 -- -$$ || true) && screen -xr mpv0 -X kill" SIGINT SIGTERM EXIT

#trap "exit" INT TERM
#trap "kill 0" EXIT


#trap '[ -n "$(jobs -pr)" ] && kill $(jobs -pr)' INT QUIT TERM EXIT




# Otherwise child X11/Wayland uses llvmpipe


# On Arch Linux nvidia-smi is in nvidia-utils package.
# On Ubuntu try apt install nvidia-utils-{DRIVER_VERSION}

# nvidia-utils also includes vulkan, opengl, libcuda.so;
# so if they work, you already have nvidia-utils.



if [ "${STUPIDI3ONLYMETHOD}" == "1" ]
then
	AUTOSWITCH=${AUTOSWITCH:-1}

	if [ "$AUTOSWITCH" == '0' ]; then
		echo "NOW YOU HAVE 3 SECONDS TO"
		echo "QUICKLY SWITCH TO ANY VIRTUAL DESKTOP"
		echo "WITHOUT WINDOWS"
		echo
		echo "and THEN you need to wait for EXACTLY 20 seconds"
		echo "until you see the terminal having maximized window"
		echo "Don't do anything with any window/desktop for those 20 seconds"
		echo "If nothing happened, then ./kill.sh and try again"
		#echo 5....
		#sleep 1
		#echo 4....
		#sleep 1
		echo 3....
		sleep 1
		echo 2....
		sleep 1
		echo 1....
		sleep 1
		echo 0
	else
		# counting from 1
		${I3MSG} workspace 3 >/dev/null
	fi
fi









#export HOST_RES=$(xdpyinfo | awk '/dimensions/{print $2}' )
# Arch Linux uses gawk as awk, Debian uses mawk as awk, but both have the same rg
#export HOST_RES=${HOST_RES:-$(xdpyinfo | grep imensions | ssed -R 's@^.+\s([0-9]+x[0-9]+)\s.+$@\1@' )}
# User should provide their own HOST_RES only if they want a particular monitor


export DISPLAY="${GUEST_DISPLAY}"
unset WAYLAND_DISPLAY






export GUEST_RES="${1:-${GUEST_RES:-1280x720}}"
export GUEST_W=$(echo -n ${GUEST_RES} | sed -r 's/x.+//g')
export GUEST_H=$(echo -n ${GUEST_RES} | sed -r 's/[0-9]+x//g')
echo GUEST_RES = ${GUEST_RES}


# Maybe there are games that don't like a refresh rate <60 Hz
export GUEST_REFRESH_RATE="${2:-60}"
# How many FPS we will see in mpv.
# I.e, how many frames per second your GPU can upscale using your shader chain.
export UPSCALED_FPS="${3:-30}"


if [[ "${STUPIDI3ONLYMETHOD}" == "1" ]]
then
	# counting from 1
	export VNC_WILL_BE_AT_DESKTOP="${4:$(${XDOTOOL} get_desktop)}"

	# VNCVIEWER_AND_MPV_H is the height without the menu, only the useful area
	# (although we don't see 1px at the bottom because we 1 pixel of the menu at the top).
	if [ ${UPRES:+1} ]; then
		export VNCVIEWER_AND_MPV_W=$(echo -n "${UPRES}" | sed -r 's/x.+//ig')
		export VNCVIEWER_AND_MPV_H=$(echo -n "${UPRES}" | sed -r 's/[0-9]+x//ig')
	else
		#VNCVIEWER_AND_MPV_W=$(( HOST_H * (GUEST_W / GUEST_H) ))
		export VNCVIEWER_AND_MPV_W=`calc "floor(${HOST_H} * (${GUEST_W} / ${GUEST_H}))"`
		export VNCVIEWER_AND_MPV_H="${HOST_H}"
	fi
	#echo "${HOST_H} * (${GUEST_W} / ${GUEST_H}) = " \
	#	`calc "${HOST_H} * (${GUEST_W} / ${GUEST_H})"`
	export VNCVIEWER_AND_MPV_RES="${VNCVIEWER_AND_MPV_W}x${VNCVIEWER_AND_MPV_H}"
	echo VNCVIEWER_AND_MPV_RES = $VNCVIEWER_AND_MPV_RES
fi

echo HOST_H = $HOST_H







#newenv

#unset origenv
#unset newenv
#env | egrep '^()'


bash "${DIR}"/cdmpvTempBgTasks.sh 123456 &

#(sleep 2 && (xrandr -s ${GUEST_RES} || true) && env I3SOCK="${DIR}/i3-ipc-socket.%p" i3 -c "${DIR}/i3-child-config") &
#(
#	sleep 4 && # THIS IS THE MOST IMPORTANT NUMBER TO THE PERFORMANCE, how many frames per second send to fake webcam
#	(bash "${DIR}"/x11grab.sh "${UPSCALED_FPS}" "${GUEST_RES}" &) &&
#	sleep 3 &&
#	(env DISPLAY=${HOST_DISPLAY} WAYLAND_DISPLAY=${HOST_WAYLAND_DISPLAY} screen -Dm -S mpv0 mpv --no-fs --profile=low-latency --no-pause av://v4l2:${CAM} &) &&
#	(env DISPLAY=${HOST_DISPLAY} WAYLAND_DISPLAY=${HOST_WAYLAND_DISPLAY} gvncviewer :0 &) &&
#	sleep 3 &&
#	env DISPLAY=${HOST_DISPLAY} WAYLAND_DISPLAY=${HOST_WAYLAND_DISPLAY} bash "${DIR}"/fixVncViewerAndMpvWindows.sh "${VNC_WILL_BE_AT_DESKTOP}" &&
#	xrandr -s ${GUEST_RES} &&
#	sleep 2 &&
#	xrandr -s ${GUEST_RES}
#) &
##while read i; do wmctrl -i -t 2 -r "$i"  ; done  < <(wmctrl -l | awk -v var=$(${XDOTOOL} get_desktop) '{if ($2 == var) print $0;}' | cut -d' '  -f1)
#(sleep 8 && (xrandr -s ${GUEST_RES} || true) && env DISPLAY=${HOST_DISPLAY} picom) &

# Move all windows from Desktop #3 to #4 (counting from 1)
#TODO: ${I3MSG} -t get_workspaces   get .nodes, then find .nodes's child with name=cur display ("DP-2"), then find in this child a node that has .nodes, then find a child with .num===3, then move every child in its .nodes
# Source: https://askubuntu.com/a/589930
#FROM_DESKTOP=${VNC_WILL_BE_AT_DESKTOP}
#TO_DESKTOP=4
#while read i; do
#	#wmctrl -i -t $((TO_DESKTOP-1)) -r "$i";
#	env DISPLAY="${HOST_DISPLAY}" wmctrl -ia "$i"
#	sleep 0.2
#	env DISPLAY="${HOST_DISPLAY}" WAYLAND_DISPLAY="${HOST_WAYLAND_DISPLAY}" ${I3MSG} "move container to workspace ${TO_DESKTOP}" > /dev/null
##done  < <(wmctrl -l | awk -v var=$((FROM_DESKTOP-1)) '{if ($2 == var) print $0;}' | cut -d' '  -f1)
#done  < <(wmctrl -l | awk -v var=$((FROM_DESKTOP-1)) '{if ($2 == var) print $0;}' | cut -d' '  -f1)

#trap "trap - SIGTERM && echo 'Caught SIGTERM, sending SIGTERM to process group' && kill -9 -- -$$" SIGINT SIGTERM EXIT

#echo $@
#"$@" &
#PID=$!
#wait $PID
#trap - SIGINT SIGTERM EXIT
#wait $PID


# autocutsel -fork ???

if [ "${PREFER_AUTOCUTSEL}" == "1" ]
then
	ALLOW_COPYOUTOF=0
	ALLOW_COPYINTO=0
fi

# If you use Dvorak/etc on host, but want a different keyboard layout (QWERTY/etc) on guest
# then set RawKeyboard=1 and maybe uncomment the setxkbmap line in `i3-child-config` file.
# For gaming it is useful to use QWERTY.
DONTPAINT=1
#if [ "${DONTPAINT}" == "1" ]
#then
#	xdamageoptname="-extension"
#else
	xdamageoptname="+extension"
#fi
set -x
DONTPAINT="${DONTPAINT}" Xvnc \
\
+iglx \
-dpi 96 \
-FrameRate=1 \
-CompareFB=0 \
-ImprovedHextile=0 \
-ZlibLevel=0 \
\
-AlwaysShared=1 \
-localhost=1 \
-AcceptSetDesktopSize=0 \
-UseBlacklist=0 \
-UseIPv6=0 \
\
-AcceptCutText="$ALLOW_COPYOUTOF" \
-SendCutText="$ALLOW_COPYINTO" \
-SendPrimary=0 \
-SetPrimary=0 \
-RawKeyboard=1 \
\
-geometry "${GUEST_RES}" \
-rfbport "${VNC_PORT}" \
-rfbunixpath "${VNC_SOCKET_PATH}" \
-rfbunixmode "${VNC_SOCKET_PERMS}" \
-SecurityTypes None \
\
-nocursor \
-desktop=cdmpv \
-depth 24 \
-pixelformat RGB888 \
+extension Composite \
"${xdamageoptname}" Damage \
+extension Xfixes "${DISPLAY}"


# x0vncserver specific;
# -display ${HOST_DISPLAY}

# Xvnc specific:
#  -nocursor \
#  -desktop=cdmpv \
#  -depth 24 -pixelformat RGB888 \
#  +extension Composite \
#  +extension Xfixes ${DISPLAY}


# https://wiki.archlinux.org/title/TigerVNC: "It looks like Composite extension in VNC will work only with 24bit depth."
# -RawKeyboard
#>/dev/null 2>/dev/null

# Only if vncserver crashed this line will run:
bash "${DIR}"/kill.sh
# If user presses ctrl+c, it won't
