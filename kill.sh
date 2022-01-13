#!/bin/bash
(killall -9 x11grab.sh && echo "killed x11grab.sh") 2>/dev/null
(killall -9 x11grab.sh && echo "killed x11grab.sh") 2>/dev/null
(killall -9 x11grab.sh && echo "killed x11grab.sh") 2>/dev/null
(killall -9 x11grab.sh && echo "killed x11grab.sh") 2>/dev/null
(killall -9 x11wid.sh && echo "killed x11wid.sh") 2>/dev/null
(killall -9 x11wid.sh && echo "killed x11wid.sh") 2>/dev/null
(killall -9 x11wid.sh && echo "killed x11wid.sh") 2>/dev/null
(killall -9 x11wid.sh && echo "killed x11wid.sh") 2>/dev/null
(killall -9 autocutsel && echo "killed all autocutsel") 2>/dev/null
(killall -9 gvncviewer && echo "killed all gvncviewer") 2>/dev/null
(killall -9 vncviewer && echo "killed all vncviewer") 2>/dev/null
screen -xr mpv0 -X kill >/dev/null 2>/dev/null
killall Xvnc 2>/dev/null
# Only SIGKILL (-9) can stop mpv!

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}"/config.sh
source "${DIR}"/vars.sh
# TODO: pgrep?
(kill -9 -- `ps h -C mpv -o pid,cmd | grep "${CAM}" | sed -r 's/^\s+//g' | cut -d' ' -sf1 | tr "\n" " "` && echo "killed mpv") 2>/dev/null
(kill -9 -- `ps h -C ffmpeg -o pid,cmd | grep "${CAM}" | sed -r 's/^\s+//g' | cut -d' ' -sf1 | tr "\n" " "` && echo "killed ffmpeg") 2>/dev/null
rm "${DIR}"/mpvsocket 2>/dev/null
#(killall picom && echo killed picom) 2>/dev/null
(killall compton && echo killed compton) 2>/dev/null
