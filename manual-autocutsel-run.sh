#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}"/config.sh

DISPLAY="${D:-${GUEST_DISPLAY}}" ./autocutsel/autocutsel -s CLIPBOARD -rawhex | (while read line ; do echo -n $line | xxd -r -p | env DISPLAY="${DISPLAY}" WAYLAND_DISPLAY="${WAYLAND_DISPLAY}" xclip  -sel clipboard -d $DISPLAY ; done )

