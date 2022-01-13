DISPLAY=:99 ./autocutsel/autocutsel -s CLIPBOARD -rawhex | (while read line ; do echo -n $line | xxd -r -p | env DISPLAY="${DISPLAY}" WAYLAND_DISPLAY="${WAYLAND_DISPLAY}" xclip  -sel clipboard -d $DISPLAY ; done )

